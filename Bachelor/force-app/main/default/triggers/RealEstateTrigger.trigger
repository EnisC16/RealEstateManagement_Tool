Trigger RealEstateTrigger on Real_Estate__c (after insert) {
    TriggerDispatcher.Run(new RealEstateTriggerHandler());
}