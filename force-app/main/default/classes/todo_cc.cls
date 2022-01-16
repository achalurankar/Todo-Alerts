@RestResource(urlMapping='/Todo/*')
global with sharing class todo_cc {
    public todo_cc() {

    }
    
    @HttpGet
    @AuraEnabled
    global static List<Todo__c> getTasks() {
        return [SELECT Name, Task_Time__c, Description__c, Display_Date_Time__c, Is_Completed__c FROM Todo__c WHERE CreatedById = :UserInfo.getUserId() ORDER BY Task_Time__c ASC];
    }

    @AuraEnabled
    @HttpPost
    global static string postTask(string requestStructure){
        try {
            TaskWrapper wrapper = (TaskWrapper) JSON.deserialize(requestStructure, TaskWrapper.class);
            System.debug('task wrapper ' + wrapper);
            Todo__c task = new Todo__c();
            if(wrapper.id != '') {
                task.Id = wrapper.id;
            }
            if(wrapper.action == 'delete') {
                delete task;
                return wrapper.id;
            }
            if(wrapper.description != null) {
                task.Description__c = wrapper.description;
            }
            task.Name = wrapper.name;
            task.Task_Time__c = wrapper.taskTime;
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
        @AuraEnabled public DateTime taskTime; 
        @AuraEnabled public string displayDateTime; 
        @AuraEnabled public boolean isCompleted; 
    }
}
