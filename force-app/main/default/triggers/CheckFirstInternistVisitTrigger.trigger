trigger CheckFirstInternistVisitTrigger on Medical_Appointment__c (before insert, before update) 
{
	new CheckFirstInternistVisit().run();
}