public with sharing class ClearAllDoctorsFieldBatch implements Database.Batchable<SObject>, Database.Stateful{
    private static Integer recordsProcessed = 0;
    public Database.QueryLocator start (Database.BatchableContext context){
    return Database.getQueryLocator('SELECT Id, Best_doctor_of_the_month__c, Payments_amount__c FROM Contact WHERE Payments_amount__c != 0');
    }
    public void execute(Database.BatchableContext context, List<Contact> doctorsList){
        System.debug('doctorsList: ' + doctorsList);
        List<Contact> doctorsToUpdateList = new List<Contact> ();
        for (Contact doctor_i : doctorsList) {
            doctorsToUpdateList.add(new Contact(Id=doctor_i.Id, Best_doctor_of_the_month__c=false, Payments_amount__c=0.0));
            recordsProcessed++;
        }
        Database.update(doctorsToUpdateList, true);
    }

    public void finish(Database.BatchableContext context){
        System.debug('recordsProcessed: ' + recordsProcessed);
        AsyncApexJob job = [SELECT  Status, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob WHERE Id =:context.getJobId()];
        System.debug('job inside class: ' + job);
        sendEmail(job, recordsProcessed);
    }

    public static void sendEmail (AsyncApexJob job, Integer recordsProcessed){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        Email_Notification_Address__c customSettings = Email_Notification_Address__c.getInstance();
        System.debug(customSettings.Email__c);
    
        message.setToAddresses(new List<String>{customSettings.Email__c});
        message.setSubject('Batch ClearAllDoctorsFieldBatch status');
        message.setHtmlBody('Status: '+job.Status+' Number of errors: '+job.NumberOfErrors+' JobItemsProcessed: '+job.JobItemsProcessed);

        Messaging.sendEmail(new Messaging.SingleEmailMessage []{message},false);
    }
}