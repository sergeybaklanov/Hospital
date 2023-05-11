public with sharing class HospitalTriggerHelper extends TriggerHandler{
    protected override void afterInsert(){
        System.debug('Trigger on insert Account');
        addUsers((List<Account>)Trigger.new );
    }

    private static void addUsers(List<Account> newAccountsList){
        List<Id> hospitalIdsToProcessList = new List<Id>();
        for (Account account_i : newAccountsList){
            if (account_i.RecordType.Name == 'Hospital'){
                hospitalIdsToProcessList.add(account_i.Id);
            }
        }
        generateUsers(hospitalIdsToProcessList);
    }

    @Future(callout = true)
    public static void generateUsers(List<Id> newHospitalsList){

        final Integer NUM_USERS = 1;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Randomuser_Site__c site = RandomUser_Site__c.getInstance();
        
        String endpoint = 'https://randomapi.com/api/' + site.RefID__c + '?key=' + site.Key__c + '&results=' + NUM_USERS;
        System.debug('endpoint: ' + endpoint);
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        System.debug('request: ' + request);
        HttpResponse response = http.send(request);
        System.debug(response.getStatusCode());

        if (response.getStatusCode() == 200){
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        } else{
            System.debug('Callout failed with status code ' + response.getStatusCode() + ': ' + response.getStatus());
        }
    }

}