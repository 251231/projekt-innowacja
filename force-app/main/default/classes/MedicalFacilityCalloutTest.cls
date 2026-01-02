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
             Email__c, 
             Medical_Facility_Address__Street__s
             FROM Medical_Facility__c];
        
        System.assertEquals('Test Facility', res[0].name);
        System.assertEquals('Mandarynkowa',res[0].Medical_Facility_Address__Street__s);        
    }
}