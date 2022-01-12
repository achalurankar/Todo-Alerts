trigger TodoTrigger on Todo__c (before insert, before update) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        List<Todo__c> todos = Trigger.new;
        for(Todo__c todo : todos) {
            // get display date
            todo.Display_Date_Time__c = DateUtil.getDisplayDate(todo.Task_Time__c);
            // schedule the task
        }
    }
}