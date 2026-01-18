public class DoctorWorkSchedulesCallout implements Schedulable
{
    public class DoctorWorkScheduleWrapper
    {
        public String doctorId;
        public String firstName;
        public String lastName;
        public String pesel;
        public Map<String, DaySchedule> Schedule;
    }
    public class DaySchedule
    {
        public String StartTime;
        public String EndTime;
    }

    @future(callout=true)
    public static void syncDoctorWorkSchedules()
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('callout:MedicalFacilityAPI/services/apexrest/DoctorWorkSchedules');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200)
        {
            List<DoctorWorkScheduleWrapper> records = (List<DoctorWorkScheduleWrapper>) JSON.deserialize(response.getBody(), List<DoctorWorkScheduleWrapper>.class);
            
            upsertDoctors(records);
            upsertSchedules(records);
        } 
        else
        {
            System.debug(response.getBody());
        }
    }

    private static void upsertDoctors(List<DoctorWorkScheduleWrapper> records)
    {
        List<Person__c> doctorsToUpsert = new List<Person__c>();
        for (DoctorWorkScheduleWrapper rec : records)
        {
            Person__c doctor = new Person__c();
            
            doctor.Person_External_Id__c = rec.doctorId;
            doctor.Name = rec.firstName + ' ' + rec.lastName;
            doctor.Personal_ID_Number__c = rec.pesel;
            
            doctorsToUpsert.add(doctor);
            System.debug(doctor);
        }
        
        System.debug('test');
        upsert doctorsToUpsert Person_External_Id__c;
    }

    private static void upsertSchedules(List<DoctorWorkScheduleWrapper> records)
    {
        Set<String> doctorCodes = new Set<String>();
        for(DoctorWorkScheduleWrapper rec : records)
        {
            doctorCodes.add(rec.doctorId);
        }
        Map<String, Id> doctorCodeToIdMap = new Map<String, Id>();
        for(Person__c doc : [SELECT Id, Person_External_Id__c FROM Person__c WHERE Person_External_Id__c IN : doctorCodes])
        {
            doctorCodeToIdMap.put(doc.Person_External_Id__c, doc.Id);
        }

        List<Working_Hour__c> schedulesToUpsert = new List<Working_Hour__c>();
        
        for (DoctorWorkScheduleWrapper rec : records)
        {
            Id doctorId = doctorCodeToIdMap.get(rec.doctorId);
            for(String day : rec.Schedule.keySet())
            {
                DaySchedule ds = rec.Schedule.get(day);
                Working_Hour__c schedule = new Working_Hour__c();
                
                schedule.Person__c = doctorId;
                schedule.Day__c = day;
                schedule.Start_Time__c = parseTime(ds.StartTime);
                schedule.End_Time__c = parseTime(ds.EndTime);
                schedule.WorKing_Hour_Display__c = ds.startTime + ' - ' + ds.endTime;
                schedule.Unique_Key__c = doctorId + day;

                schedulesToUpsert.add(schedule);
                
                System.debug(schedule);
            }
        	    
        }
        
        System.debug('test');
        upsert schedulesToUpsert unique_Key__c;
    }

    private static Time parseTime(String str) 
    {
        List<String> parts = str.split(':');
        Integer hour = Integer.valueOf(parts[0]);
        Integer min  = Integer.valueOf(parts[1]);
        return Time.newInstance(hour, min, 0, 0);
    }
    
    
    public void execute(SchedulableContext ctx)
    {
        syncDoctorWorkSchedules();
    }
    
    public static void scheduleDailySync(String cronExp, String jobName)
    {
        System.schedule(jobName, cronExp, new DoctorWorkSchedulesCallout());
    }
    
    //DoctorWorkSchedulesCallout.scheduleDailySync('0 0 5 * * ?', 'Dzienna synchronizacja doktorow');
}