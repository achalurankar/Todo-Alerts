public with sharing class TodoTriggerHandler {
    public void execute(List<Todo__c> newTodos, List<Todo__c> oldTodos) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            this.handleBeforeInsertUpdate(newTodos);
        } else if(Trigger.isDelete) {
            this.handleBeforeDelete(oldTodos); // old context variable used for delete trigger, 'new' can't be used
        }
    }

    private void handleBeforeInsertUpdate(List<Todo__c> todos) {
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
            string exp = ''; // seconds minutes hour day_of_month month day_of_week year(optional)
            if(todo.Frequency__c == 'Weekly')
                exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' ? JAN-DEC ' + dt.format('E').toUppercase();
            if(todo.Frequency__c == 'Monthly')
                exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' JAN-DEC ? ';
            if(todo.Frequency__c == 'One time')
                exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            if(todo.Frequency__c == 'Daily')
                exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' * * ? *';
            System.debug('Cron exp for ' + todo.Frequency__c + ' = ' + exp);
            TodoAlertScheduler sch = new TodoAlertScheduler(todo);
            todo.Job_Id__c = System.schedule('Alert-' + todo.Custom_Id__c, exp, sch);
        }
    }

    private void handleBeforeDelete(List<Todo__c> todos) {
        for(Todo__c todo : todos) {
            try {
                System.abortJob(todo.Job_Id__c);
            } catch(Exception e) {
                // Job is already executed and aborted
            }
        }
    }
}
