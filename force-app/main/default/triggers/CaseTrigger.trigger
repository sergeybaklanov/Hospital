trigger CaseTrigger on Case (before insert, after insert){
    CaseTriggerHelper helper = new CaseTriggerHelper();
    helper.run();
}