@isTest
private class MedicalFacilityCalloutTest 
{
    @isTest
    static void testInsertSyncFacility() 
    {

        Test.setMock(HttpCalloutMock.class, new MedicalFacilityCalloutMock());
        
        Test.startTest();
        MedicalFacilityCallout.syncFacility();
        Test.stopTest();
        
        System.assertEquals(200, MedicalFacilityCalloutMock.getLastStatusCode());

        Medical_Facility__c facility = 
            [SELECT Id, 
             Name, 
             Medical_Facility_Code__c,
             Email__c,
             Phone_Number__c,
             Medical_Facility_Address__PostalCode__s,
             Medical_Facility_Address__City__s,
             Medical_Facility_Address__Street__s    
             FROM Medical_Facility__c 
             WHERE Medical_Facility_Code__c = '12345'];
        
        System.assertEquals('Test Facility', facility.Name);
        System.assertEquals('Mandarynkowa', facility.Medical_Facility_Address__Street__s);     
        System.assertEquals('95-103', facility.Medical_Facility_Address__PostalCode__s);
        System.assertEquals('Lodz', facility.Medical_Facility_Address__City__s);
        System.assertEquals('test@example.com', facility.Email__c);
        System.assertEquals('123456789', facility.Phone_Number__c);
        System.assertEquals('12345', facility.Medical_Facility_Code__c);
 

        List<Medical_Facility_Opening_Hour__c> hours = 
            [SELECT 
             Day__c, 
             Opening_Hour__c,
                Medical_Facility__c
             FROM Medical_Facility_Opening_Hour__c 
             WHERE Medical_Facility__c = :facility.Id];

        System.assertEquals(1, hours.size());
        
        Map<String, String> expectedHours = new Map<String, String>{
            'Poniedziałek' => '9:00 - 18:00'
        };

        System.assertEquals(facility.Id, hours[0].Medical_Facility__c);
        System.assertEquals('9:00 - 18:00', hours[0].Opening_Hour__c);
    }

    @isTest
    static void testUpdateSyncFacility() 
    {
        Medical_Facility__c facility = new Medical_Facility__c(
            Name = 'Test Facility',
            Medical_Facility_Code__c = '12345',
            Email__c = 'test@example.com',
            Phone_Number__c = '123456789',
            Medical_Facility_Address__Street__s = 'Mandarynkowa',
            Medical_Facility_Address__City__s = 'Lodz',
            Medical_Facility_Address__PostalCode__s = '95-103'
        );
        insert facility;
        
        Medical_Facility_Opening_Hour__c openingHour = new Medical_Facility_Opening_Hour__c(
            Medical_Facility__c = [SELECT Id FROM Medical_Facility__c WHERE Medical_Facility_Code__c = '12345'].Id,
            Day__c = 'Poniedziałek',
            Opening_Hour__c = '9:00 - 18:00',
            Unique_Key__c = '12345Poniedziałek'
        );
        insert openingHour; 

        MedicalFacilityCalloutMock.responseBody ='[{"Name":"Test Facility",'+
        '"Id":"12345","Email":"updated@example.com",'+
        '"Phone":"987654321","OpeningHours":{"Poniedziałek":"10:00 - 20:00"},'+
        '"Address":{"Street":"Mandarynkowa 2","City":"Lodz","PostalCode":"95-103"}}]';

        Test.setMock(HttpCalloutMock.class, new MedicalFacilityCalloutMock());
        Test.startTest();
        MedicalFacilityCallout.syncFacility();
        Test.stopTest();

        Medical_Facility__c updatedFacility = 
            [SELECT Id, 
             Name, 
             Medical_Facility_Code__c,
             Email__c,
             Phone_Number__c,
             Medical_Facility_Address__PostalCode__s,
             Medical_Facility_Address__City__s,
             Medical_Facility_Address__Street__s    
             FROM Medical_Facility__c 
             WHERE Medical_Facility_Code__c = '12345'];

        System.assertEquals('Test Facility', updatedFacility.Name);
        System.assertEquals('Mandarynkowa 2', updatedFacility.Medical_Facility_Address__Street__s);     
        System.assertEquals('95-103', updatedFacility.Medical_Facility_Address__PostalCode__s);
        System.assertEquals('Lodz', updatedFacility.Medical_Facility_Address__City__s);
        System.assertEquals('987654321', updatedFacility.Phone_Number__c);
        System.assertEquals('updated@example.com', updatedFacility.Email__c);
        System.assertEquals('12345', updatedFacility.Medical_Facility_Code__c);


        List<Medical_Facility_Opening_Hour__c> updatedHours = 
            [SELECT 
             Day__c, 
             Opening_Hour__c,
                Medical_Facility__c
             FROM Medical_Facility_Opening_Hour__c 
             WHERE Medical_Facility__c = :updatedFacility.Id];

        System.assertEquals(1, updatedHours.size());
        System.assertEquals('10:00 - 20:00', updatedHours[0].Opening_Hour__c);
    }
}