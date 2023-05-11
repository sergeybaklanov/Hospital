public with sharing class DailyCurrencyUpdateSchedule implements Schedulable{
    public void scheduleProcess(){
    }

    public void execute(SchedulableContext ctx){
        updateCurrency();
    }

    @Future(callout = true)
    private static void updateCurrency(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setEndpoint('https://api.privatbank.ua/p24api/pubinfo?exchange&coursid=5');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200){
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        }
    }
}