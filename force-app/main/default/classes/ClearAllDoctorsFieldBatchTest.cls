@isTest
public with sharing class ClearAllDoctorsFieldBatchTest{
    @TestSetup
    public static void makeData(){
        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<Account> hospitalList = TestDataFactory.createHospitalsList(1, true);
        List<Account> hospitalDepartmentList = TestDataFactory.createHospitalsDepartmentList(1, hospitalList, true);
        List<Contact> doctorsList = TestDataFactory.createDoctorsList(112, hospitalDepartmentList, false);
        for (Integer i = 0; i < doctorsList.size(); i++){
            if (i < 2){
                doctorsList[i].Payments_amount__c = 0;
                doctorsList[i].Best_doctor_of_the_month__c = false;
            } else if (i == 2){
                doctorsList[i].Best_doctor_of_the_month__c = true;
                doctorsList[i].Payments_amount__c = 500;
            } else{
                doctorsList[i].Best_doctor_of_the_month__c = false;
                doctorsList[i].Payments_amount__c = 100;
            }

        }
        insert doctorsList;
    }

    @IsTest
    static void clearAllDoctorsFieldTest(){

        Test.startTest();
        Id batchId = Database.executeBatch(new ClearAllDoctorsFieldBatch());
        Test.stopTest();

        AsyncApexJob job = [SELECT Id, Status, JobItemsProcessed
                            FROM AsyncApexJob
                            WHERE Id = :batchId];
        System.assertEquals(1, job.JobItemsProcessed);
        System.assertEquals('Completed', job.Status);

        List<Contact> doctorsList = [SELECT Id
                                     FROM Contact
                                     WHERE Payments_amount__c = 0 AND Best_doctor_of_the_month__c = false];

        System.assertEquals(112, doctorsList.size(), 'Unexpected  result. Doctors num of records must be 112');
    }

}