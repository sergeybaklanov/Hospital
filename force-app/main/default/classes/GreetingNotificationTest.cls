@IsTest
public with sharing class GreetingNotificationTest{
    private static final String CRON_EXP = '0 0 0 L * ?';
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<Account> hospitalList = TestDataFactory.createHospitalsList(1, true);
        List<Account> hospitalDepartmentList = TestDataFactory.createHospitalsDepartmentList(1, hospitalList, false);
        hospitalDepartmentList[0].Department__c = 'Surgery';
        hospitalDepartmentList[0].Department_type__c = 'Adult';
        hospitalDepartmentList[0].Doctor_payments_to_receive_bonus__c = 300;
        insert hospitalDepartmentList;

        List<Contact> doctorsList = TestDataFactory.createDoctorsList(3, hospitalDepartmentList, false);
        for (Integer i = 0; i < doctorsList.size(); i++){
            if (i == 0){
                doctorsList[i].Best_doctor_of_the_month__c = true;
                doctorsList[i].Email = 'bestdoctor' + i + '@gmail.com';
            } else{
                doctorsList[i].Best_doctor_of_the_month__c = false;
                doctorsList[i].Email = 'looserofmonth' + i + '@gmail.com';
            }
        }
        insert doctorsList;
    }

    @IsTest
    static void testMethodName(){

        Test.startTest();
        System.schedule('Greeting notification', CRON_EXP, new GreetingNotification());
        Test.stopTest();

        List<Contact> bestDoctor = [SELECT Id, AccountId
                                    FROM Contact
                                    WHERE Best_doctor_of_the_month__c = true];
        System.assertEquals(1, bestDoctor.size());

        List<Task> taskList = [SELECT Id, WhoId, WhatId, Subject, Bonus__c
                               FROM Task
                               WHERE WhoId = :bestDoctor[0].Id AND WhatId = :bestDoctor[0].AccountId];
        System.assertEquals(1, taskList.size());
        System.assertEquals(600, taskList[0].Bonus__c);
    }

}