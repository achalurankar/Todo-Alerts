@RestResource(urlMapping='/Todo/*')
global with sharing class todo_cc {
    public todo_cc() {

    }
    
    @HttpGet
    @AuraEnabled
    global static string getTasks() {
        List<Todo__c> todos = [SELECT Name, Task_Time__c, Display_Date_Time__c, Is_Completed__c FROM Todo__c WHERE CreatedById = :UserInfo.getUserId()];
        List<TaskWrapper> tasks = new List<TaskWrapper>();
        for(Todo__c todo : todos) {
            TaskWrapper tw = new TaskWrapper();
            tw.id = todo.Id;
            tw.name = todo.Name;
            tw.taskTime = todo.Task_Time__c;
            tw.displayDateTime = todo.Display_Date_Time__c;
            tw.isCompleted = todo.Is_Completed__c;
            tasks.add(tw);
        }
        return JSON.serialize(tasks);
    }

    @AuraEnabled
    @HttpPost
    global static string postTask(string requestStructure){
        try {
            TaskWrapper wrapper = (TaskWrapper) JSON.deserialize(requestStructure, TaskWrapper.class);
            System.debug('task ' + wrapper);
            Todo__c task = new Todo__c();
            task.Name = wrapper.name;
            task.Task_Time__c = wrapper.taskTime;
            if(wrapper.id != '') {
                task.Id = wrapper.id;
            }
            upsert task;
            return task.Id;
        } catch (Exception e) {
            throw e;
        }
    }

    @AuraEnabled
    public static string deleteTask(string taskId){
        try {
            Todo__c todo = new Todo__c();
            todo.Id = taskId;
            delete todo;
            return taskId;
        } catch (Exception e) {
            throw e;
        }
    }

    global class TaskWrapper {
        @AuraEnabled public string id; 
        @AuraEnabled public string name; 
        @AuraEnabled public DateTime taskTime; 
        @AuraEnabled public string displayDateTime; 
        @AuraEnabled public boolean isCompleted; 
    }
}
