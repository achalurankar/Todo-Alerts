public with sharing class todo_cc {
    public todo_cc() {

    }
    
    @AuraEnabled
    public static List<TaskWrapper> getTasks() {
        List<Todo__c> todos = [SELECT Name, Task_Time__c, Is_Completed__c FROM Todo__c WHERE CreatedById = :UserInfo.getUserId()];
        List<TaskWrapper> tasks = new List<TaskWrapper>();
        for(Todo__c todo : todos) {
            TaskWrapper tw = new TaskWrapper();
            tw.id = todo.Id;
            tw.name = todo.Name;
            tw.taskTime = todo.Task_Time__c;
            tw.isCompleted = todo.Is_Completed__c;
            tasks.add(tw);
        }
        return tasks;
    }

    @AuraEnabled
    public static string postTask(string requestStructure){
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
            throw new AuraHandledException(e.getMessage());
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
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class TaskWrapper {
        @AuraEnabled public string id; 
        @AuraEnabled public string name; 
        @AuraEnabled public DateTime taskTime; 
        @AuraEnabled public boolean isCompleted; 
    }
}