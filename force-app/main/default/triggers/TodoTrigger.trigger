trigger TodoTrigger on Todo__c (before insert, before update, before delete) {
    new TodoTriggerHandler().execute(Trigger.new, Trigger.old);
}