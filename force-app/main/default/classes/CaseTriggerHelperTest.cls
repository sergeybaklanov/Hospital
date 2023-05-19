@isTest
public with sharing class CaseTriggerHelperTest{
    @IsTest
    static void checkHospitalDepartmentTest(){

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
        patientList[0].Birthday_date__c = Date.newInstance(2008, 9, 25);
        patientList[0].First_Name__c = 'Young';
        patientList[1].Birthday_date__c = Date.newInstance(2000, 10, 13);
        patientList[1].First_Name__c = 'Old';
        insert patientList;

        List<InsuranceCompany__c> insuranceCompanyList = TestDataFactory.createInsuranceCompanyList(1, true);

        List<Insurance__c> insuranceAdultList = TestDataFactory.createInsuranceList(1, 299, insuranceCompanyList, new List<Patient__c>{ patientList[1] }, false);
        insuranceAdultList[0].Covered_departments__c = 'Reception;Therapy;Gastroenterology;Surgery;Psychiatric';
        insuranceAdultList[0].Department_type__c = 'Adult';
        insert insuranceAdultList;

        List<Insurance__c> insuranceChildrenList = TestDataFactory.createInsuranceList(1, 299, insuranceCompanyList, new List<Patient__c>{ patientList[0] }, false);
        insuranceChildrenList[0].Covered_departments__c = 'Reception;Therapy;Gastroenterology;Surgery';
        insuranceChildrenList[0].Department_type__c = 'Children';
        insert insuranceChildrenList;

        List<Case> treatmentList = new List<Case>();
        for (Integer i = 0; i < 4; i++){
            treatmentList.add(new Case());
        }
        treatmentList[0].Patient__c = patientList[0].Id;
        treatmentList[0].Insurance__c = insuranceChildrenList[0].Id;
        treatmentList[0].AccountId = hospitalDepartmentList[0].Id;
        treatmentList[1].Patient__c = patientList[0].Id;
        treatmentList[1].Insurance__c = insuranceChildrenList[0].Id;
        treatmentList[1].AccountId = hospitalDepartmentList[1].Id;
        treatmentList[2].Patient__c = patientList[1].Id;
        treatmentList[2].Insurance__c = insuranceAdultList[0].Id;
        treatmentList[2].AccountId = hospitalDepartmentList[0].Id;
        treatmentList[3].Patient__c = patientList[1].Id;
        treatmentList[3].Insurance__c = insuranceAdultList[0].Id;
        treatmentList[3].AccountId = hospitalDepartmentList[2].Id;

        Test.startTest();
        List<Database.SaveResult> insertResults = Database.insert (treatmentList, false);
        Test.stopTest();

        String errorMessage = 'Check Hospital department – patient age is not matched with department type!';

        Assert.isTrue(insertResults[0].isSuccess(), 'Record was not inserted');

        Assert.isFalse(insertResults[1].isSuccess(), 'Record should not be inserted');
        Assert.areEqual(errorMessage, insertResults[1].getErrors()[0].getMessage(), 'Different error message');

        Assert.isFalse(insertResults[2].isSuccess(), 'Record should not be inserted');
        Assert.areEqual(errorMessage, insertResults[2].getErrors()[0].getMessage(), 'Different error message');

        Assert.isTrue(insertResults[3].isSuccess(), 'Record was not inserted');
    }

    @IsTest
    private static void validatePopulatedInsurance(){
        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<Account> hospitalList = TestDataFactory.createHospitalsList(1, true);

        List<Account> departmentList = TestDataFactory.createHospitalsDepartmentList(2, hospitalList, false);
        departmentList[0].Department__c = 'Therapy';
        departmentList[0].Department_type__c = 'Adult';
        departmentList[1].Department__c = 'Surgery';
        departmentList[1].Department_type__c = 'Adult';
        insert departmentList;

        List<Patient__c> patientList = TestDataFactory.createPatientList(1, hospitalList, false);
        patientList[0].Birthday_date__c = Date.valueOf('1990-10-25');
        insert patientList;

        List<InsuranceCompany__c> insuranceCompanyList = TestDataFactory.createInsuranceCompanyList(1, true);

        List<Insurance__c> insuranceList = TestDataFactory.createInsuranceList(1, 100, insuranceCompanyList, patientList, false);
        insuranceList[0].Covered_departments__c = 'Surgery;Psychiatric';
        insuranceList[0].Department_type__c = 'Adult';
        insert insuranceList;

        List<Case> treatmentList = new List<Case>();
        treatmentList.add(new Case(Patient__c = patientList[0].Id, AccountId = departmentList[0].Id, Insurance__c = insuranceList[0].Id));
        treatmentList.add(new Case(Patient__c = patientList[0].Id, AccountId = departmentList[1].Id, Insurance__c = insuranceList[0].Id));

        Test.startTest();
        List<Database.SaveResult> insertResults = Database.insert (treatmentList, false);
        Test.stopTest();

        String errorMessage = 'Insurance not covered this department or department type';
        
        Assert.isFalse(insertResults[0].isSuccess(), 'Record should not be inserted');
        Assert.areEqual(errorMessage,insertResults[0].getErrors()[0].getMessage() , 'Different error message');
        
        Assert.isTrue(insertResults[1].isSuccess(), 'Record was not inserted');
    }

}