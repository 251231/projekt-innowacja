public class EmailNotificationTriggerHandler extends TriggerHandler {

    public override void afterInsert(List<SObject> newList) {
        sendAppointmentEmails((List<Medical_Appointment__c>) newList);
    }
    
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        sendAppointmentEmails((List<Medical_Appointment__c>) newList);
    }

    public static void sendAppointmentEmails(List<Medical_Appointment__c> appointments) {

        // Pobieramy wszystkie potrzebne pola
        List<Medical_Appointment__c> apps = [
            SELECT Id,
                   Appointment_Type__c,
                   Appointment_Status__c,
                   Patient__r.Email__c,
                   Patient__r.Name,
                   Doctor__r.Name
            FROM Medical_Appointment__c
            WHERE Id IN :appointments
        ];

        if (apps.isEmpty()) return; // nic do wysłania

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Pobieramy template (jeśli istnieje)
        EmailTemplate template;
        try {
            template = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = 'Appointment_Notification_VF12'
                LIMIT 1
            ];
        } catch (Exception e) {
            template = null;
        }

        for (Medical_Appointment__c app : apps) {

            // Jeśli brak maila pacjenta – pomijamy
            if (String.isBlank(app.Patient__r.Email__c)) {
                continue;
            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ app.Patient__r.Email__c });
            email.setSubject('Powiadomienie o wizycie');
            email.setSaveAsActivity(false);

            // Jeżeli jest template – używamy go
            if (template != null) {
                email.setTemplateId(template.Id);
                email.setWhatId(app.Id); // do merge fields w szablonie
            } 
            // W przeciwnym razie wysyłamy treść "na sztywno"
            else {
                email.setPlainTextBody(
                    'Dzień dobry ' + app.Patient__r.Name + ',\n\n' +
                    'Informujemy o zmianie lub utworzeniu wizyty.\n\n' +
                    'Lekarz: ' + app.Doctor__r.Name + '\n' +
                    'Typ wizyty: ' + app.Appointment_Type__c + '\n' +
                    'Status: ' + app.Appointment_Status__c + '\n\n' +
                    'Pozdrawiamy,\n' +
                    'Placówka medyczna'
                );
            }

            emails.add(email);
        }

        // Wysyłka maili
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
