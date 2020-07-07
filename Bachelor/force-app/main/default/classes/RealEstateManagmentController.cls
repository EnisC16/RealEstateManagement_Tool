public with sharing class RealEstateManagmentController {

    public class MyException extends Exception {}


    @AuraEnabled
    public static List<Location> getPropertyList(
        Decimal bathrooms,
        Decimal bedrooms,
        Decimal radius,
        String city,
        String postalcode,
        Decimal minPrice,
        Decimal maxPrice
    ){
        String query = 'SELECT Id,Bathrooms__c,Bedrooms__c,Broker__r.Name,Buyer__r.LastName,'; 
        query += 'Comission_for_Buyer__c,Construction_Date__c,Country__c,Living_Space__c,Buyer__r.FirstName,City__c,';
        //query += 'Location_Description__c,Object_Condition__c,Object_Description__c,Equipment__c,'; ,Location__latitude__s,Location__longitude__s,
        query += 'Rooms__c,Seller__r.LastName,Seller__r.FirstName,State__c,Street__c,Type__c,PostalCode__c,Price__c,Name';
        query += ' FROM Real_Estate__c';

        if(bathrooms != NULL || bedrooms != NULL || (radius != NULL && 
            (city != NULL || postalcode != NULL)) || minPrice != NULL || maxPrice != NULL)
        {
            query += ' WHERE';

            if(bathrooms != null) {
                query += ' Bathrooms__c >= :bathrooms';
                if(bedrooms != null || minPrice != null || maxPrice != null || (city != NULL || postalcode != NULL) && radius != NULL) {
                    query += ' AND';
                }
            }
            if(bedrooms != null) {
                query += ' Bedrooms__c >= :bedrooms';
                if(minPrice != null || maxPrice != null || (city != NULL || postalcode != NULL) && radius != NULL) {
                    query += ' AND';
                }
            }
            if(minPrice != null) {
                query += ' Price__c >= :minPrice';
                if(maxPrice != null || (city != NULL || postalcode != NULL) && radius != NULL) {
                    query += ' AND';
                }
            }
            if(maxPrice != null) {
                query += ' Price__c <= :maxPrice';
                if((city != NULL || postalcode != NULL) && radius != NULL) {
                    query += ' AND';
                }
            }
            
            if((city != NULL || postalcode != NULL) && radius != NULL) {

                GeolocationService geoService = new GeolocationService();
                geoService.calculateGeolocationByAddress('', city, '', '',postalcode);

                try{
                    if(geoService.result == 'SUCCESS') {
                        query += ' DISTANCE(Location__c, GEOLOCATION('+String.valueOF(geoService.latitude)+','+String.valueOf(geoService.longitude)+'), \'km\') < '+String.valueOf(radius);
                    }
                    else {
                        throw new MyException(geoService.message);
                    }

                 } catch (Exception e) {
                    system.debug(e.getMessage());
                }
            }
        }

        query += ' LIMIT 10000';
        List<Real_Estate__c> listRealEstate = Database.query(query);

        List<Location> listLocs = new List<Location>();
        for(Real_Estate__c obj : listRealEstate){
            GeoLocation geoInfo = new GeoLocation();
            geoInfo.Street = obj.Street__c;
            geoInfo.PostalCode = obj.PostalCode__c;
            geoInfo.City = obj.City__c;
            geoInfo.State = obj.State__c;
            geoInfo.Country = obj.Country__c;
            Location locDetail = new Location();
            locDetail.icon = 'action:new_account'; 
            locDetail.value = obj.Id;
            locDetail.title = obj.Name;
            locDetail.description = (obj.Street__c != NULL ? (obj.Street__c+'<br/>') : '');
            locDetail.description += (obj.PostalCode__c != NULL ? (obj.PostalCode__c+' ') : '');
            locDetail.description += (obj.City__c != NULL ? (obj.City__c+'<br/>') : '');
            locDetail.description += (obj.State__c != NULL ? (obj.State__c+'<br/>') : '');
            locDetail.description += (obj.Country__c != NULL ? obj.Country__c : '<br/>');
            locDetail.location = geoInfo;
            
            listLocs.add(locDetail);
        }

        return listLocs;
    }


    public class Location{
        @AuraEnabled 
        public String value{get;set;} 
        @AuraEnabled 
        public String icon{get;set;} 
        @AuraEnabled 
        public String title{get;set;} 
        @AuraEnabled
        public String description{get;set;} 
        @AuraEnabled 
        public GeoLocation location{get;set;} 
    }
    public class GeoLocation{
        @AuraEnabled 
        public String Street{get;set;}
        @AuraEnabled 
        public String PostalCode{get;set;}
        @AuraEnabled 
        public String City{get;set;}
        @AuraEnabled 
        public String State{get;set;}
        @AuraEnabled 
        public String Country{get;set;}
    }


    @AuraEnabled
    public static PropertyWrapper getPropertyDetails(String recordId){
        List<ContentDocumentLink> documentFiles = [
                SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.Title, ContentDocument.CreatedDate
                FROM ContentDocumentLink
                WHERE LinkedEntityId  = :recordId
                ORDER BY ContentDocument.CreatedDate ASC];

        PropertyWrapper wrapper = new PropertyWrapper(recordId);
        wrapper.files = documentFiles;

        return wrapper;
    }

    public class PropertyWrapper {
        @AuraEnabled
        public List<ContentDocumentLink> files;
        @AuraEnabled
        public Real_Estate__c property;

        public PropertyWrapper(String recordId){
            this.property = [SELECT Rooms__c,Seller__r.LastName,
                    Seller__r.FirstName,State__c,Street__c,Type__c,
                    PostalCode__c,Price__c,Name,Bathrooms__c,
                    Bedrooms__c,Broker__r.Name,Buyer__r.LastName,
                    Comission_for_Buyer__c,Construction_Date__c,
                    Country__c,Living_Space__c,Buyer__r.FirstName,
                    City__c,Location_Description__c,Object_Condition__c,
                    Object_Description__c,Equipment__c,
                    Location__latitude__s,Location__longitude__s
                             FROM Real_Estate__c
                             WHERE Id = :recordId];
            this.listURL = new List<String>();
            this.files = new List<ContentDocumentLink>();
        }
    }

}
