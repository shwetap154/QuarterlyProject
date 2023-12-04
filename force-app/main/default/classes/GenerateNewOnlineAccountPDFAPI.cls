/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 07-06-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   07-06-2023    Padma Nerella @ Zoetis Inc  Initial version TPDEV-1268
**/
@RestResource(urlMapping='/NewOnlineAccount/GeneratePDF/V1/*')
global with sharing class GenerateNewOnlineAccountPDFAPI {
    
    @testVisible private static Boolean forceExceptionToFailAPI = false;
    
    /**
    * @description API request to generate pdf for leads passed in.
    * @author Padma Nerella @ Zoetis Inc | 07-07-2023 
    * @param leadAppNumIds 
    **/
    @HttpPost
    global static void generatePDF(List<String> leadAppNumIds){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Set<String> leadAppNumSet = new Set<String>(leadAppNumIds);
        Map<String,Blob> generatePDFWithAppNumMap = new Map<String,Blob>();
        try{
            res.addHeader('Content-Type','application/json');
            generatePDFWithAppNumMap = NOALeadsService.generateNewOnlineAccountPDF(leadAppNumSet);
            res.responseBody = Blob.valueOf(JSON.serialize(generatePDFWithAppNumMap));
            res.StatusCode = 201;
            if(forceExceptionToFailAPI){
                integer y = 1 / 0;
            }
        } catch(exception e){
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
            logger.saveLog();
        }
    }
}