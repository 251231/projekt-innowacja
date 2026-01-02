public class MedicalFacilityCallout
{
    
    @future(callout=true)
    public static void syncFacility()
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:MedicalFacilityAPI/services/apexrest/MedicalFacilities');
        request.setMethod('GET');
        System.debug(request);
        
        HttpResponse response = http.send(request);
        System.debug('Test');
        System.debug(response);
        
        if(response.getStatusCode() == 200)
        {
            List<Object> records = (List<Object>) JSON.deserializeUntyped(response.getBody());
            
            upsertMedicalFacilities(records);
            upsertMedicalFacilitiesHours(records);
        } 
        else
        {
            System.debug(response.getBody());
        }
    }
    
    private static void upsertMedicalFacilities(List<Object> records)
    {
        System.debug(records.size());
        List<Medical_Facility__c> facilitiesToUpsert = new List<Medical_Facility__c>();
        for (Object obj : records)
        {
            System.debug(obj);
            Map<String, Object> data = (Map<String, Object>) obj;
            Medical_Facility__c facility = new Medical_Facility__c();
            
            facility.Medical_Facility_Code__c = ((String) data.get('Id')).trim();
            facility.Name = (String) data.get('Name');
            facility.Email__c = (String) data.get('Email');
            facility.Phone_Number__c = (String) data.get('Phone');
            
            Map<String, Object> addresMap = (Map<String, Object>) data.get('Address');
            if(addresMap != null)
            {
                facility.Medical_Facility_Address__Street__s = (String) addresMap.get('Street');
                facility.Medical_Facility_Address__PostalCode__s = (String) addresMap.get('PostalCode');
                facility.Medical_Facility_Address__City__s = (String) addresMap.get('City');
                facility.Medical_Facility_Address__CountryCode__s = 'PL';
            }
            
            System.debug(facility);
            facilitiesToUpsert.add(facility);
        }
        
        upsert facilitiesToUpsert Medical_Facility_Code__c;
    }
   
    
    private static void upsertMedicalFacilitiesHours(List<Object> records)
    {
        List<Medical_Facility_Opening_Hour__c> hoursToUpsert = new List<Medical_Facility_Opening_Hour__c>();
        Map<String, Id> facilityMap = new Map<String, Id>();
        for (Medical_Facility__c mf : [SELECT Id, Medical_Facility_Code__c FROM Medical_Facility__c])
        {
            facilityMap.put(mf.Medical_Facility_Code__c, mf.Id);
        }
        
        for(Object obj : records)
        {
            Map<String, Object> data = (Map<String, Object>) obj;
            
            String facilityCode = (String) data.get('Id');
            Id facilityId = facilityMap.get(facilityCode);
            
            Map<String, Object> openingHours = (Map<String, Object>) data.get('OpeningHours');
            
            for(String day : openingHours.keySet())
            {
                Medical_Facility_Opening_Hour__c hour = new Medical_Facility_Opening_Hour__c();
                hour.Medical_Facility__c = facilityId;
                hour.Day__c = day;
                hour.Opening_Hour__c = (String) openingHours.get(day);
                hour.Unique_Key__c = facilityCode + day;
                hoursToUpsert.add(hour);
            }
        }
        
        upsert hoursToUpsert Unique_Key__c;
    }
}