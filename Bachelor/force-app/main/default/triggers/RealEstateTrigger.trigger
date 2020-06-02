Trigger RealEstateTrigger on Real_Estate__c (before insert) {
    TriggerDispatcher.Run(new RealEstateTriggerHandler());
}