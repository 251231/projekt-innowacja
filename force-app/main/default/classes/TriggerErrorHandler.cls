public with sharing class TriggerErrorHandler {
    public static void handleError(Exception e, String context) {
        try {
            List<String>toAddresses = new List<String>{}; 
            List<User>u = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator' AND Email = '251231@edu.p.lodz.pl'];
            for(user ui : u){ 
                toAddresses.add(ui.Email); 
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject(' Błąd w triggerze: ' + context);
            mail.setPlainTextBody(
                'Wystąpił błąd w triggerze.\n\n' +
                'Kontekst: ' + context + '\n\n' +
                'Message: ' + e.getMessage() + '\n\n' +
                'StackTrace:\n' + e.getStackTraceString()
            );

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
        } catch (Exception ignore) {
        }
    }
}