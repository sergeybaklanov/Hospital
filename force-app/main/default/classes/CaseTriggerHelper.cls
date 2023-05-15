//7.    When Case is saved, create a validation for populated Hospital department – check Department type based on patient age and if the Hospital department is not valid – don’t save record and show error message “Check Hospital department – patient age is not matched with department type!”
// 8.	When Case is saved validate populated insurance – check that filled insurance can cover this case (based on Insurance Covered departments field)
public with sharing class CaseTriggerHelper extends TriggerHandler{
    protected override void beforeInsert(){
        checkHospitalDepartment(Trigger.new );
    }

    protected override void afterInsert(){
     
    }

    private static void checkHospitalDepartment(List<Case> newTreatmentList){
        Set<Id> patientIdSet = new Set<Id>();
        Set<Id> hospitalDepartmentSet = new Set<Id>();

        for (Case treatment : newTreatmentList){
            patientIdSet.add(treatment.Patient__c);
            hospitalDepartmentSet.add(treatment.AccountId);
        }

        Map<Id, Patient__c> patientMap = new Map<Id, Patient__c>([SELECT Id, Age__c
                                                                  FROM Patient__c
                                                                  WHERE Id IN:patientIdSet]);

        Map<Id, Account> departmentMap = new Map<Id, Account>([SELECT Id, Department__c, Department_type__c
                                                               FROM Account
                                                               WHERE Id IN:hospitalDepartmentSet]);

        for (Case treatment : newTreatmentList){
            Patient__c patient = patientMap.get(treatment.Patient__c);
            Account department = departmentMap.get(treatment.AccountId);

            Boolean isPatientUnderage = patient.Age__c < 18;
            Boolean isAdultDepartment = department.Department_type__c == 'Adult' || department.Department__c == 'Psychiatric';
            Boolean isChildrenDepartment = department.Department_type__c == 'Children';

            if ((isPatientUnderage && isAdultDepartment) || (!isPatientUnderage && isChildrenDepartment)){
                treatment.addError('Check Hospital department – patient age is not matched with department type!');
            }
        }
    }

 
}