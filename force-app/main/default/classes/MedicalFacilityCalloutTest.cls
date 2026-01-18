@isTest
private class MedicalFacilityCalloutTest 
{
    @isTest
    static void testSyncFacility() 
    {
        Test.setMock(HttpCalloutMock.class, new MedicalFacilityCalloutMock());
        
        Test.startTest();
        MedicalFacilityCallout.syncFacility();
        Test.stopTest();
        
        List<Medical_Facility__c> res = 
            [SELECT 
             Name, 
             Medical_Facility_Address__Street__s    
             FROM Medical_Facility__c];
        
        System.assertEquals(1, res.size());
        System.assertEquals('Test Facility', res[0].name);
        System.assertEquals('Mandarynkowa',res[0].Medical_Facility_Address__Street__s);     
        
 
        Id facilityId = res[0].Id;

        

        List<Medical_Facility_Opening_Hour__c> hours = 
            [SELECT 
             Day__c, 
             Opening_Hour__c 
             FROM Medical_Facility_Opening_Hour__c 
             WHERE Medical_Facility__c = :facilityId];

        System.assertEquals('9:00 - 18:00', hours[0].Opening_Hour__c);
    }
}