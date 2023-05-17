public with sharing class DailyCurrencyCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest request){
        if (request.getMethod() == 'GET'){
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('[{"ccy":"EUR","base_ccy":"UAH","buy":"40.50000","sale":"41.50000"},{"ccy":"USD","base_ccy":"UAH","buy":"37.12000","sale":"37.62000"}]');
            return response;
        } else {
            return null;
        }
    }

}