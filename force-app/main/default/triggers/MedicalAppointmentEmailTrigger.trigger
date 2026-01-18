trigger MedicalAppointmentEmailTrigger on Medical_Appointment__c (after insert, after update) {
    //new EmailNotificationTriggerHandler().run();
}