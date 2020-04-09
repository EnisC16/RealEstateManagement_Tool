public with sharing class RealEstateManagmentController {
    @AuraEnabled
    public static List<Real_Estate__c> getPropertyList(
        Decimal bathrooms,
        Decimal bedrooms,
        Decimal radius,
        String city,
        String postalcode,
        Decimal minPrice,
        Decimal maxPrice
    ){
        String query = 'SELECT Id FROM Real_Estate__c';

        if(bathrooms != NULL || bedrooms != NULL || radius != NULL || 
            city != NULL || postalcode != NULL || minPrice != NULL || maxPrice != NULL)
        {
            query += ' WHERE';

            if(bathrooms != null) {
                query += ' Bathrooms__c <= :bathrooms';
            }
            if(bedrooms != null) {
                query += ' Bedrooms__c <= :bedrooms';
            }
            if(minPrice != null) {
                query += ' Price__c >= :minPrice';
            }
            if(maxPrice != null) {
                query += ' Price__c <= :maxPrice';
            }
            if(city != NULL && postalcode != NULL && radius != NULL) {
                String address = postalcode+' '+city;
                address = EncodingUtil.urlEncode(address, 'UTF-8');

                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
                req.setMethod('GET');
                req.setTimeout(5000);

                try{
                    HttpResponse res = h.send(req);
                    JSONParser parser = JSON.createParser(res.getBody());

                    double lat = null;
                    double lon = null;

                    while (parser.nextToken() != null) {

                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'location')){

                            parser.nextToken();

                            while (parser.nextToken() != JSONToken.END_OBJECT){

                                String txt = parser.getText();
                                parser.nextToken();

                                if (txt == 'lat')
                                    lat = parser.getDoubleValue();

                                else if (txt == 'lng')
                                    lon = parser.getDoubleValue();

                            }

                        }

                    }
                 } catch (Exception e) {
                    system.debug(e);
                }

                query += ' DISTANCE(Location__c, GEOLOCATION(:lat,:lon), \'km\') < :radius';
            }
        }

        query += ' LIMIT 10000';
        return Database.query(query);
    }
}
