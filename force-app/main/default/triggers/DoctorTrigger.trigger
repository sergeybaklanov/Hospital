trigger DoctorTrigger on Contact (before insert, before update) {
    DoctorTriggerHandler handler = new DoctorTriggerHandler();
    handler.run();
}