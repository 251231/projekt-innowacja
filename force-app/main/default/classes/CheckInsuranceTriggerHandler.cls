public class CheckInsuranceTriggerHandler extends TriggerHandler {
    public override void beforeInsert(List<SObject> newList) {
        validate((List<Medical_Appointment__c>) newList,null);
    }
    public override void beforeUpdate(List<SObject> newList,Map<Id,SObject> oldMap){
        validate((List<Medical_Appointment__c>) newList,(Map<Id,Medical_Appointment__c>) oldMap);
    }
    public static void validate(List<Medical_Appointment__c> appointments, Map<Id,Medical_Appointment__c> oldMap){
        Set<Id> patientIds = new Set<Id>();
        Set<Id> facilityIds = new Set<Id>();
        
        for(Medical_Appointment__c ma : appointments) {
            //Sprawdzenie czy był update
            if (oldMap !=null) {
                Medical_Appointment__c oldma = oldMap.get(ma.Id);
                if(oldma != null && oldma.Patient__c == ma.Patient__c && oldma.Medical_facility__c == ma.Medical_facility__c) {
                    continue;
                }
            }
            if(ma.Patient__c !=null && ma.Medical_facility__c != null) {
                patientIds.add(ma.Patient__c);
                facilityIds.add(ma.Medical_facility__c);
            }
        }
        if(patientIds.isEmpty()) return; //równie dobrze facilityIds.isEmpty()
        //Wyszukanie placowek ktore w wizycie zostaly dodane lub zmienione i maja wymagane ubezpieczenie
        Map<Id,Medical_Facility__c> facilities_requires_insurance = new Map<Id, Medical_Facility__c>([Select Id FROM Medical_Facility__c WHERE Id in :facilityIds AND Requires_insurance__c = true]);
        
        if(facilities_requires_insurance.isEmpty()) return;
        
        Set<Id> insuredPatients = new Set<Id>();
        //Wyszukanie pacjentów którzy w wizycie zostali dodanie lub zmienieni i ich ubezpieczenie ma status aktywne
        for(Medical_Insurance__c mi : [Select Insured_Person__c FROM Medical_Insurance__c WHERE Insured_Person__c in :patientIds AND Status__c = 'Active']) {
            insuredPatients.add(mi.Insured_Person__c);
        }
        //jeśli placowka wymaga ubezpieczenia a pacjent go nie ma zostanie przekazany blad
		//kiedy placowka nie wymaga ubezpieczenia to będzie false i caly warunek będzie nieprawdziwy
        for(Medical_Appointment__c ma : appointments) {
            if(facilities_requires_insurance.containsKey(ma.Medical_Facility__c) && !insuredPatients.contains(ma.Patient__c))
            {
                ma.addError('Wybrana placowka wymaga ubezpieczenia, a Pacjent go nie posiada.');
            }
        }
    }
}