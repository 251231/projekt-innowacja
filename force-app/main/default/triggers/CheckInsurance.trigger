trigger CheckInsurance on Medical_Appointment__c (before insert, before update) {
	new MedicalAppointmentTriggers().run();
}