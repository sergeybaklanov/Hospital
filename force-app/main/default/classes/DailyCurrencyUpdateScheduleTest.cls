@IsTest
public with sharing class DailyCurrencyUpdateScheduleTest{
    public static String CRON_EXP = '0 0 * * * ? *';
    @IsTest
    static void updateCurrencyTest(){

        Test.setMock(HttpCalloutMock.class, new DailyCurrencyCalloutMock());

        List<Rate_currency__c> rateToInsertList = new List<Rate_currency__c>();
        rateToInsertList.add(new Rate_currency__c(Name='USD-UAH', buy__c=0, sale__c=0));
        rateToInsertList.add(new Rate_currency__c(Name='EUR-UAH', buy__c=0, sale__c=0));
        insert rateToInsertList;

        System.debug('rateToInsertList '+rateToInsertList);

        Test.startTest();
        DailyCurrencyUpdateSchedule.updateCurrency();
        Test.stopTest();

        Map<String,Rate_currency__c> rateMap = Rate_currency__c.getAll();
        System.debug(rateMap);

        System.assertEquals(2, rateMap.size());
            
        Assert.areEqual(41.5, rateMap.get('EUR-UAH').sale__c);
        Assert.areEqual(40.5, rateMap.get('EUR-UAH').buy__c);

        Assert.areEqual(37.62, rateMap.get('USD-UAH').sale__c);
        Assert.areEqual(37.12, rateMap.get('USD-UAH').buy__c);
    }

}