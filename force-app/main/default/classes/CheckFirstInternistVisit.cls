public class CheckFirstInternistVisit extends TriggerHandler
{
        
    public override void beforeInsert(List<SObject> newList)
    {
        validate((List<Medical_Appointment__c>) newList, null);
    }
    public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) 
    {
        validate
            (
          	(List<Medical_Appointment__c>) newList,
            (Map<Id, Medical_Appointment__c>) oldMap
        );
    }
    
    private static void validate(List<Medical_Appointment__c> appointments,
                                 Map<Id, Medical_Appointment__c> oldMap)
    {
        Set<Id> patientsIdsToCheck = new Set<Id>();
        Set<Id> doctorIdsToCheck = new Set<Id>();
        
        Id onlineRecordTypeId;
        
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Medical_Appointment__c.getRecordTypeInfosByDeveloperName();
        if(rtMap.containsKey('Online')) 
        {
            onlineRecordTypeId = rtMap.get('Online').getRecordTypeId();
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
              AND Doctor__r.Speciazlization__c = 'Internist'
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
                if(doc.Speciazlization__c == 'Internist')
                {
                	Integer visitCount = internistVisitCountByPatient.get(appointment.Patient__c);
                    if(visitCount == 0 || visitCount == null)
                    {
                        appointment.addError('Pierwsza wizyta u internisty musi być stacjonarnie');
                    }    
                }
            }
        }
    }
}