public with sharing class MedicalFacilityMapController {

    @AuraEnabled(cacheable=true)
    public static List<Medical_Facility__c> getFacilities(String searchKey) {

        String key = '%' + String.escapeSingleQuotes(
            String.isBlank(searchKey) ? '' : searchKey.trim()
        ) + '%';

        return [
            SELECT Id,
                Name,
                Medical_Facility_Address__Street__s,
                Medical_Facility_Address__City__s,
                Medical_Facility_Address__PostalCode__s,
                Medical_Facility_Address__CountryCode__s
            FROM Medical_Facility__c
            WHERE Name LIKE :key
            ORDER BY Name
            LIMIT 100
        ];
    }

}