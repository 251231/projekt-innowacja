public with sharing class openingHoursController {
    @AuraEnabled(cacheable=true)
    public static List<Medical_Facility_Opening_Hour__c> getOpeningHours(Id facilityId) {
        return [Select Id,Day__c,Opening_Hour__c from Medical_Facility_Opening_Hour__c where Medical_Facility__c = :facilityId order by Day__c asc];
    }
}