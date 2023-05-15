@isTest
public with sharing class CaseTriggerHelperTest{
    @IsTest
    static void caseInsertTest(){

        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<Account> hospitalList = TestDataFactory.createHospitalsList(1, true);
        List<Account> hospitalDepartmentList = TestDataFactory.createHospitalsDepartmentList(3, hospitalList, false);
        hospitalDepartmentList[0].Department_type__c = 'Children';
        hospitalDepartmentList[0].Department__c = 'Surgery';
        hospitalDepartmentList[1].Department_type__c = 'Adult';
        hospitalDepartmentList[1].Department__c = 'Psychiatric';
        hospitalDepartmentList[2].Department_type__c = 'Adult';
        hospitalDepartmentList[2].Department__c = 'Therapy';
        insert hospitalDepartmentList;
        List<Patient__c> patientList = TestDataFactory.createPatientList(2, hospitalList, false);
        patientList[0].Birthday_date__c = Date.valueOf('2008-9-25');
        patientList[0].First_Name__c = 'Young';
        patientList[1].Birthday_date__c = Date.valueOf('2000-10-13');
        patientList[1].First_Name__c = 'Old';
        insert patientList;

        List<Case> treatmentList = new List<Case>();
        for (Integer i = 0; i < 4; i++){
            treatmentList.add(new Case());

        }
        treatmentList[0].Patient__c = patientList[0].Id;
        treatmentList[0].AccountId = hospitalDepartmentList[0].Id;
        treatmentList[1].Patient__c = patientList[0].Id;
        treatmentList[1].AccountId = hospitalDepartmentList[1].Id;
        treatmentList[2].Patient__c = patientList[1].Id;
        treatmentList[2].AccountId = hospitalDepartmentList[0].Id;
        treatmentList[3].Patient__c = patientList[1].Id;
        treatmentList[3].AccountId = hospitalDepartmentList[2].Id;
        System.debug('treatmentList: ' + treatmentList);
        Test.startTest();
        List<Database.SaveResult> insertResults = Database.insert (treatmentList, false);
        Test.stopTest();
        System.debug('Case trigger helper test !!!!!!!!!!!!!!');

        System.assertEquals(insertResults[0].isSuccess(), true);
        System.assertEquals(insertResults[1].isSuccess(), false);
        System.assertEquals(insertResults[1].getErrors()[0].getMessage(), 'Check Hospital department – patient age is not matched with department type!');
        System.assertEquals(insertResults[2].isSuccess(), false);
        System.assertEquals(insertResults[2].getErrors()[0].getMessage(), 'Check Hospital department – patient age is not matched with department type!');
        System.assertEquals(insertResults[3].isSuccess(), true);
    }

}