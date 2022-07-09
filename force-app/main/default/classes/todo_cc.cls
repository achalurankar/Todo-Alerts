@RestResource(urlMapping='/Todo/*')
global with sharing class todo_cc {
    public todo_cc() {

    }
    
    @HttpGet
    @AuraEnabled
    global static List<TaskWrapper> getTasks() {
        List<TaskWrapper> todos = new List<TaskWrapper>();
        for(Todo__c todo : [SELECT Name, Task_Time__c, Frequency__c, Description__c, Display_Date_Time__c, Is_Completed__c FROM Todo__c WHERE CreatedById = :UserInfo.getUserId() ORDER BY Task_Time__c ASC]) {
            todos.add(new TaskWrapper(todo));
        }
        return todos;
    }

    @AuraEnabled
    @HttpPost
    global static string postTask(string requestStructure){
        try {
            TaskWrapper wrapper = (TaskWrapper) JSON.deserialize(requestStructure, TaskWrapper.class);
            System.debug('task wrapper ' + wrapper);
            Todo__c task = wrapper.getObject();
            if(wrapper.action == 'delete') {
                delete task;
                return wrapper.id;
            }
            upsert task;
            return task.Id;
        } catch (Exception e) {
            throw e;
        }
    }

    global class TaskWrapper {
        @AuraEnabled public string id; 
        @AuraEnabled public string name; 
        @AuraEnabled public string action;
        @AuraEnabled public string description;
        @AuraEnabled public string frequency;
        @AuraEnabled public DateTime taskTime; 
        @AuraEnabled public string displayDateTime; 
        @AuraEnabled public boolean isCompleted; 

        public TaskWrapper(Todo__c todo) {
            this.id = todo.Id;
            this.name = todo.Name;
            this.description = todo.Description__c;
            this.frequency = todo.Frequency__c;
            this.taskTime = todo.Task_Time__c;
            this.displayDateTime = todo.Display_Date_Time__c;
            this.isCompleted = todo.Is_Completed__c;
        }

        public Todo__c getObject() {
            Todo__c todo = new Todo__c();
            todo.Id = this.id != '' ? this.id : null;
            todo.Name = this.Name;
            todo.Description__c = this.description;
            todo.Frequency__c = this.frequency;
            todo.Task_Time__c = this.taskTime;
            todo.Display_Date_Time__c = this.displayDateTime;
            todo.Is_Completed__c = this.isCompleted;
            return todo;
        }
    }
}