public with sharing class DoctorTriggerHandler extends TriggerHandler{
    protected override void beforeInsert(){
        populateFieldPaymentsAmount((List<Contact>)Trigger.new );
    }

    protected override void beforeUpdate(){
        preventEmptyFieldUpdate((Map<Id, Contact>)Trigger.oldMap, (List<Contact>)Trigger.new);
    }

    private static void populateFieldPaymentsAmount(List<Contact> newDoctorsList){

        for (Contact doctor_i : newDoctorsList){
            if (doctor_i.Payments_amount__c == null){
                doctor_i.Payments_amount__c = 0;
            }
        }
    }

    private static void preventEmptyFieldUpdate(Map<Id, Contact> oldDoctorsMap, List<Contact> newDoctorsList){
        for (Contact doctor_i : newDoctorsList){
            if (oldDoctorsMap.get(doctor_i.Id).Payments_amount__c != doctor_i.Payments_amount__c && doctor_i.Payments_amount__c==null){
                doctor_i.Payments_amount__c.addError('Field Payments_amount__c couldn\'t be empty');
            }
        }
    }
}