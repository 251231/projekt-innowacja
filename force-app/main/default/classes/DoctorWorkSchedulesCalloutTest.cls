@IsTest
public class DoctorWorkSchedulesCalloutTest 
{

    private class DoctorWorkSchedulesCalloutMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            res.setBody('[{' +
                '"doctorId": "D000001",' +
                '"firstName": "Jan",' +
                '"lastName": "Kowalski",' +
                '"pesel": "04240307617",' +
                '"Schedule": {' +
                    '"Monday": {"StartTime":"08:00","EndTime":"16:00"},' +
                    '"Tuesday": {"StartTime":"09:00","EndTime":"15:00"}' +
                '}' +
            '}]');

            return res;
        }
    }

    @IsTest
    static void testSyncDoctorWorkSchedules() 
    {
        Test.setMock(HttpCalloutMock.class, new DoctorWorkSchedulesCalloutMock());

        Test.startTest();
        DoctorWorkSchedulesCallout.syncDoctorWorkSchedules();
        Test.stopTest();
        
        List<Person__c> doc = [SELECT Name, Personal_ID_Number__c, Person_External_Id__c FROM Person__c WHERE Person_External_Id__c = 'D000001'];
        System.assertEquals('Jan Kowalski', doc[0].Name);
        System.assertEquals('04240307617', doc[0].Personal_ID_Number__c);

        
         List<Working_Hour__c> hours = [
            SELECT Day__c, Start_Time__c, End_Time__c, Working_Hour_Display__c
            FROM Working_Hour__c 
            WHERE Person__c = :doc[0].Id
        ];

        System.assertEquals(2, hours.size(), 'Powinny być dodane 2 wpisy godzin pracy');

        
    }
}