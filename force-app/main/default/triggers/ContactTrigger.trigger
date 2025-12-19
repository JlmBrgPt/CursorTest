trigger ContactTrigger on Contact (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ContactTriggerHandler.updateAddressFromAccount(Trigger.new, Trigger.oldMap);
        }
    }
}

