trigger HospitalTrigger on Account (after insert) {
    HospitalTriggerHelper helper = new  HospitalTriggerHelper();
    helper.run();

}