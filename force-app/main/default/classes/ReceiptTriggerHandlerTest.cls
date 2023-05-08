@IsTest
public with sharing class ReceiptTriggerHandlerTest{
    @TestSetup
    static void makeData(){
        List<Account> hospitals = TestDataFactory.createHospitalsList(1, true);
        List<Account> departments = TestDataFactory.createHospitalsDepartmentList(1, hospitals, false);
        for (Account department_i : departments){
            department_i.Doctor_payments_to_receive_bonus__c = 100;
        }
        insert departments;

        List<Contact> doctors = TestDataFactory.createDoctorsList(1, departments, true);
        List<InsuranceCompany__c> insuranceCompanies = TestDataFactory.createInsurenceCompanyList(1, true);
        List<Patient__c> patients = TestDataFactory.createPatientList(1, hospitals, true);
        List<Insurance__c> insurance = TestDataFactory.createInsuranceList(1, 150, insuranceCompanies, patients, true);
        List<Case> treatments = TestDataFactory.createTreatmentList(1, departments, doctors, patients, insurance, true);
    }

    @isTest
    static void testUpdateDoctorsPaymentsAmount(){
        List<Case> treatments = [SELECT Id, ContactId, Patient__c, Insurance__c, AccountId
                                 FROM Case];
        List<Patient__c> patients = [SELECT Id
                                     FROM Patient__c];
        List<Insurance__c> insurance = [SELECT Id
                                        FROM Insurance__c];
        List<Receipt__c> receipts = TestDataFactory.createReceiptsList(5, treatments, patients, insurance, false);
        for (Receipt__c receipt_i : receipts){
            receipt_i.Amount__c = 100;
        }

        Test.startTest();
        insert receipts;
        Test.stopTest();

        for (Contact doctor : [SELECT Payments_amount__c, Best_doctor_of_the_month__c
                               FROM Contact]){
            System.assertEquals(500.0, doctor.Payments_amount__c);
            System.assertEquals(true, doctor.Best_doctor_of_the_month__c);
        }
    }

}