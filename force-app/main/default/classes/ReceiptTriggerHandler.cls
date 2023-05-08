// 3.    When Amount of Receipt object is changed
// 3.1    Check sum of “Amount of payments” of all Cases related to current doctor in current month– if received sum is more than “Doctor payments to receive bonus” field value from Hospital department – update field “Payments amount” on Doctor object with received value
// 3.2    Check the doctors related to the same department with populated “Payments amount” field and set the flag “Best doctor of the month” on object with the higher value. NOTE: There can be only one Best doctor for each hospital department.
public with sharing class ReceiptTriggerHandler extends TriggerHandler{
    protected override void afterInsert(){
        updateTreatmentPaymentsAmount((Map<Id, Receipt__c>)Trigger.newMap);
        updateDoctorsPaymentsAmount((Map<Id, Receipt__c>)Trigger.newMap);
    }

    private static void updateTreatmentPaymentsAmount(Map<Id, Receipt__c> newReceiptsMap){
        List<Case> treatmentsList = [SELECT Id, (SELECT Id
                                                 FROM Receipts__r
                                                 WHERE Id IN:newReceiptsMap.keySet())
                                     FROM Case ];
        List<Id> treatmentIdsList = new List<Id>();
        for (Case treatment_i : treatmentsList){
            treatmentIdsList.add(treatment_i.Id);
        }

        List<AggregateResult> treatmentReceiptsList = [SELECT SUM(Amount__c)Amount, Treatment__c TrId
                                                       FROM Receipt__c 
                                                       WHERE Treatment__c IN:treatmentIdsList
                                                       GROUP BY Treatment__c];

        List<Case> treatmentsToUpdateList = new List<Case>();
        for (AggregateResult treatment_i : treatmentReceiptsList){
            treatmentsToUpdateList.add(new Case(Id = (Id) treatment_i.get('TrId'), Amount_of_payments__c = (Decimal) treatment_i.get('Amount')));
        }
        List<Database.SaveResult> updateResults = Database.update (treatmentsToUpdateList, true);
    }

    private static void updateDoctorsPaymentsAmount(Map<Id, Receipt__c> newReceiptsMap){

        List<Id> listCasesIdsFromReceipts = new List<Id>();
        for (Receipt__c receipt_i : newReceiptsMap.values()){
            {
                listCasesIdsFromReceipts.add(receipt_i.Treatment__c);
            }
        }
        List<Contact> doctorsList = [SELECT Id, AccountId, Account.Department__c, Payments_amount__c, Account.Doctor_payments_to_receive_bonus__c, (SELECT Id, Amount_of_payments__c
                                                                                                                                                    FROM Cases
                                                                                                                                                    WHERE Id IN:listCasesIdsFromReceipts)
                                     FROM Contact ];

        Map<Id, Contact> doctorsMap = new Map<Id, Contact>();
        List<Id> doctorsDepartmentsIdsList = new List<Id>();

        for (Contact contact_i : doctorsList){
            doctorsMap.put(contact_i.Id, contact_i);
            doctorsDepartmentsIdsList.add(contact_i.AccountId);
        }

        List<Case> cases = [SELECT Id, ContactId, Amount_of_payments__c
                            FROM Case];
        List<AggregateResult> allDoctorsTreatmentsList = [SELECT SUM(Amount_of_payments__c)amount, ContactId ctId
                                                          FROM Case 
                                                          WHERE ContactId IN:doctorsMap.keySet() AND CreatedDate = THIS_MONTH
                                                          GROUP BY ContactId];

        List<Contact> doctorIdsToUpdateList = new List<Contact>();
        //3.1

        for (AggregateResult result_i : allDoctorsTreatmentsList){



            if (doctorsMap.get((Id) result_i.get('ctId')).Account.Doctor_payments_to_receive_bonus__c < (Decimal) result_i.get('amount')){
                doctorIdsToUpdateList.add(new Contact(Id = (Id) result_i.get('ctId'), Payments_amount__c = (Decimal) result_i.get('amount')));
            }
        }
        List<Database.SaveResult> updateResults = Database.update (doctorIdsToUpdateList, true);

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
                                                          FROM Contacts
                                                          ORDER BY Payments_amount__c DESC)
                                        FROM Account 
                                        WHERE Id IN:doctorsDepartmentsIdsList];

        Map<Id, Contact> doctorsToUpdateMap = new Map<Id, Contact>();

        for (Account department_i : departmentList){
            Id doctorIdWithHighestPayments = department_i.Contacts[0].Id;
            Decimal highestAmount =department_i.Contacts[0].Payments_amount__c;
            for (Contact contact_i : department_i.Contacts){
                doctorsToUpdateMap.put(contact_i.Id, (new Contact(Id = contact_i.Id, Best_doctor_of_the_month__c = false)));
            }
            System.debug('Department ' + department_i.Name + ' has highest payment of ' + highestAmount + ' made by doctor ' + doctorIdWithHighestPayments);
            doctorsToUpdateMap.get(doctorIdWithHighestPayments).Best_doctor_of_the_month__c = true;
        }
        System.debug('Update doctors values: ' + doctorsToUpdateMap.values());
        update doctorsToUpdateMap.values();
    }

}