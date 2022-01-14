trigger TodoTrigger on Todo__c (before insert, before update, before delete) {
    if(Trigger.isInsert || Trigger.isUpdate) {
        List<Todo__c> todos = Trigger.new;
        for(Todo__c todo : todos) {
            // get display date for ui
            todo.Display_Date_Time__c = DateUtil.getDisplayDate(todo.Task_Time__c);
            todo.Custom_Id__c = DateTime.now().getTime() + '';
            if(Trigger.isUpdate) {
                // if update, abort old scheduled job for this task
                try {
                    System.abortJob(todo.Job_Id__c);
                } catch(Exception e) {
                    // Job is already executed and aborted, do nothing as new job will be scheduled
                }
            }
            // schedule task
            DateTime dt = todo.Task_Time__c;
            string exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            TodoAlertScheduler sch = new TodoAlertScheduler(todo);
            todo.Job_Id__c = System.schedule('Alert-' +todo.Custom_Id__c, exp, sch);
        }
    }   

    if(Trigger.isDelete) {
        List<Todo__c> todos = Trigger.old; // old context variable used for delete trigger, 'new' can't be used
        for(Todo__c todo : todos) {
            try {
                System.abortJob(todo.Job_Id__c);
            } catch(Exception e) {
                // Job is already executed and aborted, do nothing as new job will be scheduled
            }
        }
    }
}