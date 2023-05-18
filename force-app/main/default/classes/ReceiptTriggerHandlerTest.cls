@IsTest
public with sharing class ReceiptTriggerHandlerTest{
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<Account> hospitals = TestDataFactory.createHospitalsList(1, true);
        List<Account> departments = TestDataFactory.createHospitalsDepartmentList(1, hospitals, false);
        for (Account department_i : departments){
            department_i.Doctor_payments_to_receive_bonus__c = 100;
            department_i.Department__c = 'Gastroenterology';
            department_i.Department_type__c = 'Adult';
        }
        insert departments;

        List<Contact> doctors = TestDataFactory.createDoctorsList(1, departments, true);
        List<InsuranceCompany__c> insuranceCompanies = TestDataFactory.createInsuranceCompanyList(1, true);
        List<Patient__c> patients = TestDataFactory.createPatientList(1, hospitals, true);
        List<Insurance__c> insurance = TestDataFactory.createInsuranceList(1, 150, insuranceCompanies, patients, false);
        insurance[0].Covered_departments__c = 'Reception;Therapy;Gastroenterology;Surgery;Psychiatric';
        insurance[0].Department_type__c = 'Adult';
        insert insurance;

        List<Case> treatments = TestDataFactory.createTreatmentList(1, departments, doctors, patients, insurance, true);
    }

    @IsTest
    static void updateInsuranceCoveredAmountTest(){

        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
        List<InsuranceCompany__c> insuranceCompanyList = [SELECT Id
                                                          FROM InsuranceCompany__c
                                                          LIMIT 1];
        List<Patient__c> patientList = [SELECT Id
                                        FROM Patient__c
                                        LIMIT 1];
        List<Insurance__c> insuranceList = TestDataFactory.createInsuranceList(1, 1000, insuranceCompanyList, patientList, false);
        insuranceList[0].Covered_departments__c = 'Reception;Therapy;Gastroenterology;Surgery;Psychiatric';
        insuranceList[0].Department_type__c = 'Adult';
        insert insuranceList;


        List<Insurance__c> insDBList = [SELECT Id, Covered_departments__c, Department_type__c, Amount__c, Covered_Amount__c
                                        FROM Insurance__c];

        List<Contact> doctorsList = [SELECT Id
                                     FROM Contact
                                     LIMIT 1];
        List<Account> hospitalDepartmentList = [SELECT Id
                                                FROM Account
                                                LIMIT 1];
        hospitalDepartmentList[0].Department__c = 'Gastroenterology';
        hospitalDepartmentList[0].Department_type__c = 'Adult';
        update hospitalDepartmentList;

        List<Case> treatmentList = TestDataFactory.createTreatmentList(1, hospitalDepartmentList, doctorsList, patientList, insuranceList, true);

        List<Receipt__c> receiptList1 = TestDataFactory.createReceiptsList(2, treatmentList, patientList, insuranceList, false);
        receiptList1[0].Amount__c = 100;
        receiptList1[1].Amount__c = 200;

        List<Receipt__c> receiptList2 = TestDataFactory.createReceiptsList(1, treatmentList, patientList, insuranceList, false);
        receiptList2[0].Amount__c = 800;


        Test.startTest();
        List<Database.SaveResult> saveResults = Database.insert (receiptList1, false);
        for (Integer i = 0; i < saveResults.size(); i++){
            System.assertEquals(true, saveResults[i].isSuccess());
        }
        saveResults = Database.insert (receiptList2, false);
        System.assertEquals(false, saveResults[0].isSuccess());
        System.assertEquals('Insurance have not enough amount for coverage – chose another one or clear this field.', saveResults[0].getErrors()[0].getMessage());
        Test.stopTest();
    }

    @isTest
    static void testUpdateDoctorsPaymentsAmountTest(){
        Test.setMock(HttpCalloutMock.class, new EmptyCalloutMock());
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

        Contact testDoctor2 = new Contact(LastName = 'Test doctor2', Payments_amount__c = 100, AccountId = treatments[0].AccountId, Best_doctor_of_the_month__c = true);
        insert testDoctor2;

        Test.startTest();
        insert receipts;
        Test.stopTest();

        List<Contact> doctors = [SELECT AccountId, Payments_amount__c, Best_doctor_of_the_month__c
                                 FROM Contact
                                 WHERE Best_doctor_of_the_month__c = true];

        System.assert(doctors[0].Payments_amount__c == 500, 'Not expected doctors payments amount');
    }

}