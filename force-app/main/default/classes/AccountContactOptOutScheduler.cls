/*******************************************************************************************************************************************
* Class Name   : AccountContactOptOutScheduler
* Description  : This Batch class sends out emails to the NARC Team about Accounts that share emails with Contacts 
				 that have opted out of Global Email Communications
*     
* Created By   : Cognizant
*
* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                          Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Cognizant                  		??           		 Created
* Slalom / Mohamed                  0‎3/11/2020           Modified to segment contacts and accounts that are US 
*****************************************************************************************************************************************/

global class AccountContactOptOutScheduler implements Database.Batchable<SObject>, Schedulable, Database.Stateful 
{
    global List<NARC_Opt_Outs__c> accOptOutNarcs = new List<NARC_Opt_Outs__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {  
        return Database.getQueryLocator(
            							[SELECT Id,LastModifiedDate,Interface_Email__c,Interface_Email_Opt_Out__c 
                                         FROM Contact 
                                         WHERE LastModifiedDate = TODAY 
                                         AND Interface_Email__c != Null 
                                         AND ZTS_EU_Market__c = 'United States'
                                         AND (Interface_Email_Opt_Out__c = True OR ZTS_US_Portal_Email_Opt_Out__c = True)
                                        ]
                                       );
        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts) 
    {
        Set<String> contEmails = new Set<String>();
        for(Contact c: contacts)
        {
            contEmails.add(c.Interface_Email__c);
        } 
        
        for(Account a : [SELECT Id, Name, ZTS_US_Email_Opt_Out__c,Email__c, ZTS_US_NARC_ID__c 
                         FROM Account 
                         WHERE ZTS_US_Email_Opt_Out__c = False 
                         AND ZTS_US_NARC_ID__c !=Null
                         AND ZTS_EU_Market__c = 'United States'
                         AND Email__c IN :contEmails
                        ]
           )
        {                                
            NARC_Opt_Outs__c noo = new NARC_Opt_Outs__c();
            noo.Account_Id__c = a.Id;
            noo.NARC_Id__c = a.ZTS_US_NARC_ID__c;     
            noo.Matching_Email__c = a.Email__c;
            accOptOutNarcs.add(noo);                                       
        }
        
    }
    
    global void finish(Database.BatchableContext BC) 
    {        
        try
        {
            Database.insert(accOptOutNarcs, false);
        }
        catch(DMLException ex)
        {
            System.debug('Error inserting NARC_Opt_Outs__c records:' + ex);
        } 
        
        List<NARC_Opt_Outs__c> noos = [SELECT NARC_Id__c,CreatedDate,Matching_Email__c 
                                       FROM NARC_Opt_Outs__c 
                                       WHERE CreatedDate = TODAY
                                      ];
        
        if(noos != null && noos.size()>0)
        {
            String narcs = '';
            
            for(NARC_Opt_Outs__c ns: noos )
            {
                narcs = narcs + ns.NARC_Id__c + ' - ' + ns.Matching_Email__c + '\n';
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            List<String> narcToEmailIds = new List<String>();  
            
            if(NARC_Team_Email__c.getOrgDefaults() != null && NARC_Team_Email__c.getOrgDefaults().To_Emails__c != null)
            {
                narcToEmailIds = NARC_Team_Email__c.getOrgDefaults().To_Emails__c.split(','); 
            }
            
            mail.setToAddresses(narcToEmailIds);
            List<String> narcCCemailIds = new List<String>();  
            
            if(NARC_Team_Email__c.getOrgDefaults() != null && NARC_Team_Email__c.getOrgDefaults().CC_Emails__c != null)
            {
                narcCCemailIds = NARC_Team_Email__c.getOrgDefaults().CC_Emails__c.split(','); 
            }
            
            mail.setToAddresses(narcToEmailIds);
            mail.setReplyTo('shivashankar.kudikilla@cognizant.com');  
            mail.setCcAddresses(narcCCemailIds);
            mail.setSenderDisplayName('TouchPoint Batch Job');
            mail.setSubject('Today\'s List of Email-Opt-Opt NARCs');
            String body = 'NARC Team, \n A contact sharing the same email has opted out of Global email communications. Please make sure to update the NARC level email as opt out so that we do not communicate to them via email moving forward.\n Below is the list of Account NARCs who are opted out of Emails:\n\n';
            body = body + narcs ;
            body = body + '\n Thank you, \n TouchPoint CRM Team';
            mail.setPlainTextBody(body);
            
            if(!Test.isRunningTest())
            {
            	Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});      
            }            
        } 
    }
    
    public void execute (SchedulableContext sc) 
    { 
        Database.executebatch(new AccountContactOptOutScheduler());
    }
}