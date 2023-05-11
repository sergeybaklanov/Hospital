@IsTest
global class PatientGeneratorCalloutMock implements HttpCalloutMock{
   
   global static HttpResponse respond(HttpRequest request){
      HttpResponse response = new HttpResponse();
      response.setHeader('Content-Type', 'application/json');
      response.setBody('{"results": [{"name": "Mia McGlynn","date": "2012-01-21"},{"name": "Mazie Blick","date": "1958-02-02"},{"name": "Estefania Hoppe Sr.","date": "2013-07-22"},{"name": "Heather Harris","date": "1965-03-25"},{"name": "Ron Runolfsdottir","date": "1983-04-01"},{"name": "Yasmin Bergstrom III","date": "1999-02-22"},{"name": "Betsy Dibbert","date": "2008-04-02"},{"name": "Arne Kilback","date": "1998-02-28"},{"name": "Dante Ernser","date": "2000-12-14"},{"name": "Ruthe Kuhlman","date": "1993-03-24"}]}');
      response.setStatusCode(200);
      return response;
   }

}