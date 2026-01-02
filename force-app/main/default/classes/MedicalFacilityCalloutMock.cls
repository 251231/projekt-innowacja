global class MedicalFacilityCalloutMock implements HttpCalloutMock 
{
    global HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setBody('[{"Name":"Test Facility","Id":"12345","Email":"test@example.com","Phone":"123456789","OpeningHours":{"Poniedziałek":"9:00 - 18:00"},"Address":{"Street":"Mandarynkowa","City":"Lodz","PostalCode":"95-103","CountryCode":"PL"}}]');
        return response;
    }
}