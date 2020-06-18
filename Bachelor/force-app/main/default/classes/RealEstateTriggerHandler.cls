public class RealEstateTriggerHandler implements ITriggerHandler {

    public static Boolean TriggerDisabled = false;

    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().RealEstateTriggerDisabled__c == true) {
            return true;
        }
        else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {}

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {
        if(newItems.size() == 1) {
            String propertyId = String.valueOf(newItems.values()[0].get('Id'));
            System.debug('propertyId ---->'+propertyId);
            updateGeolocationField(propertyId);
        }
    }
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    @future (Callout = true)
    private static void updateGeolocationField(String propertyId) {
        Real_Estate__c property = [SELECT Id,Street__c,City__c,Country__c,State__c,PostalCode__c,Location__latitude__s,Location__longitude__s FROM Real_Estate__c WHERE Id = :propertyId];

        if(property.Location__latitude__s == NULL || property.Location__longitude__s == NULL) {
            GeolocationService geoService = new GeolocationService();
            geoService.calculateGeolocationByAddress(property.Street__c,
                                                    property.City__c,
                                                    property.State__c,
                                                    property.Country__c,
                                                    property.PostalCode__c);

            if(geoService.result == 'SUCCESS') {
                property.Location__latitude__s = geoService.latitude;
                property.Location__longitude__s = geoService.longitude;
            }

            update property;
        }
    }
}
