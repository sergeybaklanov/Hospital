//7.    When Case is saved, create a validation for populated Hospital department – check Department type based on patient age and if the Hospital department is not valid – don’t save record and show error message “Check Hospital department – patient age is not matched with department type!”
// 8.    When Case is saved validate populated insurance – check that filled insurance can cover this case (based on Insurance Covered departments field)
public with sharing class CaseTriggerHelper extends TriggerHandler{
    protected override void beforeInsert(){
        checkHospitalDepartment((List<Case>)Trigger.new );
        validatePopulatedInsurance(Trigger.new );
    }

    private static void checkHospitalDepartment(List<Case> newTreatmentList){
        Set<Id> patientIdSet = new Set<Id>();
        Set<Id> hospitalDepartmentSet = new Set<Id>();

        for (Case treatment_i : newTreatmentList){
            patientIdSet.add(treatment_i.Patient__c);
            hospitalDepartmentSet.add(treatment_i.AccountId);
        }

        Map<Id, Patient__c> patientMap = new Map<Id, Patient__c>([SELECT Id, Age__c
                                                                  FROM Patient__c
                                                                  WHERE Id IN:patientIdSet]);

        Map<Id, Account> departmentMap = new Map<Id, Account>([SELECT Id, Department__c, Department_type__c
                                                               FROM Account
                                                               WHERE Id IN:hospitalDepartmentSet]);

        for (Case treatment_i : newTreatmentList){
            Patient__c patient = patientMap.get(treatment_i.Patient__c);
            Account department = departmentMap.get(treatment_i.AccountId);

            Boolean isPatientUnderage = patient.Age__c < 18;
            Boolean isAdultDepartment = department.Department_type__c == 'Adult' || department.Department__c == 'Psychiatric';
            Boolean isChildrenDepartment = department.Department_type__c == 'Children';

            if ((isPatientUnderage && isAdultDepartment) || (!isPatientUnderage && isChildrenDepartment)){
                treatment_i.AccountId.addError('Check Hospital department – patient age is not matched with department type!');
            }
        }
    }

    private static void validatePopulatedInsurance(List<Case> newTreatmentList){
        Set<Id> insuranceIdsSet = new Set<Id>();
        Set<Id> hospitalDepartmentSet = new Set<Id>();
        for (Case treatment_i : newTreatmentList){
            insuranceIdsSet.add(treatment_i.Insurance__c);
            hospitalDepartmentSet.add(treatment_i.AccountId);
        }
        Map<Id, Insurance__c> insuranceMap = new Map<Id, Insurance__c>([SELECT Id, Covered_departments__c, Department_type__c
                                                                        FROM Insurance__c
                                                                        WHERE Id IN:insuranceIdsSet]);

        List<Account> hospitalDepartmentsList = [SELECT Id, Department__c, Department_type__c
                                                 FROM Account
                                                 WHERE Id IN:hospitalDepartmentSet];
        Map<Id, Account> departmentMap = new Map<Id, Account>(hospitalDepartmentsList);
        for (Case treatment_i : newTreatmentList){
            if (!insuranceMap.get(treatment_i.Insurance__c).Covered_departments__c.contains(departmentMap.get(treatment_i.AccountId).Department__c) || insuranceMap.get(treatment_i.Insurance__c).Department_type__c != departmentMap.get(treatment_i.AccountId).Department_type__c){
                treatment_i.Insurance__c.addError('Insurance not covered this department or department type');
            }
        }
    }

}