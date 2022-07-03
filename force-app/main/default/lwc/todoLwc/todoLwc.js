import { api, LightningElement, track } from 'lwc';
import postTask from "@salesforce/apex/todo_cc.postTask";
import getTasks from "@salesforce/apex/todo_cc.getTasks";

export default class TodoLwc extends LightningElement {

    @track tasks;
    @track showModal = false;
    @track fields;
    idVsTaskMap;
    selectedTask;

    connectedCallback() {
        this.loadTasks();
    }

    loadTasks() {
        getTasks()
            .then(res => {
                this.tasks = res;
                this.idVsTaskMap = {};
                res.forEach(element => {
                    this.idVsTaskMap[`${element.id}`] = element;
                });
            })
            .catch(err => {
                console.log(JSON.stringify(err));
            });
    }

    // new task button click
    handleNewTaskClick() {
        this.fields = this.getFields();
        this.selectedTask = undefined;
        this.showModal = true;
    }

    // edit task button click
    handleEditTaskClick(event) {
        let taskId = event.currentTarget.dataset.id;
        this.selectedTask = this.idVsTaskMap[`${taskId}`];
        this.fields = this.getFields(this.selectedTask.name, this.selectedTask.taskTime, this.selectedTask.frequency);
        this.showModal = true;
    }

    // delete task button click
    handleDeleteTaskClick(event) {
        let taskId = event.currentTarget.dataset.id;
        let params = { id : taskId, action : "delete" };
        postTask({ requestStructure : JSON.stringify(params) })
            .then(res => {
                this.loadTasks();
            })
            .catch(err => {
                console.log(JSON.stringify(err));
            })
    }

    handleCancel() {
        this.showModal = false;
    }

    handleSave(event) {
        let updatedFields = event.detail.updatedFields;
        let id = this.selectedTask === undefined ? '' : this.selectedTask.id;
        let name = updatedFields.inputs[0].value
        let taskTime = updatedFields.inputs[1].value
        let frequency = updatedFields.comboboxes[0].value
        let isCompleted = false;
        let params = { id : id, name : name, taskTime : taskTime, isCompleted : isCompleted, action : "upsert", frequency : frequency };
        // console.log(JSON.stringify(params));
        postTask({ requestStructure : JSON.stringify(params) })
            .then(res => {
                this.loadTasks();
                this.showModal = false;
            })
            .catch(err => {
                console.log(JSON.stringify(err));
            })
    }

    getFields(name = "", datetime = "", frequency = "") {
        const frequencyOptions = [{ label : "One time", value : "One time" }, { label : "Daily", value : "Daily" }, { label : "Weekly", value : "Weekly" }, { label : "Monthly", value : "Monthly" }];
        
        return {
            inputs : [
                { label : "Task Name", type : "text", value : name, uniqueName: "name", required : true },
                { label : "Task Date & Time", type : "datetime", value : datetime, uniqueName: "datetime", required : true }
            ],
            comboboxes : [
                { label : "Frequency", options : frequencyOptions, uniqueName : "frequency", value : frequency, required : true },
            ]
        }
    }
}