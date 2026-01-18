public class MedicalFacilityCallout
{
    public class MedicalFacilityWrapper
    {
        public String Id;
        public String Name;
        public String Email;
        public String Phone;
        public AddressWrapper Address;
        public Map<String, String> OpeningHours; 
    }
    public class AddressWrapper
    {
        public String Street;
        public String PostalCode;
        public String City;
    }


    @future(callout=true)
    public static void syncFacility()
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:MedicalFacilityAPI/services/apexrest/MedicalFacilities');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200)
        {
            List<MedicalFacilityWrapper> records = (List<MedicalFacilityWrapper>) JSON.deserialize(response.getBody(), List<MedicalFacilityWrapper>.class);
            
            upsertMedicalFacilities(records);
            upsertMedicalFacilitiesHours(records);
        } 
        else
        {
            System.debug(response.getBody());
        }
    }

    private static void upsertMedicalFacilities(List<MedicalFacilityWrapper> records)
    {
        List<Medical_Facility__c> facilitiesToUpsert = new List<Medical_Facility__c>();
        for (MedicalFacilityWrapper rec : records)
        {
            Medical_Facility__c facility = new Medical_Facility__c();
            
            facility.Medical_Facility_Code__c = rec.Id;
            facility.Name = rec.Name;
            facility.Email__c = rec.Email;
            facility.Phone_Number__c = rec.Phone;
            
            if(rec.Address != null)
            {
                facility.Medical_Facility_Address__Street__s = rec.Address.Street;
                facility.Medical_Facility_Address__PostalCode__s = rec.Address.PostalCode;
                facility.Medical_Facility_Address__City__s = rec.Address.City;
            }
            
            facilitiesToUpsert.add(facility);
        }
        
        upsert facilitiesToUpsert Medical_Facility_Code__c;
    }


    private static void upsertMedicalFacilitiesHours(List<MedicalFacilityWrapper> records)
    {
        List<Medical_Facility_Opening_Hour__c> hoursToUpsert = new List<Medical_Facility_Opening_Hour__c>();

        Set<String> facilityCodes = new Set<String>();
        for(MedicalFacilityWrapper rec : records)
        {
            facilityCodes.add(rec.Id);
        }

        Map<String, Id> facilityMap = new Map<String, Id>();
        for (Medical_Facility__c mf : [SELECT Id, Medical_Facility_Code__c FROM Medical_Facility__c WHERE Medical_Facility_Code__c IN :facilityCodes])
        {
            facilityMap.put(mf.Medical_Facility_Code__c, mf.Id);
        }

        for(MedicalFacilityWrapper rec : records)
        {
            String facilityCode = rec.Id;
            Id facilityId = facilityMap.get(facilityCode);
            for(String day : rec.OpeningHours.keySet())
            {
                Medical_Facility_Opening_Hour__c hour = new Medical_Facility_Opening_Hour__c();
                hour.Medical_Facility__c = facilityId;
                hour.Day__c = day;
                hour.Opening_Hour__c = rec.OpeningHours.get(day);
                hour.Unique_Key__c = facilityCode + day;
                hoursToUpsert.add(hour);
            }
        }
        upsert hoursToUpsert Unique_Key__c;
    }
}