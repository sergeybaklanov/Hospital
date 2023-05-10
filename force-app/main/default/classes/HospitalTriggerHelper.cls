public with sharing class HospitalTriggerHelper extends TriggerHandler{
    protected override void afterInsert(){
        generateNewUsers(1);
    }

      @Future(callout = true)
    public static void generateNewUsers(Integer numUsers){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Randomuser_Site__c site = Randomuser_Site__c.getInstance();
        String endpoint = site.Endpoint__c + 'api/' + site.RefID__c + '?key=' + site.Key__c + '&results=' + numUsers;
        System.debug('endpoint: '+endpoint);
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode()==200) {

            String responseBody = response.getBody();
        System.debug('response: ' + responseBody);
        System.debug('response: ' + response.getStatusCode());
        }
    }

}