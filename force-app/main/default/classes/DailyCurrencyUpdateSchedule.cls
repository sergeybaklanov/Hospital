public with sharing class DailyCurrencyUpdateSchedule implements Schedulable{
    public void execute(SchedulableContext ctx){
        updateCurrency();
    }

    @Future(callout = true)
    public static void updateCurrency(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setEndpoint('https://api.privatbank.ua/p24api/pubinfo?exchange&coursid=5');
        HttpResponse response = http.send(request);
        System.debug('Response: ' + response.getBody());
        System.debug('Before checking response');

        if (response.getStatusCode() == 200){
            List<CurrencyWrapper> results = (List<CurrencyWrapper>)JSON.deserialize(response.getBody(), List<CurrencyWrapper>.class);
            System.debug('Results: ' + results);

            Map<String, Rate_currency__c> currencyRateMap =Rate_currency__c.getAll(); 

            for (CurrencyWrapper res_i : results){
                String label = res_i.ccy + '-' + res_i.base_ccy;
                currencyRateMap.get(label).buy__c = res_i.buy;
                currencyRateMap.get(label).sale__c = res_i.sale;
            }
            update currencyRateMap.values();
        }
    }

    class CurrencyWrapper{
        public String ccy;
        public String base_ccy;
        public Decimal buy;
        public Decimal sale;

    }

}