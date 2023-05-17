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

            List<Metadata.CustomMetadata> customMetadataList = new List<Metadata.CustomMetadata>();

            for (CurrencyWrapper res_i : results){
                String fullName = 'Currency_rate.' + res_i.ccy + '_' + res_i.base_ccy;
                String label = res_i.ccy + '_' + res_i.base_ccy;

                Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                customMetadata.fullName = fullName;
                customMetadata.label = label;

                Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                fieldWithValuesMap.put('buy__c', res_i.buy);
                fieldWithValuesMap.put('sale__c', res_i.sale);

                for (String key : fieldWithValuesMap.keySet()){
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    customField.field = key;
                    customField.value = fieldWithValuesMap.get(key);
                    customMetadata.values.add(customField);
                }

                customMetadataList.add(customMetadata);
            }

            CreateUpdateMetadataUtils.createUpdateMetadata(customMetadataList);
        }
    }

    class CurrencyWrapper{
        public String ccy;
        public String base_ccy;
        public Decimal buy;
        public Decimal sale;

    }

}