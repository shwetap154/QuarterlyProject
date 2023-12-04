/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_Owner_Expiration_Notice
* Description   :  This batch queries all the records from the object 'Contract' and checking owner expiration date based on that it will sent
                    an email to the contract owner.                          

* @author       :   CloudSense (Srinivas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     2nd-Apr-15   Srinivas             Created the class.

********************************************************************************************************************************************/

global class ZTS_EU_Batch_Owner_Expiration_Notice implements Database.Batchable<sObject>
{
    //Query on contracts to get all the contracts  
     string query='Select Id,ContractNumber,OwnerExpirationNotice,OwnerId, Owner.Name, Owner.email,ZTS_EU_End_Date__c'+
                        +' From contract'
                        +' WHERE ZTS_EU_End_Date__c!=null AND ZTS_EU_Market__c != \'United States\'';
    //start Method
    
    global Database.queryLocator start(Database.BatchableContext bc) {   
           //system.debug('query====>'+query);
            return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<contract> contLst) {
         //system.debug('execute====>');
        List<contract> lstContract=new List<Contract>();
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        //EmailTemplate emailTemplate = [select Id, Body  from EmailTemplate where DeveloperName = 'Notify_Contract_Expiration_to_Contract_Owner'];
        
        for(contract cont: contLst){ 
            //system.debug('cont.OwnerExpirationNotice====>'+cont.OwnerExpirationNotice);
            if(cont.OwnerExpirationNotice!=null){
                Integer days = Integer.valueof(cont.OwnerExpirationNotice);
                //system.debug('days====>'+days);
                if(system.today().adddays(days)==cont.ZTS_EU_End_Date__c){                
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setToAddresses(new String[] {cont.Owner.Email});
                            email.setSaveAsActivity(false);
                            string body= '<html> <body> Dear ' + cont.Owner.Name + ',<br><br> ' + 

'The contract ' + Cont.ContractNumber + ' will get expired on ' + String.valueOf(Cont.ZTS_EU_End_Date__c) + ' Please work on Contract '+ Cont.ContractNumber +'.<br><br> ' +

'This is an automatic email, please do not reply. In case of issues, please contact your local helpdesk. </body></html>';
                            email.setHtmlBody(body);
                            allMails.add(email);
                            //cont.OwnerExpirationNotice_Checkbox__c=true;
                            //lstContract.add(cont); 
                            
                }
        }
    }
        if(!allMails.isEmpty()){
            //system.debug('allMails====>'+allMails);
            Messaging.sendEmail(allMails);
            //Update lstContract;
        }
    }
    global void finish(Database.BatchableContext bc) {
        
    }
    
}