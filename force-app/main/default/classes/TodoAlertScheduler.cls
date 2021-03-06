global with sharing class TodoAlertScheduler implements Schedulable {
    
    //task id of the task which is being scheduled
    global Todo__c todo;
    
    global TodoAlertScheduler(Todo__c todo) {
        this.todo = todo;
    }
    
    global void execute(SchedulableContext sc) {
        Application_Log__c appLog = new Application_Log__c();
        try {
            appLog.Source__c = 'TodoAlertScheduler';
            appLog.Message__c = '------------------------------------------';
            appLog.Message__c += '\n\nScheduler called for ' + todo;
            System.debug('Scheduled Apex executed for task Id ' + this.todo);
            // sending mail
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { 'achalurankar@gmail.com' };
            message.optOutPolicy = 'FILTER';
            message.subject = '\'' + this.todo.Name + '\' reminder';
            if(this.todo.Description__c != null) 
                message.htmlbody = 'Your task is due, task details are as follows,<br>Task : <b>'+ this.todo.Name +
                    '</b><br>Due Date : <b>' + this.todo.Display_Date_Time__c + 
                    '</b><br>Description : <b>'+ this.todo.Description__c +
                    '</b><br>Regards,<br>Todo Alert Bot.';
            else
                message.htmlbody = 'Your task <b>'+ this.todo.Name +'</b> scheduled at <b>'+ this.todo.Display_Date_Time__c + '</b> is due, make sure to check it out and complete it :)<br>Regards,<br>Todo Alert Bot.';
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');    
                appLog.Message__c += '\n\nThe Email was sent successfully';
            } else {
                appLog.Message__c += '\n\nThe email failed to send: ' + results[0].errors[0].message;
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }

            // abort one time job as email is sent
            if(todo.Frequency__c == 'One time') {
                Todo__c obj = [SELECT Job_Id__c FROM Todo__c WHERE Custom_Id__c = :todo.Custom_Id__c];
                appLog.Message__c += '\n\nAborting One Time job';
                System.abortJob(obj.Job_Id__c);
                appLog.Message__c += '\n\nOne Time job aborted';
                
            }
        } catch(Exception e) {
            appLog.Message__c += '\n\nException ' + e.getMessage() + '\n' + e.getStackTraceString();
        }
        appLog.Message__c += '\n\n------------------------------------------';
        insert appLog;
    }
}