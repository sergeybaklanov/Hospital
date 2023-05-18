trigger ReceiptTrigger on Receipt__c (after insert){
    ReceiptTriggerHandler handler = new ReceiptTriggerHandler();
    handler.run();
}