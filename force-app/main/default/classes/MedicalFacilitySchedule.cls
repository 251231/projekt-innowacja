public class MedicalFacilitySchedule implements Schedulable
{
    public void execute(SchedulableContext ctx)
    {
        MedicalFacilityCallout.syncFacility();
    }
    
    //String cronExp = '0 0 5 * * ?';
	//System.schedule('Dzienna synchronizacja', cronExp, new MedicalFacilitySchedule());
}