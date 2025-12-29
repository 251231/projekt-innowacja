trigger MedicalAppointmentTrigger on Medical_Appointment__c (after insert, after update) {

    
    if (Trigger.isInsert) {
        MedicalAppointmentEmailService.sendAppointmentEmails(Trigger.new);
    }

    
    if (Trigger.isUpdate) {
        MedicalAppointmentEmailService.sendAppointmentEmails(Trigger.new);
    }
}