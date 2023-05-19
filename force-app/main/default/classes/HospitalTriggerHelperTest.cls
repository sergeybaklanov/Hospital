@IsTest
public with sharing class HospitalTriggerHelperTest{
    @IsTest
    private static void insertTest(){
        Test.setMock(HttpCalloutMock.class, new PatientGeneratorCalloutMock());
        List<Account> hospitalsList = new List<Account>();
        Id hospitalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital').getRecordTypeId();

        Test.startTest();
            TestDataFactory.createHospitalsList(2, true);
        Test.stopTest();

        List<Account> hospitalsAfterInsertList = [SELECT Id, (SELECT Id
                                                              FROM Patients__r)
                                                  FROM Account 
                                                  WHERE RecordTypeId = :hospitalRecordTypeId];

        Assert.areEqual(2,hospitalsAfterInsertList.size(), 'Incorrect num of Hospitals records');
        for (Account acc_i : hospitalsAfterInsertList){
            Assert.areEqual(10,acc_i.Patients__r.size(), 'Incorrect num of related patients for each hospital');
        }
    }

}