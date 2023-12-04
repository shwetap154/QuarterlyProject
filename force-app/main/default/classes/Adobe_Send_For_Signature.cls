/**********************************************************************************************************************************************
 * Trigger Name : Adobe_Send_For_Signature
 * Description  : This is used to prepare document information needed for Adobe send for singature including both manual and auto submissions
 * Created By   : Shiva Kudikilla
 * Created Date : Oct 10, 2016 
 *
 * Modification History:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Author                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Shiva Kudikilla       10/10/2016         Initial Version
 * Abir Bhattacharya     31/07/2017         Changed for new requirement, dynamic tage generated(SC-002287)
***********************************************************************************************************************************************/
global with sharing class Adobe_Send_For_Signature {
    public static Id contractId;
    public static List<AccWrapper> suppliers {get;set;} 
    public static List<AccWrapper> addlLocations {get;set;}
    public static List<AccWrapper> distributors {get;set;}
    public static List<string> adobeTags {get;set;}
   
    
    public Adobe_Send_For_Signature(ApexPages.StandardController controller){ 
        
               
        string tagName = '', seperator = '&”-”&', openBraces= '{{', closeBraces = '}}', referenceTag = '$V';//, delimiter=',';
        string tagFormat= '#V{0}={0}_es_:signer1:checkbox';
        string calcFieldFormat = '{2}_es_:signer1:calc({0}):hideifany({1}=checked,{1}=unchecked)';
        
        addlLocations = new List<AccWrapper>(); 
        suppliers = new List<AccWrapper>();
        distributors = new List<AccWrapper>(); 
        adobeTags =  new List<String>();
                
        contractId = controller.getId();
        Contract contract = [select id,name,AccountId,ContractNumber,ZTS_US_NARC_ID__c,ZTS_US_Current_Tier__c,ZTS_US_Field_Proposed_Tier__c from Contract where Id = :contractId AND ZTS_EU_Market__c = 'United States' limit 1];
        
        
        //fetching additional locations
        if(contract.ZTS_US_NARC_ID__c != null){
            List<Account> addLocationAccnts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ZTS_US_Parent_NARC_ID__c, ZTS_EU_Account_Status__c, BillingStreet, BillingCity,                                              BillingState, BillingPostalCode, BillingCountry 
                                                        FROM Account WHERE ZTS_US_Parent_NARC_ID__c =:contract.ZTS_US_NARC_ID__c AND ZTS_EU_Market__c = 'United States' ORDER BY CreatedDate DESC];
            Integer counter = 0;
            string concatFields = '';
            
            for(Account acc : addLocationAccnts){
                tagName =  'L' + counter;
                concatFields = (concatFields == '') ? tagName : concatFields + seperator + tagName ;                
                AccWrapper awloc = new AccWrapper();
                awloc.Id = acc.Id;
                awloc.accName = acc.Name;
                awloc.address = acc.BillingStreet;
                awloc.cityStateZip = acc.BillingCity + ', ' + acc.BillingState + ', ' + acc.BillingPostalCode;
                awloc.NARC = acc.ZTS_US_NARC_ID__c;
                awloc.tagName = openBraces + referenceTag + tagName + closeBraces;
                addlLocations.add(awloc);
                adobeTags.add(openBraces + string.format(tagFormat, new String[]{tagName}) + closeBraces);
                
                counter++;
            }
            
            if(concatFields != ''){
                adobeTags.add(openBraces + string.format(calcFieldFormat, new String[]{concatFields, 'L0', 'delLoc'}) + closeBraces);                            
            }
        }
        
        
        
        //fetching suppliers and distributors 
        List<ZTS_EU_Account_Affiliations__c> affAccs = [Select Id, ZTS_US_Role__c, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__r.Name, ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c 
                                                        FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__r.Id = :contract.AccountId AND (ZTS_US_Role__c='Supplier' OR ZTS_US_Role__c = 'Distributor') AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ORDER BY CreatedDate DESC ]; 
        
        Integer suppCounter = 0, distCounter = 0;                                               
        string suppConcatFields = '', distConcatFields = '';
        
        for(ZTS_EU_Account_Affiliations__c affAcc : affAccs){
            if(affAcc.ZTS_US_Role__c != null && affAcc.ZTS_US_Role__c == 'Supplier'){
                tagName = 'S' + suppCounter;
                suppConcatFields = (suppConcatFields == '') ? tagName : suppConcatFields + seperator + tagName ;
                AccWrapper aw = new AccWrapper();
                aw.Id = affAcc.Id;
                aw.accName = affAcc.ZTS_EU_Affiliated_Account__r.Name;
                aw.cityStateZip = affAcc.ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c;
                aw.tagName= openBraces + referenceTag + tagName + closeBraces;
                suppliers.add(aw);
                adobeTags.add(openBraces + string.format(tagFormat, new String[]{tagName}) + closeBraces);
                suppCounter++;
            }else if(affAcc.ZTS_US_Role__c != null && affAcc.ZTS_US_Role__c == 'Distributor'){
                tagName = 'D' + distCounter;
                distConcatFields = (distConcatFields == '') ? tagName : distConcatFields + seperator + tagName ;
                AccWrapper aw = new AccWrapper();
                aw.Id = affAcc.Id;
                aw.accName = affAcc.ZTS_EU_Affiliated_Account__r.Name;
                aw.cityStateZip = affAcc.ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c;
                aw.tagName= openBraces + referenceTag + tagName + closeBraces;
                distributors.add(aw);
                adobeTags.add(openBraces + string.format(tagFormat, new String[]{tagName}) + closeBraces);
                distCounter++;
            } 
        }

        if(suppConcatFields != ''){
            adobeTags.add(openBraces + string.format(calcFieldFormat, new String[]{suppConcatFields, 'S0', 'delSup'}) + closeBraces);                  
        }
        if(distConcatFields != ''){
            adobeTags.add(openBraces + string.format(calcFieldFormat, new String[]{distConcatFields, 'D0', 'delDis'}) + closeBraces);                
        }    
            
    }  
    
    //below code is for manual submissoin
    webservice static String createAddendum(Id id){          
        String atId = 'No Template Found';
        String contractNumber = '';
        String validationMsg = '';
        try{ 
            //suppliers = new List<AccWrapper>();
            contractId = id;
            Contract contract = [select id,name,AccountId,Status,ZTS_US_Current_Tier__c,ContractNumber,Contract_Recipient__c,Primary_Business_Focus__c,ZTS_US_Field_Proposed_Tier__c 
                                 from Contract where Id = :contractId AND ZTS_EU_Market__c = 'United States' limit 1]; 
            contractNumber = contract.ContractNumber; 
            if(contract.Status == null || contract.Status != 'Proposal Approved'){
                validationMsg = 'Contract must be approved \n';
            } 
            
            echosign_dev1__Agreement_Template__c agTemplate = null;
            if(contract.ZTS_US_Field_Proposed_Tier__c == 'Veterinarian' || contract.ZTS_US_Field_Proposed_Tier__c == 'Animal Health Account'){
                agTemplate = [SELECT id FROM echosign_dev1__Agreement_Template__c 
                              WHERE Name like '%Veterinarian and Animal Health Account _Manual_%' LIMIT 1];     
            }else{
                String primaryBF = contract.Primary_Business_Focus__c;
                if(primaryBF != null && primaryBF == 'Pork'){
                    primaryBF = '%Pork%' ;
                }else{
                    primaryBF = '%Cattle%';
                }
                System.debug('....Primary Business Focus....' + primaryBF);
                String businessTier = '%' + contract.ZTS_US_Field_Proposed_Tier__c +'%';      
                System.debug('...ZTS_US_Field_Proposed_Tier__c......' + contract.ZTS_US_Field_Proposed_Tier__c);
                List<echosign_dev1__Agreement_Template__c> agTemplates = [SELECT id FROM echosign_dev1__Agreement_Template__c WHERE Name like :primaryBF AND Name LIKE :businessTier]; 
                if(agTemplates != null && agTemplates.size() > 0){
                    agTemplate = agTemplates[0];
                }else{
                    agTemplate = [SELECT id FROM echosign_dev1__Agreement_Template__c WHERE Name like '%Producers_Manual_%' LIMIT 1]; 
                }
                System.debug('...Agreement Template...' + agTemplate); 
            } 
            System.debug('...Agreement Template..' + agTemplate);
            if(agTemplate != null && agTemplate.Id != null){
                atId = agTemplate.Id;
            }else{
               validationMsg = 'No Agreement Template Found for this Contract \n'; 
            }
            System.debug(validationMsg.length() + '...validation message....' + validationMsg);
            if(validationMsg != null && validationMsg.length() > 5){
                return 'Following Errors must be corrected before submission: \n' + validationMsg;
            } 
            
            Attachment att = new Attachment();
            att.ParentId = Id;
            att.Name = contract.ContractNumber + ' - Addendum - ' + DateTime.now() + '.pdf';
            PageReference addDoc = Page.CreateAddendum;
            addDoc.getParameters().put('id',id);             
            Blob docContent;
            if (Test.IsRunningTest()) {
                docContent=Blob.valueOf('UNIT.TEST');
            }else {
                docContent = addDoc.getContent(); 
            } 
            att.Body = docContent;          
            insert att;                                   
            System.debug('Addendum created for contract: ' + contract.Name);                          
        }catch(Exception ex){ 
            System.debug('Unable to insert addendum for contract: ' + contractNumber);
            System.debug(ex.getMessage());  
        } 
        return atId;
    }      
    
    public class AccWrapper{
        public String accName {get;set;}
        public String address {get;set;}
        public String cityStateZip {get;set;}
        public String NARC {get;set;}
        public String Id {get;set;}
        public string tagName {get;set;}
        public AccWrapper(){
            
        }
    } 
    
}