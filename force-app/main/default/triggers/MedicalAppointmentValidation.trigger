trigger MedicalAppointmentValidation on Medical_Appointment__c (
    before insert, before update
) {
    new MedicalAppointmentTriggerHandler().run();
}