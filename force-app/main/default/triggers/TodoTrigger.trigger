trigger TodoTrigger on Todo__c (before insert, before update, after insert, after update) {
    if(Trigger.isInsert || Trigger.isUpdate) {
        if(Trigger.isBefore) {
            List<Todo__c> todos = Trigger.new;
            for(Todo__c todo : todos) {
                // get display date for ui
                todo.Display_Date_Time__c = DateUtil.getDisplayDate(todo.Task_Time__c);
                todo.Custom_Id__c = DateTime.now().getTime() + '';
                // schedule task
                DateTime dt = todo.Task_Time__c;
                string exp = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
                TodoAlertScheduler sch = new TodoAlertScheduler(todo);
                todo.Job_Id__c = System.schedule('Alert-' +todo.Custom_Id__c, exp, sch);
            }
        }
    }
}