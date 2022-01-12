import { api, LightningElement, track } from 'lwc';
import postTask from "@salesforce/apex/todo_cc.postTask";
import deleteTask from "@salesforce/apex/todo_cc.deleteTask";
import getTasks from "@salesforce/apex/todo_cc.getTasks";
import { log } from 'c/utils';

export default class TodoLwc extends LightningElement {

    @track tasks;
    @track showModal = false;
    @track fields;
    idVsTaskMap;
    selectedBook;

    renderedCallback() {
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
                log(err, true);
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
                log(err, true);
            })
    }

    handleCancel() {
        this.showModal = false;
    }

    handleSave(event) {
        let updatedFields = event.detail.updatedFields;
        console.log( JSON.stringify(updatedFields) );
        let id = this.selectedBook === undefined ? '' : this.selectedBook.id;
        let name = updatedFields[0].value, taskTime = updatedFields[1].value, isCompleted = false;
        let params = { id : id, name : name, taskTime : taskTime, isCompleted : isCompleted };
        postTask({ requestStructure : JSON.stringify(params) })
            .then(res => {
                this.loadTasks();
                this.showModal = false;
            })
            .catch(err => {
                log(err, true);
            })
    }

    getFields(name = "", datetime = "2020-09-12T18:13:41Z") {
        return [
            { label : "Task Name", type : "text", value : name, uniqueName: "name", required : true },
            { label : "Task Date & Time", type : "datetime", value : datetime, uniqueName: "datetime", required : true }
        ];
    }
}