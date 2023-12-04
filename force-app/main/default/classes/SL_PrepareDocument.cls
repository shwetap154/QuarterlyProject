/**
* @ClassName    : SL_PrepareDocument 
* @JIRATicket   : ZETM-26
* @CreatedOn    : 22nd March 2019.
* @CreatedBy    : Poonam Dalvi
* @ModifiedBy   : Premraj K K
* @Description  : Controller to fetch the template on click of Prepare Document Lightning quick action.
*/
public with sharing class SL_PrepareDocument {
    /***********
      * Method name  : fetchPrepareDocumentURL
      * Description  : Gets the URL of the 
      * Return Type  : String
      * Parameters   : String strRecordId
    ***********/ 
    @AuraEnabled
    public static String fetchPrepareDocumentURL(Id strRecordId) {
        
        if(String.isBlank(strRecordId))
            throw new AuraHandledException('Something went wrong, please contact the administrator');
       
        
        List<echosign_dev1__Agreement_Template__c> lstAgreementTemplate = new List<echosign_dev1__Agreement_Template__c>();
        String redirectURL;
        String strTemplateName = '';
        Id userId = UserInfo.getUserId();
        String strObjectName = strRecordId.getSObjectType().getDescribe().getName();
        
        if(strObjectName == 'Account') {
            Account acc = [SELECT Id, ZTS_EU_Market__c,FR_Contract_Template__c,Fr_Contract_Email__c 
                             FROM Account 
                            WHERE Id= :strRecordId AND ZTS_EU_Market__c != 'United States'];
            
            
            if(acc.ZTS_EU_Market__c == 'France')
            {
                if(acc.Fr_Contract_Email__c == null){
                    throw new AuraHandledException ('FR Contract Email field must be populated.');
                }
                else if(acc.FR_Contract_Template__c == null)
                {
                    throw new AuraHandledException ('You must select FR Contract Template to proceed.');
                }
                else
                {   //SC-009999 Fetch 2023 France Contracts
                    if(acc.FR_Contract_Template__c == 'Contrat annuel AD CA')
                                strTemplateName = 'Contrat de partenariat AD 2023 Animaux de Compagnie'; 
                    else if(acc.FR_Contract_Template__c == 'Contrat annuel AD RU')
                                strTemplateName = 'Contrat de partenariat AD 2023 Ruminants'; 
                    else if(acc.FR_Contract_Template__c == 'Contrat annuel AD EQ')
                                strTemplateName = 'Contrat de partenariat AD 2023 Equine';
                    else if(acc.FR_Contract_Template__c == 'Contrat annuel AD AV')
                                strTemplateName = 'Contrat de partenariat AD 2021 Aviaire';
                }
            }
            
            lstAgreementTemplate = fetchAgreementTemplate('Account', strTemplateName);
        }
        
        else if(strObjectName == 'ZTS_EU_Sample__c') {
            strTemplateName = 'Sample AT';
            lstAgreementTemplate = fetchAgreementTemplate('ZTS_EU_Sample__c', 'Sample AT');
        }
        
        else if(strObjectName == 'Contact') {
            
            User objUser = [SELECT ZTS_EU_Market__c 
                            FROM User 
                            WHERE Id =: userId AND ZTS_EU_Market__c != 'United States']; 
            String strMarket = objUser.ZTS_EU_Market__c;
            
            Contact objContact = [Select Select_Consent_for_eSign__c ,IT_Contact_Template__c
                                  From Contact 
                                  Where Id =: strRecordId AND ZTS_EU_Market__c != 'United States'];
                        String strConsent = objContact.Select_Consent_for_eSign__c; 
            String strEuropeanMarketLabel = System.Label.EuropeanMarkets;
            
            if(!strEuropeanMarketLabel.contains(strMarket))
                throw new AuraHandledException('This feature is not available for your Market : ' + strMarket);
            else {
                if(String.isEmpty(strConsent))
                    throw new AuraHandledException('Please Select Consent for eSign value.');
                else {
                    if(strMarket.toLowerCase() != 'belgium' && (strConsent == 'Privacy - NL' || strConsent == 'Privacy - FR'))
                        throw new AuraHandledException('This feature is not applicable for your strMarket : ' + strMarket + '. Please select Privacy from Select Concent from eSign to sign a contact privacy form.'); 
                    else if(strMarket.toLowerCase() == 'belgium' && strConsent == 'Privacy' )
                        throw new AuraHandledException('Please select Privacy - NL for Dutch version Or Privacy - FR for French version'); 
                    //SC -009894 - Added to fetch agreements based on IT_Contact_Template 
                    else if(strMarket.toLowerCase() == 'italy')
                        {
                            if(objContact.IT_Contact_Template__c == null){
                                throw new AuraHandledException ('You must select IT Contact Template to proceed.');
                            }
                            else{
                                
                            if(objContact.IT_Contact_Template__c == 'Global Data Privacy')
                                strTemplateName = 'Contact AT for Privacy - italy';                               
                            else if(objContact.IT_Contact_Template__c == 'Customer Service Form CS1')
                                strTemplateName = 'Customer Service Form CS1 - italy';                                
                            else if(objContact.IT_Contact_Template__c == 'Customer Service Form CS3')
                                strTemplateName = 'Customer Service Form CS3 - italy'; 
                           }     
                        }
                   
                    //SC-009894 - End of Code
                    //TPDEV-392
                    else if(strMarket.toLowerCase() == 'thailand'){
                        if(objContact.IT_Contact_Template__c == null){
                            throw new AuraHandledException ('You must select  Contact Template to proceed.');
                        }else{                            
                                strTemplateName = objContact.IT_Contact_Template__c;
                            }                                
                        
                    } //TPDEV-392 -EOC
                    else {
                       if(strConsent.contains('Privacy')) {
                            if(strConsent == 'Privacy - NL')
                                strTemplateName = 'Contact AT for Privacy - belgium(dutch)'; 
                            else if(strConsent == 'Privacy - FR')
                                strTemplateName = 'Contact AT for Privacy - belgium(french)'; 
                            else if(strConsent == 'Privacy - PH')
                                strTemplateName = 'Contact AT for Privacy Pharmaq - Turkey';
                            else
                                strTemplateName = 'Contact AT for Privacy - ' + strMarket.toLowerCase(); 
                        }
                        else if(strMarket.toLowerCase() == 'spain')
                            strTemplateName = 'Contact AT for ' + strMarket + ' - ' + strConsent; 
                        
                        else
                            strTemplateName = '';
                            //lstAgreementTemplate = fetchAgreementTemplate('Contact', strTemplateName);
                    }
                     
                        lstAgreementTemplate = fetchAgreementTemplate('Contact', strTemplateName); //SC-009894
                }
            }
        }
        else if(strObjectName == 'Contract') { 
            User objUser = [SELECT ZTS_EU_Market__c 
                            FROM User 
                            WHERE Id =: userId AND ZTS_EU_Market__c != 'United States']; 
            String strMarket = objUser.ZTS_EU_Market__c;
            
            String contractDocument = [Select eSign_Document__c
                                       From Contract
                                       Where Id =: strRecordId AND ZTS_EU_Market__c != 'United States'].eSign_Document__c;
            
            if(String.isBlank(contractDocument))
                throw new AuraHandledException('Please select eSign Dcoument');
            
            strTemplateName = 'Contract AT for ' + strMarket.toLowerCase() + ' - ' + contractDocument;
            lstAgreementTemplate = fetchAgreementTemplate('Contract', strTemplateName);
        }
        
        if(lstAgreementTemplate.isEmpty())
            throw new AuraHandledException('No agreement template defined with the name: ' + strTemplateName);
       
            //TPDEV-2015 instead of using apex/page we are using PageReference.
            PageReference pageRef = new PageReference('/apex/echosign_dev1__AgreementTemplateProcess?masterId=' + strRecordId + '&TemplateId=' + lstAgreementTemplate[0].Id);
            if(strObjectName == 'Contact' || strObjectName == 'Contract'|| strObjectName == 'Account')
                pageRef.getParameters().put('loggedinUser',userId);
            redirectURL = pageRef.getUrl(); 
            return redirectURL;
        
    }
    
    private static List<echosign_dev1__Agreement_Template__c> fetchAgreementTemplate(String objectType, String templateName) {
       return 
         new List<echosign_dev1__Agreement_Template__c>([SELECT Id, Name 
                                                               FROM echosign_dev1__Agreement_Template__c 
                                                               WHERE echosign_dev1__Master_Object_Type__c =:objectType AND Name =: templateName]);
        
     
    }
}