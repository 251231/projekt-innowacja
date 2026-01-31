@IsTest
public class DoctorWorkSchedulesCalloutTest 
{

    private class DoctorWorkSchedulesCalloutMock implements HttpCalloutMock 
    {
        public String responseBody = '[{' +
                '"doctorId": "D000001",' +
                '"firstName": "Jan",' +
                '"lastName": "Kowalski",' +
                '"pesel": "04240307617",' +
                '"Schedule": {' +
                    '"Monday": {"StartTime":"08:00","EndTime":"16:00"},' +
                    '"Tuesday": {"StartTime":"09:00","EndTime":"15:00"}' +
                '}' +
            '}]';

        public HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(responseBody);

            return res;
        }
    }

    @IsTest
    static void testInsertSyncDoctorWorkSchedules() 
    {
        Test.setMock(HttpCalloutMock.class, new DoctorWorkSchedulesCalloutMock());

        Test.startTest();
        DoctorWorkSchedulesCallout.syncDoctorWorkSchedules();
        Test.stopTest();
        
        System.assertEquals(200, new DoctorWorkSchedulesCalloutMock().respond(new HttpRequest()).getStatusCode());

        List<Person__c> doc = [SELECT Name, 
        Personal_ID_Number__c, 
        Person_External_Id__c 
        FROM Person__c 
        WHERE Person_External_Id__c = 'D000001'];
        System.assertEquals('Jan Kowalski', doc[0].Name);
        System.assertEquals('04240307617', doc[0].Personal_ID_Number__c);
        System.assertEquals('D000001', doc[0].Person_External_Id__c);
        
         List<Working_Hour__c> hours = [
            SELECT Day__c, Start_Time__c, End_Time__c, Working_Hour_Display__c
            FROM Working_Hour__c 
            WHERE Person__c = :doc[0].Id
        ];

        System.assertEquals(2, hours.size());

        Map<String, Working_Hour__c> dayToHoursMap = new Map<String, Working_Hour__c>();

        for(Working_Hour__c hour : hours) 
        {
            dayToHoursMap.put(hour.Day__c, hour);
        }

        System.assertEquals(Time.newInstance(8, 0, 0, 0),dayToHoursMap.get('Monday').Start_Time__c);
        System.assertEquals(Time.newInstance(16, 0, 0, 0),dayToHoursMap.get('Monday').End_Time__c);
        
        System.assertEquals(Time.newInstance(9, 0, 0, 0),dayToHoursMap.get('Tuesday').Start_Time__c);
        System.assertEquals(Time.newInstance(15, 0, 0, 0),dayToHoursMap.get('Tuesday').End_Time__c);
    }

    @isTest
    static void testUpdateSyncDoctorWorkSchedules()
    {
        Person__c docToInsert = new Person__c(
            Name = 'Jan Kowalski',
            Personal_ID_Number__c = '04240307617',
            Person_External_Id__c = 'D000001'
        );
        insert docToInsert;
        Working_Hour__c wh = new Working_Hour__c(
            Person__c = docToInsert.Id,
            Day__c = 'Monday',
            Start_Time__c = Time.newInstance(8, 0, 0, 0),
            End_Time__c = Time.newInstance(16, 0, 0, 0),
            Working_Hour_Display__c = '8:00 - 16:00',
            Unique_Key__c = docToInsert.Id + 'Monday'
        );
        insert wh;

        DoctorWorkSchedulesCalloutMock mock = new DoctorWorkSchedulesCalloutMock();
        mock.responseBody = '[{' +
            '"doctorId": "D000001",' +
            '"firstName": "Jan",' +
            '"lastName": "Nowak",' +
            '"pesel": "04240307617",' +
            '"Schedule": {' +
                '"Monday": {"StartTime":"10:00","EndTime":"18:00"},' +
                '"Tuesday": {"StartTime":"09:00","EndTime":"15:00"}' +
            '}' +
        '}]';

        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        DoctorWorkSchedulesCallout.syncDoctorWorkSchedules();
        Test.stopTest();

        List<Person__c> doc = [SELECT Name, 
        Personal_ID_Number__c, 
        Person_External_Id__c 
        FROM Person__c 
        WHERE Person_External_Id__c = 'D000001'];

        System.assertEquals('Jan Nowak', doc[0].Name);
        System.assertEquals('04240307617', doc[0].Personal_ID_Number__c);
        System.assertEquals('D000001', doc[0].Person_External_Id__c);

        List<Working_Hour__c> hours = [
            SELECT Day__c, Start_Time__c, End_Time__c, Working_Hour_Display__c
            FROM Working_Hour__c 
            WHERE Person__c = :doc[0].Id
        ];

        Map<String, Working_Hour__c> dayToHoursMap = new Map<String, Working_Hour__c>();
        for(Working_Hour__c hour : hours) 
        {
            dayToHoursMap.put(hour.Day__c, hour);
        }

        System.assertEquals(2, hours.size());
        System.assertEquals(Time.newInstance(10, 0, 0, 0),dayToHoursMap.get('Monday').Start_Time__c);
        System.assertEquals(Time.newInstance(18, 0, 0, 0),dayToHoursMap.get('Monday').End_Time__c);

        System.assertEquals(Time.newInstance(9, 0, 0, 0),dayToHoursMap.get('Tuesday').Start_Time__c);
        System.assertEquals(Time.newInstance(15, 0, 0, 0),dayToHoursMap.get('Tuesday').End_Time__c);
    }
}