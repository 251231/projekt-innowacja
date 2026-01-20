public with sharing class MedicalFacilityMapController {

    @AuraEnabled(cacheable=true)
    public static List<Medical_Facility__c> getFacilities() {
        return [
            SELECT Id,
                   Name,
                   Medical_Facility_Address__Street__s,
                   Medical_Facility_Address__City__s,
                   Medical_Facility_Address__PostalCode__s,
                   Medical_Facility_Address__CountryCode__s
            FROM Medical_Facility__c
        ];
    }
}