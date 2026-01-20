public class MedicalAppointmentTriggerHandler {

    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                validateDoctorFacilityAssignment(Trigger.new);
            }
        }
    }

    private void validateDoctorFacilityAssignment(
        List<Medical_Appointment__c> appointments
    ) {
        Set<Id> doctorIds = new Set<Id>();
        Set<Id> facilityIds = new Set<Id>();

        for (Medical_Appointment__c ma : appointments) {
            if (ma.Doctor__c != null && ma.Medical_Facility__c != null) {
                doctorIds.add(ma.Doctor__c);
                facilityIds.add(ma.Medical_Facility__c);
            }
        }

        if (doctorIds.isEmpty() || facilityIds.isEmpty()) {
            return;
        }

        Set<String> validPairs = new Set<String>();

        for (Doctor_Facility_Assignment__c df : [
            SELECT Person__c, Medical_Facility__c
            FROM Doctor_Facility_Assignment__c
            WHERE Person__c IN :doctorIds
              AND Medical_Facility__c IN :facilityIds
        ]) {
            validPairs.add(df.Person__c + '-' + df.Medical_Facility__c);
        }

        for (Medical_Appointment__c ma : appointments) {
            if (ma.Doctor__c != null && ma.Medical_Facility__c != null) {
                String key = ma.Doctor__c + '-' + ma.Medical_Facility__c;
                if (!validPairs.contains(key)) {
                    ma.addError(
                        'Wybrany lekarz nie pracuje w wybranej placówce.'
                    );
                }
            }
        }
    }
}