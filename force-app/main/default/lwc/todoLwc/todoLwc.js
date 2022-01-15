import { api, LightningElement, track } from 'lwc';
import postTask from "@salesforce/apex/todo_cc.postTask";
import deleteTask from "@salesforce/apex/todo_cc.deleteTask";
import getTasks from "@salesforce/apex/todo_cc.getTasks";

export default class TodoLwc extends LightningElement {

    @track tasks;
    @track showModal = false;
    @track fields;
    idVsTaskMap;
    selectedBook;

    connectedCallback() {
        this.loadTasks();
    }

    loadTasks() {
        getTasks()
            .then(res => {
                this.tasks = JSON.parse(res);
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
        this.selectedBook = undefined;
        this.showModal = true;
    }

    // edit task button click
    handleEditTaskClick(event) {
        let taskId = event.currentTarget.dataset.id;
        this.selectedBook = this.idVsTaskMap[`${taskId}`];
        this.fields = this.getFields(this.selectedBook.name, this.selectedBook.taskTime);
        this.showModal = true;
    }

    // delete task button click
    handleDeleteTaskClick(event) {
        let taskId = event.currentTarget.dataset.id;
        deleteTask({ taskId : taskId })
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
        let id = this.selectedBook === undefined ? '' : this.selectedBook.id;
        let name = updatedFields[0].value, taskTime = updatedFields[1].value, isCompleted = false;
        let params = { id : id, name : name, taskTime : taskTime, isCompleted : isCompleted };
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

    getFields(name = "", datetime = "") {
        return [
            { label : "Task Name", type : "text", value : name, uniqueName: "name", required : true },
            { label : "Task Date & Time", type : "datetime", value : datetime, uniqueName: "datetime", required : true }
        ];
    }
}