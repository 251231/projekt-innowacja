public class MedicalAppointmentTriggers extends TriggerHandler
{
    private static final String SPECIALIZATION = 'Internist';
    private static final String ONLINE_RT = 'Online';
    
    public override void beforeInsert(List<SObject> newList)
    {
        validateFirstInternistVisit((List<Medical_Appointment__c>) newList, null);
        validateInsurance((List<Medical_Appointment__c>) newList, null);
    }
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) 
    {
        validateFirstInternistVisit((List<Medical_Appointment__c>) newList,(Map<Id, Medical_Appointment__c>) oldMap);
        validateInsurance((List<Medical_Appointment__c>) newList,(Map<Id, Medical_Appointment__c>) oldMap);
    }
    
    private static void validateFirstInternistVisit(List<Medical_Appointment__c> appointments, Map<Id, Medical_Appointment__c> oldMap)
    {
        Set<Id> patientsIdsToCheck = new Set<Id>();
        Set<Id> doctorIdsToCheck = new Set<Id>();
        
        Id onlineRecordTypeId;
        
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Medical_Appointment__c.getRecordTypeInfosByDeveloperName();
        if(rtMap.containsKey(ONLINE_RT)) 
        {
            onlineRecordTypeId = rtMap.get(ONLINE_RT).getRecordTypeId();
        }  
        else
        {
            return;
        }
        for(Medical_Appointment__c appointment : appointments)
        {
            if(oldMap != null && oldMap.containsKey(appointment.Id))
            {
                Medical_Appointment__c oldAppointment = oldMap.get(appointment.Id);
                
                if(oldAppointment.Patient__c == appointment.Patient__c &&
                   oldAppointment.Doctor__c == appointment.Doctor__c &&
                   oldAppointment.RecordTypeId == appointment.RecordTypeId)
                {
                    continue;
                }
            }
            
            if(appointment.RecordTypeId == onlineRecordTypeId)
            {
                patientsIdsToCheck.add(appointment.Patient__c);
                doctorIdsToCheck.add(appointment.Doctor__c);
            }
        }
        
        if (patientsIdsToCheck.isEmpty() || doctorIdsToCheck.isEmpty()) return;
        
        
        
        Map<Id, Integer> internistVisitCountByPatient = new Map<Id, Integer>();
        
        for (AggregateResult counter:
             [ SELECT Patient__c patientId, COUNT(Id) visitCount
              FROM Medical_Appointment__c 
              WHERE Patient__c IN :patientsIdsToCheck
              AND Doctor__r.Speciazlization__c = :SPECIALIZATION
              AND RecordTypeId != :onlineRecordTypeId
              GROUP BY Patient__c
            
             ])
        {
            Id pid = (Id) counter.get('patientId');
            Integer cnt = (Integer) counter.get('visitCount');
            internistVisitCountByPatient.put(pid, cnt);
        }
        
        Map<Id, Person__c> docMap = new Map<Id, Person__c>
            (
                [SELECT Id, Speciazlization__c FROM Person__c WHERE Id IN :doctorIdsToCheck]
            );
        
        
        for(Medical_Appointment__c appointment : appointments)
        {
            if(appointment.RecordTypeId == onlineRecordTypeId)
            {
                Person__c doc = docMap.get(appointment.Doctor__c);
                if(doc.Speciazlization__c == SPECIALIZATION)
                {
                    List<Medical_Appointment__c> onsiteVisits = [
                        SELECT Appointment_DateTime__c
                        FROM Medical_Appointment__c
                        WHERE Patient__c = :appointment.Patient__c
                          AND Doctor__r.Speciazlization__c = :SPECIALIZATION
                          AND RecordTypeId != :onlineRecordTypeId
                        ORDER BY Appointment_DateTime__c ASC
                        LIMIT 1
                	];
                    
                	Integer visitCount = internistVisitCountByPatient.get(appointment.Patient__c);
                    if(onsiteVisits.isEmpty() || visitCount == 0 || visitCount == null || appointment.Appointment_DateTime__c < onsiteVisits[0].Appointment_DateTime__c)
                    {
                        appointment.addError('Pierwsza wizyta u internisty musi być stacjonarnie');
                    }    
                }
            }
        }
    }
    public static void validateInsurance(List<Medical_Appointment__c> appointments, Map<Id,Medical_Appointment__c> oldMap){
        Set<Id> patientIds = new Set<Id>();
        Set<Id> facilityIds = new Set<Id>();
        List<Medical_Appointment__c> appointmentsToCheck = new List<Medical_Appointment__c>();
        for(Medical_Appointment__c ma : appointments) {
            if (oldMap !=null) {
                Medical_Appointment__c oldma = oldMap.get(ma.Id);
                if(oldma != null || oldma.Patient__c != ma.Patient__c || oldma.Medical_facility__c != ma.Medical_facility__c || oldma.Patient__c.Status__c != ma.Patient__c.Status__c) {
                    if(ma.Patient__c !=null && ma.Medical_facility__c != null) {
                    patientIds.add(ma.Patient__c);
                    facilityIds.add(ma.Medical_facility__c);
                    appointmentsToCheck.add(ma);
                    }
                }
                
            } 
        }
        if(patientIds.isEmpty()) return;
        
        Map<Id,Medical_Facility__c> facilitiesRequiresInsurance = new Map<Id, Medical_Facility__c>([Select Id FROM Medical_Facility__c WHERE Id in :facilityIds AND Requires_insurance__c = true]);
        
        if(facilitiesRequiresInsurance.isEmpty()) return;
        
        Set<Id> insuredPatients = new Set<Id>();
       
        for(Medical_Insurance__c mi : [Select Insured_Person__c FROM Medical_Insurance__c WHERE Insured_Person__c in :patientIds AND Status__c = 'Active']) {
            insuredPatients.add(mi.Insured_Person__c);
        }
       
        for(Medical_Appointment__c ma : appointmentsToCheck) {
            if(facilitiesRequiresInsurance.containsKey(ma.Medical_Facility__c) && !insuredPatients.contains(ma.Patient__c))
            {
                ma.addError('Wybrana placówka wymaga ubezpieczenia, a Pacjent go nie posiada.');
            }
        }
    }
}