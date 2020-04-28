public with sharing class RealEstateManagmentController {
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
                String address = ((postalcode != NULL ? postalcode+' ' : '') +(city != NULL ? city : ''));
                address = EncodingUtil.urlEncode(address+' Germany', 'UTF-8');

                String endpoint='https://eu1.locationiq.com/v1/search.php?key=5e6b269dc80685&q='+address+'&format=json';

                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                //req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
                req.setMethod('GET');
                req.setTimeout(5000);

                try{
                    HttpResponse res = h.send(req);
                    JSONParser parser = JSON.createParser(res.getBody());
                    System.debug('res----->'+res.getBody());

                    Double lat = null;
                    Double lon = null;

                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lat') && lat == null){
                            parser.nextToken();
                            lat = Double.valueOf(parser.getText());
                        }
                        else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lon') && lon == null){
                            parser.nextToken();
                            lon = Double.valueOf(parser.getText());
                        }
                    }
                    System.debug('lat: '+lat+'#### lon: '+lon);
                    query += ' DISTANCE(Location__c, GEOLOCATION('+String.valueOF(lat)+','+String.valueOf(lon)+'), \'km\') < '+String.valueOf(radius);

                 } catch (Exception e) {
                    system.debug(e);
                }
            }
        }

        query += ' LIMIT 10000';
        System.debug('query:----->'+query.right(45));

        List<Location> listLocs = new List<Location>();
        for(Real_Estate__c obj : Database.query(query)){
            System.debug('real estate: '+obj);
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
            //locDetail.description += '<button type="button" onclick="{!c.openProperties}">Open</button>';
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
                WHERE LinkedEntityId  = :recordId //AND (ContentDocument.Title LIKE '%.png' OR ContentDocument.Title LIKE '%.jpg' )
                ORDER BY ContentDocument.CreatedDate ASC];

        PropertyWrapper wrapper = new PropertyWrapper(recordId);

        for(ContentDocumentLink link : documentFiles) {
            System.debug('link ----> '+link);
            System.debug('ContentDocument.Title ----> '+link.ContentDocument.Title);
            wrapper.listURL.add('/sfc/servlet.shepherd/document/download/'+link.ContentDocumentId);
            // /sfc/servlet.shepherd/version/download/
            // /sfc/servlet.shepherd/document/download/
            // /servlet/servlet.FileDownload?file=
        }

        return wrapper;
    }

    public class PropertyWrapper {
        @AuraEnabled
        public List<String> listURL;
        @AuraEnabled
        public Real_Estate__c property;

        public PropertyWrapper(String recordId){
            this.property = [SELECT Rooms__c,Seller__r.LastName,Seller__r.FirstName,State__c,Street__c,Type__c,PostalCode__c,Price__c,Name,
                                Bathrooms__c,Bedrooms__c,Broker__r.Name,Buyer__r.LastName,
                                Comission_for_Buyer__c,Construction_Date__c,Country__c,Living_Space__c,Buyer__r.FirstName,City__c,
                                Location_Description__c,Object_Condition__c,Object_Description__c,Equipment__c,Location__latitude__s,Location__longitude__s
                             FROM Real_Estate__c
                             WHERE Id = :recordId];
            this.listURL = new List<String>();
        }
    }

}
