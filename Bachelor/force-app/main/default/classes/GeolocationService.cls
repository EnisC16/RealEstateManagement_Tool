public class GeolocationService {
    public Double latitude;
    public Double longitude;

    public String message;
    public String result;

    public void calculateGeolocationByAddress(String postalcode, String city) {

        String address = ((postalcode != NULL ? postalcode+' ' : '') +(city != NULL ? city : ''));
        address = EncodingUtil.urlEncode(address+' Germany', 'UTF-8');

        String endpoint='https://eu1.locationiq.com/v1/search.php?key=5e6b269dc80685&q='+address+'&format=json';

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(5000);

        try{
            HttpResponse res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            System.debug('res----->'+res.getBody());

            latitude = null;
            longitude = null;
            message = '';

            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lat') && latitude == null){
                    parser.nextToken();
                    latitude = Double.valueOf(parser.getText());
                }
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'lon') && longitude == null){
                    parser.nextToken();
                    longitude = Double.valueOf(parser.getText());
                }
            }
            System.debug('lat: '+latitude+'#### lon: '+longitude);

            result = 'SUCCESS';

        } catch (Exception e) {
            result = 'ERROR';
            message = e.getMessage();
            system.debug(e);
        }
    }
}
