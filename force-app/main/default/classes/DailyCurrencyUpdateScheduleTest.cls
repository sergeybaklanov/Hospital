@IsTest
public with sharing class DailyCurrencyUpdateScheduleTest{
    public static String CRON_EXP = '0 0 * * * ? *';
    @IsTest
    static void updateCurrencyTest(){

        Test.setMock(HttpCalloutMock.class, new DailyCurrencyCalloutMock());

        Test.startTest();
           // System.schedule('Currency daily update', CRON_EXP, new DailyCurrencyUpdateSchedule());
           DailyCurrencyUpdateSchedule.updateCurrency();
        Test.stopTest();


        List<Currency_rate__mdt> customMetadataList = [SELECT Id, MasterLabel, sale__c, buy__c
                                                            FROM Currency_rate__mdt];
        System.assertEquals(2, customMetadataList.size());

        for (Currency_rate__mdt metadata_i : customMetadataList) {
            if(metadata_i.MasterLabel =='USD_UAH'){
                System.assertEquals(37.62000, metadata_i.sale__c);
                System.assertEquals( 37.12000,metadata_i.buy__c);
            }
            if(metadata_i.MasterLabel =='EUR_UAH'){
                System.assertEquals(41.50000, metadata_i.sale__c);
                System.assertEquals( 40.50000,metadata_i.buy__c);
            }
        }
    }
}