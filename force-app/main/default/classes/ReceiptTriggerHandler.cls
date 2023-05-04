// 3.    When Amount of Receipt object is changed
// 3.1    Check sum of “Amount of payments” of all Cases related to current doctor in current month– if received sum is more than “Doctor payments to receive bonus” field value from Hospital department – update field “Payments amount” on Doctor object with received value
// 3.2    Check the doctors related to the same department with populated “Payments amount” field and set the flag “Best doctor of the month” on object with the higher value. NOTE: There can be only one Best doctor for each hospital department.
public with sharing class ReceiptTriggerHandler extends TriggerHandler{
    protected override void afterInsert(){
        updateDoctorsPaymentsAmount((Map<Id, Receipt__c>)Trigger.newMap);
    }

    private static void updateDoctorsPaymentsAmount(Map<Id, Receipt__c> newReceiptsMap){

        List<Id> listCasesIdsFromReceipts = new List<Id>();
        for (Receipt__c receipt_i : newReceiptsMap.values()){
            {
                listCasesIdsFromReceipts.add(receipt_i.Treatment__c);
            }
        }

        List<Contact> doctorsList = [SELECT Id, AccountId, Account.Department__c, Payments_amount__c, Account.Doctor_payments_to_receive_bonus__c, (SELECT Id
                                                                                                                                                    FROM Cases
                                                                                                                                                    WHERE Id IN:listCasesIdsFromReceipts)
                                     FROM Contact ];

        Map<Id, Contact> doctorsMap = new Map<Id, Contact>();
        List<Id> doctorsDepartmentsIdsList = new List<Id>();

        for (Contact contact_i : doctorsList){
            doctorsMap.put(contact_i.Id, contact_i);
            doctorsDepartmentsIdsList.add(contact_i.AccountId);
        }

        List<AggregateResult> allDoctorsTreatmentsList = [SELECT SUM(Amount_of_payments__c)amount, ContactId ctId
                                                          FROM Case 
                                                          WHERE ContactId IN:doctorsMap.keySet() AND CreatedDate = THIS_MONTH AND CreatedDate = THIS_YEAR
                                                          GROUP BY ContactId];

        List<Contact> doctorIdsToUpdateList = new List<Contact>();
        //3.1
        for (AggregateResult result_i : allDoctorsTreatmentsList){
            if (doctorsMap.containsKey((Id) result_i.get('ctId'))){
                if (doctorsMap.get((Id) result_i.get('ctId')).Account.Doctor_payments_to_receive_bonus__c < (Decimal) result_i.get('amount')){
                    doctorIdsToUpdateList.add(new Contact(Id = (Id) result_i.get('ctId'), Payments_amount__c = (Decimal) result_i.get('amount')));
                }

            }
        }
        List<Database.SaveResult> updateResults = Database.update (doctorIdsToUpdateList, false);

        for (Database.SaveResult result : updateResults){
            if (result.isSuccess()){
                System.debug('Successfully published event.');
            } else{
                for (Database.Error error : result.getErrors()){
                    System.debug(error.getMessage());
                    System.debug(error.getStatusCode());
                }
            }
        }

        //3.2 
        List<Account> departmentList = [SELECT Id, Name, (SELECT Id, Payments_amount__c, Best_doctor_of_the_month__c
                                                          FROM Contacts)
                                        FROM Account 
                                        WHERE Id IN:doctorsDepartmentsIdsList];
        System.debug('Departments list :' + departmentList);

            Map<Id, Contact> doctorsToUpdateMap = new Map<Id, Contact> ();
        
        for (Account department_i : departmentList) {
            Id doctorIdWithHighestPayments;
            Decimal highestAmount = 0;
            for (Contact contact_i : department_i.Contacts) {
                if (contact_i.Payments_amount__c > highestAmount) {
                    highestAmount = contact_i.Payments_amount__c;
                    doctorIdWithHighestPayments = contact_i.Id;
                }
                doctorsToUpdateMap.put(contact_i.Id,(new Contact(Id=contact_i.Id, Best_doctor_of_the_month__c=false)));
            }
            System.debug('Department ' + department_i.Name + ' has highest payment of ' + highestAmount + ' made by doctor ' + doctorIdWithHighestPayments);
            doctorsToUpdateMap.get(doctorIdWithHighestPayments).Best_doctor_of_the_month__c=true;
        }
        update doctorsToUpdateMap.values();
    }
}