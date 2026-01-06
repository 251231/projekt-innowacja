public with sharing class EmailNotificationTriggerHandler {
    public override void afterInsert(List<SObject> newList) {
        sendAppointmentEmails((List<Medical_Appointment__c>) newList, null);
    }
    
    public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
        sendAppointmentEmails((List<Medical_Appointment__c>) newList, (Map<Id, Medical_Appointment__c>) oldMap);
    }

    public static void sendAppointmentEmails(List<Medical_Appointment__c> appointments) {
        
        List<Medical_Appointment__c> apps = [
            SELECT Id,
                   Email_content__c,
                   Appointment_Type__c,
                   Appointment_Status__c,
                   Patient__r.Email__c,
                   Patient__r.Name,
                   Doctor__r.Name
            FROM Medical_Appointment__c
            WHERE Id IN :appointments
        ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        EmailTemplate template;
        try {
            template = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName = 'Appointment_Notification'
                LIMIT 1
            ];
        } catch (Exception e) {
            template = null;
        }

        for (Medical_Appointment__c app : apps) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setToAddresses(new List<String>{ app.Patient__r.Email__c });
            email.setSubject('Powiadomienie o wizycie');

             //Treść od użytkownika
            if (!String.isBlank(app.Email_content__c)) {

                email.setPlainTextBody(app.Email_content__c);

            }
            //Email Template
            else if (template != null) {

                email.setTemplateId(template.Id);
                email.setWhatId(app.Id);

            }
            //Treść na sztywno
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
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }

    }
}