// 3.    When Amount of Receipt object is changed
// 3.1    Check sum of “Amount of payments” of all Cases related to current doctor in current month– if received sum is more than “Doctor payments to receive bonus” field value from Hospital department – update field “Payments amount” on Doctor object with received value
// 3.2    Check the doctors related to the same department with populated “Payments amount” field and set the flag “Best doctor of the month” on object with the higher value. NOTE: There can be only one Best doctor for each hospital department.
//9.    When Receipt is saved – update Insurance Covered amount (must be sum of all receipts of current month). Balance field on Insurance must be only positive and if it becomes negative – don’t save the Receipt and show Error message – “Insurance have not enough amount for coverage – chose another one or clear this field.”
public with sharing class ReceiptTriggerHandler extends TriggerHandler{
    protected override void beforeInsert(){
        updateInsuranceCoveredAmount((List<Receipt__c>)Trigger.new );
    }

    protected override void afterInsert(){
        updateTreatmentPaymentsAmount((Map<Id, Receipt__c>)Trigger.newMap);
        updateDoctorsPaymentsAmount((Map<Id, Receipt__c>)Trigger.newMap);
    }

    private static void updateInsuranceCoveredAmount(List<Receipt__c> newReceiptsList){

        Set<Id> insuranceIdsSet = new Set<Id>();
        for (Receipt__c receipt_i : newReceiptsList){

            insuranceIdsSet.add(receipt_i.Insurance__c);
        }
        //Alternative variant
        // List<AggregateResult> sumOfExistReceiptsToInsuranceList = [SELECT SUM(Amount__c)sumAmount, Insurance__c insId
        //                                                            FROM Receipt__c
        //                                                            WHERE Insurance__c  IN:insuranceIdsSet AND CreatedDate = THIS_MONTH
        //                                                            GROUP BY Insurance__c ];


        // Map<Id,Decimal> insuranceIdCoveredAmountMap = new Map<Id,Decimal> ();

        // for (AggregateResult result_i : sumOfExistReceiptsToInsuranceList){
        //     insuranceIdCoveredAmountMap.put((Id)result_i.get('insId'), (Decimal)result_i.get('sumAmount'));
        // }

        List<Insurance__c> insuranceList = [SELECT Id, Amount__c, (SELECT Amount__c
                                                                   FROM Receipts__r
                                                                   WHERE CreatedDate = THIS_MONTH)
                                            FROM Insurance__c 
                                            WHERE Id IN:insuranceIdsSet];

        Map<Id, Decimal> insuranceIdAmountBalanceMap = new Map<Id, Decimal>();
        for (Insurance__c insurance_i : insuranceList){
            Decimal sumExistAmount = 0;
            for (Receipt__c receipt_i : insurance_i.Receipts__r){
                sumExistAmount += receipt_i.Amount__c;
            }
            insuranceIdAmountBalanceMap.put(insurance_i.Id, (insurance_i.Amount__c - sumExistAmount));
        }

        for (Receipt__c receipt_i : newReceiptsList){
            if ((insuranceIdAmountBalanceMap.get(receipt_i.Insurance__c) - receipt_i.Amount__c) < 0){
                receipt_i.Insurance__c.addError('Insurance have not enough amount for coverage – chose another one or clear this field.');
            }
        }
    }

    private static void updateTreatmentPaymentsAmount(Map<Id, Receipt__c> newReceiptsMap){
        List<Case> treatmentsList = [SELECT Id, (SELECT Id
                                                 FROM Receipts__r
                                                 WHERE Id IN:newReceiptsMap.keySet())
                                     FROM Case ];

        Map<Id, Case> treatmentMap = new Map<Id, Case>(treatmentsList);

        List<AggregateResult> treatmentReceiptsList = [SELECT SUM(Amount__c)Amount, Treatment__c TrId
                                                       FROM Receipt__c 
                                                       WHERE Treatment__c IN:treatmentMap.keySet()
                                                       GROUP BY Treatment__c];

        List<Case> treatmentsToUpdateList = new List<Case>();
        for (AggregateResult treatment_i : treatmentReceiptsList){
            treatmentsToUpdateList.add(new Case(Id = (Id) treatment_i.get('TrId'), Amount_of_payments__c = (Decimal) treatment_i.get('Amount')));
        }
        List<Database.SaveResult> updateResults = Database.update (treatmentsToUpdateList, true);
        dmlStatusNotification(updateResults);
    }

    private static void updateDoctorsPaymentsAmount(Map<Id, Receipt__c> newReceiptsMap){

        List<Id> listCasesIdsFromReceipts = new List<Id>();
        for (Receipt__c receipt_i : newReceiptsMap.values()){
            {
                listCasesIdsFromReceipts.add(receipt_i.Treatment__c);
            }
        }

        List<Case> treatmentList = [SELECT Id, Contact.Id, AccountId, Account.Doctor_payments_to_receive_bonus__c
                                    FROM Case
                                    WHERE ID IN:listCasesIdsFromReceipts];

        Map<Id, Decimal> doctorIdVsPaymentsToReceiveBonusMap = new Map<Id, Decimal>();
        List<Id> doctorsDepartmentsIdsList = new List<Id>();

        for (Case case_i : treatmentList){
            doctorIdVsPaymentsToReceiveBonusMap.put(case_i.Contact.Id, case_i.Account.Doctor_payments_to_receive_bonus__c);
            doctorsDepartmentsIdsList.add(case_i.AccountId);
        }
        List<AggregateResult> allDoctorsTreatmentsList = [SELECT SUM(Amount_of_payments__c)amount, ContactId ctId
                                                          FROM Case 
                                                          WHERE ContactId IN:doctorIdVsPaymentsToReceiveBonusMap.keySet() AND CreatedDate = THIS_MONTH
                                                          GROUP BY ContactId];

        List<Contact> doctorIdsToUpdateList = new List<Contact>();
        //3.1

        for (AggregateResult result_i : allDoctorsTreatmentsList){

            if (doctorIdVsPaymentsToReceiveBonusMap.get((Id) result_i.get('ctId')) < (Decimal) result_i.get('amount')){
                doctorIdsToUpdateList.add(new Contact(Id = (Id) result_i.get('ctId'), Payments_amount__c = (Decimal) result_i.get('amount'), Best_doctor_of_the_month__c = true));
            }
        }

        List<Database.SaveResult> updateResults = Database.update (doctorIdsToUpdateList, true);
        dmlStatusNotification(updateResults);
        //3.2
        List<Account> departmentsList = [SELECT Id, (SELECT Id, Payments_amount__c, Best_doctor_of_the_month__c
                                                     FROM Contacts
                                                     WHERE Best_doctor_of_the_month__c = true
                                                     ORDER BY Payments_amount__c DESC)
                                         FROM Account 
                                         WHERE Id IN:doctorsDepartmentsIdsList];

        List<Contact> finalDoctorsUpdateList = new List<Contact>();

        for (Account department_i : departmentsList){
            for (Integer i = 1; i < department_i.Contacts.size(); i++){
                department_i.Contacts[i].Best_doctor_of_the_month__c = false;
                finalDoctorsUpdateList.add(department_i.Contacts[i]);
            }
        }

        updateResults = Database.update (finalDoctorsUpdateList, true);
        dmlStatusNotification(updateResults);
    }

    private static void dmlStatusNotification(List<Database.SaveResult> results){
        for (Database.SaveResult result_i : results){
            if (result_i.isSuccess()){
                System.debug('Successfully published event.');
            } else{
                for (Database.Error error : result_i.getErrors()){
                    System.debug(error.getMessage());
                    System.debug(error.getStatusCode());
                }
            }
        }
    }

}