// 4.    Create a scheduled process that runs every last day of the moth at 11 pm:
// 4.1    Create task for “Best doctor” with congrats text “Congratulations! You are the best doctor of the month and will receive the bonus!” and populate Bonus field [“Payments for getting bonus” (from doctor field) * “Bonus rate” (from metadata settings)]
// 4.2    Clear “Payments amount” and uncheck “Best doctor of the month” for all Doctor objects
public with sharing class GreetingNotification implements Schedulable{
    public void scheduleProcess(){
        String cronExpression = '0 0 0 L * ?'; 
        System.schedule('GreetingNotification Job', cronExpression, this);
    }

    public void execute(SchedulableContext context){
        notification();
    }

    public static void notification(){
        List<Contact> bestDoctorsOfMonthList = [SELECT Id, Best_doctor_of_the_month__c, Email, Payments_amount__c, AccountId, Account.Department__c, Account.Department_type__c, Account.Doctor_payments_to_receive_bonus__c
                                                FROM Contact
                                                WHERE Best_doctor_of_the_month__c = TRUE];

        List<String> doctorsEmailsList = new List<String>();

        List<Department_Type_Department__mdt> departmentMetadata = Department_Type_Department__mdt.getAll().values();

        List<Task> bonusPaymentsTask = new List<Task>();

        for (Contact doctor_i : bestDoctorsOfMonthList){
            List<Department_Type_Department__mdt> doctorsDepartmentMetadataList = [SELECT Department__r.Label, Department__r.Bonus_amount__c, Department_Type__r.Label, Department_Type__r.Bonus_rate__c
                                                                                   FROM Department_Type_Department__mdt
                                                                                   WHERE Department__r.Label = :doctor_i.Account.Department__c AND Department_Type__r.Label = :doctor_i.Account.Department_type__c];
            if (!doctorsDepartmentMetadataList.isEmpty()){
                Decimal bonus = doctor_i.Account.Doctor_payments_to_receive_bonus__c * doctorsDepartmentMetadataList[0].Department_Type__r.Bonus_rate__c;
                bonusPaymentsTask.add(new Task(WhoId = doctor_i.Id, WhatId = doctor_i.AccountId, Subject = 'Assign bonus', Bonus__c = bonus));
            }
            if (doctor_i.Email != null){
                doctorsEmailsList.add(doctor_i.Email);
            }

        }
        sendGreetingMessage(doctorsEmailsList);


        Database.SaveResult[] results = Database.insert (bonusPaymentsTask, true);

        ClearAllDoctorsFieldBatch batch = new ClearAllDoctorsFieldBatch();
        Id batchId = Database.executeBatch(batch);
    }

    @future(callout = true)
    public static void sendGreetingMessage(List<String> emailAddresses){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(emailAddresses);
        email.setSubject('Best doctor');
        email.setHtmlBody('Congratulations! You are the best doctor of the month and will receive the bonus!');

        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });

        for (Messaging.SendEmailResult result : results){
            if (result.isSuccess()){
                System.debug('Email sent successfully');
            } else{
                System.debug('Error sending email: ' + result.getErrors()[0].getMessage());
            }
        }
    }

}