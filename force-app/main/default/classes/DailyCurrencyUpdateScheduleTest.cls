@IsTest
public with sharing class DailyCurrencyUpdateScheduleTest{
    public static String CRON_EXP = '0 0 * * * ? *';
    @IsTest
    static void testMethodName(){
        Test.setMock(HttpCalloutMock.class, new DailyCurrencyCalloutMock());

        Test.startTest();
        System.schedule('Currency daily update', CRON_EXP, new DailyCurrencyUpdateSchedule());
        Test.stopTest();
    }

}