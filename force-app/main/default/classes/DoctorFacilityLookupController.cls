public with sharing class DoctorFacilityLookupController {

    @AuraEnabled(cacheable=true)
    public static List<Person__c> searchDoctors(String searchKey, Id facilityId) {

        if (String.isBlank(searchKey)) {
            searchKey = '';
        }

        if (facilityId != null) {

            Set<Id> doctorIds = new Set<Id>();

            for (Doctor_Facility_Assignment__c dfa : [
                SELECT Person__c
                FROM Doctor_Facility_Assignment__c
                WHERE Medical_Facility__c = :facilityId
            ]) {
                doctorIds.add(dfa.Person__c);
            }

            if (doctorIds.isEmpty()) {
                return new List<Person__c>();
            }

            return [
                SELECT Id, Name
                FROM Person__c
                WHERE RecordType.DeveloperName = 'Doctor'
                AND Name LIKE :('%' + searchKey + '%')
                AND Id IN :doctorIds
                LIMIT 20
            ];
        }

        return [
            SELECT Id, Name
            FROM Person__c
            WHERE RecordType.DeveloperName = 'Doctor'
            AND Name LIKE :('%' + searchKey + '%')
            LIMIT 20
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Medical_Facility__c> searchFacilities(String searchKey, Id doctorId) {

        if (String.isBlank(searchKey)) {
            searchKey = '';
        }

        if (doctorId != null) {

            Set<Id> facilityIds = new Set<Id>();

            for (Doctor_Facility_Assignment__c dfa : [
                SELECT Medical_Facility__c
                FROM Doctor_Facility_Assignment__c
                WHERE Person__c = :doctorId
            ]) {
                facilityIds.add(dfa.Medical_Facility__c);
            }

            if (facilityIds.isEmpty()) {
                return new List<Medical_Facility__c>();
            }

            return [
                SELECT Id, Name
                FROM Medical_Facility__c
                WHERE Name LIKE :('%' + searchKey + '%')
                AND Id IN :facilityIds
                LIMIT 20
            ];
        }

        return [
            SELECT Id, Name
            FROM Medical_Facility__c
            WHERE Name LIKE :('%' + searchKey + '%')
            LIMIT 20
        ];
    }
}
