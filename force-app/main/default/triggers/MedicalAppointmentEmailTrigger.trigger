trigger MedicalAppointmentEmailTrigger on Medical_Appointment__c (after insert, after update) {

    if (Trigger.isInsert) {
        //EmailNotificationTriggerHandler.sendAppointmentEmails(Trigger.new);
    }

    if (Trigger.isUpdate) {
        //EmailNotificationTriggerHandler.sendAppointmentEmails(Trigger.new);
    }
}