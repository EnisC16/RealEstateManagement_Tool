public class RealEstateTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
        if (TriggerSettings__c.getOrgDefaults().RealEstateTriggerDisabled__c == true) {
            return true;
        }
        else {
            return TriggerDisabled;
        }
    }
 
    public void BeforeInsert(List<SObject> newItems) {
        /* update geolocation fields */
        if(newItems.size() == 1) {
            updateGeolocationField((Real_Estate__c) newItems[0]);
        }
    }
 
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterInsert(Map<Id, SObject> newItems) {}
 
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
 
    public void AfterDelete(Map<Id, SObject> oldItems) {}
 
    public void AfterUndelete(Map<Id, SObject> oldItems) {}

    private void updateGeolocationField(Real_Estate__c property) {
        if(property.Location__latitude__s == NULL || property.Location__longitude__s == NULL) {
            GeolocationService geoService = new GeolocationService();
            geoService.calculateGeolocationByAddress(property.Street__c,
                                                    property.City__c,
                                                    property.Country__c,
                                                    property.State__c,
                                                    property.Country__c,
                                                    property.PostalCode__c);

            if(geoService.result == 'SUCCESS') {
                property.Location__latitude__s = geoService.latitude;
                property.Location__longitude__s = geoService.longitude;
            }
            
        }
    }
}
