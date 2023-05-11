@IsTest
public with sharing class HospitalTriggerHelperTest{
    @IsTest
    private static void insertTest(){
        Test.setMock(HttpCalloutMock.class, new PatientGeneratorCalloutMock());
        List<Account> hospitalsList = new List<Account>();
        Id hospitalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital').getRecordTypeId();
        for (Integer i = 0; i < 2; i++){
            hospitalsList.add(new Account(RecordTypeId = hospitalRecordTypeId, Name = 'Test Hospital' + i));
        }
        Test.startTest();
        insert hospitalsList;
        Test.stopTest();

        List<Account> hospitalsAfterInsertList = [SELECT Id , (SELECT Id FROM Patients__r) FROM Account WHERE RecordTypeId=:hospitalRecordTypeId];

        System.assert(hospitalsAfterInsertList.size()==2,'Incorrect num of Hospitals records');
        for(Account acc_i: hospitalsAfterInsertList){
            System.assertEquals(10, acc_i.Patients__r.size());
            System.assert(acc_i.Patients__r.size()==10, 'Incorrect num of related patients for each hospital');
        }

    }

}