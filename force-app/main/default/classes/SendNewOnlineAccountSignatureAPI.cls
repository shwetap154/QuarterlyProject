/**
* @description       : 
* @author            : Padma Nerella @ Zoetis Inc
* @group             : 
* @last modified on  : 06-26-2023
* @last modified by  : Padma Nerella @ Zoetis Inc
* Modifications Log
* Ver   Date         Author                      Modification
* 1.0   6-21-2023    Padma Nerella @ Zoetis Inc  Initial version
**/
@RestResource(urlMapping='/NewOnlineAccount/SendForSignature/V1/*')
global with sharing class SendNewOnlineAccountSignatureAPI {
    
    @testVisible private static Boolean forceExceptionToFailAPI = false;
    @HttpPost
    global static void sendForSignature(List<String> leadAppNumIds){
        Logger.suspendSaving(); 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Set<String> leadAppNumSet = new Set<String>(leadAppNumIds);        
        try{
            if(forceExceptionToFailAPI){
                integer y = 1 / 0;
            }
            res.addHeader('Content-Type','application/json');
            Map<String,Id> leadAgreementIdMap = new Map<String,Id>();
            leadAgreementIdMap = NOALeadsService.sendNewOnlineAccountSignature(leadAppNumSet);
            res.responseBody = Blob.valueOf(JSON.serialize(leadAgreementIdMap));
            res.StatusCode = 201;
        }catch(exception e){
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500; 
        } finally {
            Logger.resumeSaving();
            logger.saveLog();
        }
        
    }
}