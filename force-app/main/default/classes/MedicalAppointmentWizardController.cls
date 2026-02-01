public with sharing class MedicalAppointmentWizardController {

    @AuraEnabled
    public static List<Medical_Facility__c> getFacilities() {
        return [
            SELECT Id, Name
            FROM Medical_Facility__c
            ORDER BY Name
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static List<Person__c> getDoctors() {
        return [
            SELECT Id, Name
            FROM Person__c
            WHERE RecordType.DeveloperName = 'Doctor'
            ORDER BY Name
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static List<Person__c> getPatients() {
        return [
            SELECT Id, Name
            FROM Person__c
            WHERE RecordType.DeveloperName = 'Patient'
            ORDER BY Name
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static List<Person__c> getDoctorsByFacility(Id facilityId) {
        if (facilityId == null) return new List<Person__c>();

        List<Person__c> result = new List<Person__c>();

        for (Doctor_Facility_Assignment__c dfa : [
            SELECT Person__r.Id, Person__r.Name
            FROM Doctor_Facility_Assignment__c
            WHERE Medical_Facility__c = :facilityId
            ORDER BY Person__r.Name
        ]) {
            if (dfa.Person__r != null) {
                result.add(dfa.Person__r);
            }
        }
        return result;
    }

    @AuraEnabled
    public static List<Medical_Facility__c> getFacilitiesByDoctor(Id doctorId) {
        if (doctorId == null) return new List<Medical_Facility__c>();

        List<Medical_Facility__c> result = new List<Medical_Facility__c>();

        for (Doctor_Facility_Assignment__c dfa : [
            SELECT Medical_Facility__r.Id, Medical_Facility__r.Name
            FROM Doctor_Facility_Assignment__c
            WHERE Person__c = :doctorId
            ORDER BY Medical_Facility__r.Name
        ]) {
            if (dfa.Medical_Facility__r != null) {
                result.add(dfa.Medical_Facility__r);
            }
        }
        return result;
    }
}
