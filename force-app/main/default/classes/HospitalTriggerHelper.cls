public with sharing class HospitalTriggerHelper extends TriggerHandler{
    protected override void afterInsert(){
        addUsers((Map<Id, Account>)Trigger.newMap);
    }

    private static void addUsers(Map<Id, Account> newAccountsMap){
        generateUsers(newAccountsMap.keySet());
    }

    @Future(callout = true)
    public static void generateUsers(Set<Id> newHospitalsList){
        Randomuser_Site__c site = RandomUser_Site__c.getInstance();
        final Integer NUM_PATIENTS = 2;
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String endpoint = 'https://randomapi.com/api/' + site.RefID__c + '?key=' + site.Key__c + '&results=' + NUM_PATIENTS;
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        List<Patient__c> newPatientsList = new List<Patient__c>();
        for (Id hospitalId_i : newHospitalsList){
            HttpResponse response = http.send(request);
            System.debug('response.getStatusCode() : ' + response.getStatusCode());
            if (response.getStatusCode() == 200){
                Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                System.debug(result);
                List<Object> objectsList = (list<Object>)result.get('results');
                for (Object res_i : objectsList){
                    Map<String, Object> user = (Map<String, Object>)res_i;
                    String[] userName = ((String) user.get('name')).split(' ');
                    String [] userBirthDate = ((String)user.get('date')).split('-');
                    Integer year = Integer.valueOf(userBirthDate[0]);
                    Integer month = Integer.valueOf(userBirthDate[1]);
                    Integer day = Integer.valueOf(userBirthDate[2]);
                    newPatientsList.add(new Patient__c(Hospital__c = hospitalId_i, First_Name__c = userName[0], Last_Name__c = userName[1], Birthday_date__c = Date.newInstance(year, month, day)));
                }
            } else{
                System.debug('Callout failed with status code ' + response.getStatusCode() + ': ' + response.getStatus());
            }
        }
        System.debug('newPatientsList: ' + newPatientsList);
        Database.insert (newPatientsList, true);
    }

}