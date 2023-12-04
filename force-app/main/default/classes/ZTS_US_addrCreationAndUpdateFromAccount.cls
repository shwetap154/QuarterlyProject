/*************************************************************************************************************************
Class Name     : ZTS_US_addrCreationAndUpdateFromAccount
Description    : This class is called from trigger on account for creation of Address record.
Created By     : Ninad
Created On     : 02/26/2014

Modification Log    :
-----------------------------------------------------------------------------------------------------------------------
Developer                            Date                   Description
---------                            ----                 -----------
Deloitte Constulting/Ninad Patil    02/26/2014              Created
Ketan Prakash Singh                 03/18/2014              Modified
Mayank Agarwal                      03/25/2014              Modified (added method updateAccConAffInactive,createAnimalCountFTE)
Raghu                               03/26/2014              Modified (added update Contact Addresses )
Cognizant Technology Solutions/Shiva01/04/2017              Modified (updateContactsAddress..added Pet Owner scenario to avoid contact address updation upon modification of account)
Laxmikanth                          01/09/2017              added updatecontractdetailschildaccounts methods
Cognizant Technology Solutions/Kaushik 19/05/2017              Modified (updateContactsAddress..added Equine Owner, Producer Owner scenario to avoid contact address updation upon modification of account)
Ethan Hirsch @ Zoetis Inc           01/09/2023              Update updateAddressRecord to exit early if chkUpdate is set to false.
                                                            This saves some processing time and SOQL limits as it won't do anything if this is set to false. (TPDEV-82)
Ethan Hirsch @ Zoetis Inc           01/18/2023              Update createAddressRecord, updateAddressRecord, updateAccConAffInactive, updateAccContactsAddress, and createAnimalCountFTE to use NebulaLogger
                                                            for logging errors to standardize the logging sytem. Also add a way to test unhandled exceptions in these methods (TPDEV-85)
********************************************************************************************************************************/
public class ZTS_US_addrCreationAndUpdateFromAccount
{
    public static boolean chkUpdate = true;
    @testVisible private static Boolean forceExceptionCreateAddressRecord = false;
    @testVisible private static Boolean caughtExceptionCreateAddressRecord = false;
    /***********
    * Method name  : createAddressRecord
    * Description  : This will create Address record on creation of Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    * 
    ***********/            
    public static void createAddressRecord(List<Account> triggerNew)
    {
        List<Address__C> listAdd = new List<Address__C>();
        String LINE_BREAK='\n';
        for(Account oAcc: triggerNew)
        {            
            // if Address ENtered on account is not null then carete corresponding Address record.
            if((oAcc.BillingStreet != Null) || (oAcc.BillingPostalCode != Null )||
            (oAcc.BillingState != Null) ||(oAcc.BillingCountry != Null)|| (oAcc.BillingCity != Null))
            {
                Address__C oAdd = new Address__c();
                if(!String.isBlank(oAcc.BillingStreet)){                    
                    String [] addressLines=oAcc.BillingStreet.split(LINE_BREAK);
                    if(addressLines.size()>0){
                        oAdd.ZTS_Address_Line_1__c = addressLines[0];
                        oAdd.ZTS_EU_Address_Line_2__c='';
                        for(Integer i=1;i<addressLines.size();i++){
                            oAdd.ZTS_EU_Address_Line_2__c+= addressLines[i]+LINE_BREAK;
                        }
                    }
                }
                
                oAdd.Zip_Postal_Code__c = oAcc.BillingPostalCode;
                oAdd.ZTS_US_State_Province__c = oAcc.BillingState;
                oAdd.ZTS_EU_Country__c = oAcc.BillingCountry;
                oAdd.ZTS_EU_City__c = oAcc.BillingCity;
                oAdd.ZTS_US_Primary__c = true;
                oAdd.ZTS_EU_Address_Type__c = 'Primary';
                oAdd.ZTS_EU_Account__c= oAcc.ID;
                listAdd.add(oAdd);
            }     
        }
        
        // Updating Address record list.
        if(!listAdd.isEmpty())
        {
            try
            { 
                if (forceExceptionCreateAddressRecord) {
                    integer y = 1 / 0;
                }
                ZTS_addrUpdateOnAccount.chkUpdate=false;
                List<Database.Saveresult> results=Database.insert(listAdd,false);
                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to create new Primary Addresses for the following Account(s). Please create Primary Addresses manually: {0}', 
                    triggerNew);

                Logger_Extension.errorLogIfSaveError(logMessage, listAdd, results);
            }
            catch(Exception e)
            {
                caughtExceptionCreateAddressRecord = true;
                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to create new Primary Addresses for the following Account(s). Please create Primary Addresses manually: {0}', 
                    triggerNew);

                Logger.error(logMessage, listAdd, e);
            }     
        }        
    } 
    
    /***********
    * Method name  : updateMZRchildaccounts
    * Description  : This will update MZR fields on Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/    
    public static void updatecontractdetailschildaccounts(Map<Id,Account> triggerNew)
    {
        Set<Account> allAccounts = new Set<Account>();
        Map<Account,List<Account>> acclist = new Map<Account,List<Account>>();
        List<Account> toBeupdated = new List<Account>();
        List<Account> allchilds = new List<Account>();
        List<Account> nextInLine = [SELECT Id,parentId FROM Account WHERE parentId IN:Triggernew.keyset() AND ZTS_EU_Market__c = 'United States'];
        Map<Id, List<Account>> parentChildMap =  New Map<Id,List<Account>>();
        
        for(Id accountId : triggerNew.keySet())
        parentChildMap.put(accountId,null);
        
        Boolean firstLevelRun = true;
        Account objAccount = null;
        List<Account> lstAccounts = null;
        
        while (!nextInLine.isEmpty())
        {
            for (Account child: nextInLine)
            {
                objAccount = new Account();
                objAccount.Id = child.Id;
                
                if(firstLevelRun && parentChildMap.containsKey(child.ParentId))
                {
                    if(parentChildMap.get(child.ParentId) == null)
                    {
                        lstAccounts = new list<Account>();
                        lstAccounts.add(objAccount);                        
                    }
                    else
                    {
                        lstAccounts = parentChildMap.get(child.ParentId);
                        lstAccounts.add(objAccount);
                    }
                    parentChildMap.put(child.ParentId, lstAccounts );                   
                }
                else
                {
                    for(Id accountId : parentChildMap.keyset())
                    {
                        lstAccounts = new list<Account>();
                        if(parentChildMap.get(AccountId) != null)
                        lstAccounts = parentChildMap.get(accountId);
                        
                        Boolean found = false;
                        if(!lstAccounts.isEmpty())
                        {
                            for(Account acc: lstAccounts)
                            {
                                if(acc.Id == child.ParentId)
                                {
                                    found = true;                               
                                    break;
                                }
                            }  
                        }
                        if(found)
                        lstAccounts.add(objAccount);    
                    }
                    
                }              
            }
            firstLevelRun = false;
            nextInLine = [SELECT Id,parentId FROM Account WHERE parentId IN :nextInLine AND ZTS_EU_Market__c = 'United States'];
        }
        
        for(Id accountid : parentChildMap.keySet())
        {
            Account ant = triggerNew.get(accountid);
            
            if(parentChildMap.get(accountid) != null)
            {
                List<Account> lstAccount =  parentChildMap.get(accountid);
                
                for(Account accId : lstAccount)
                {  
                    if(ant.MZR_Status__c=='Active'||ant.MZR_Status__c=='Un-enrolled in MZR')
                    {
                        accId.MZR_Accepted_Declined_Date__c=ant.MZR_Accepted_Declined_Date__c;
                        accId.MZR_Account__c=ant.MZR_Account__c;
                        accId.MZR_Decline_Additional_Notes__c=ant.MZR_Decline_Additional_Notes__c;
                        accId.MZR_Enrollment_Date__c=ant.MZR_Enrollment_Date__c;
                        accId.MZR_Reason_for_Not_Enrolling__c=ant.MZR_Reason_for_Not_Enrolling__c;
                        accId.MZR_Status__c=ant.MZR_Status__c;
                        accId.MZR_Tier__c=ant.MZR_Tier__c;
                    }
                    if(ant.ZTS_US_VGP_Enrollment_Status__c=='VGP Enrolled'||ant.ZTS_US_VGP_Enrollment_Status__c=='Un-enrolled in VGP')
                    {
                        accId.ZTS_US_VGP_Enrollment_Status__c=ant.ZTS_US_VGP_Enrollment_Status__c;
                        accId.VGP_Enrollment_Date__c=ant.VGP_Enrollment_Date__c;
                        accId.VGP_Accepted_Declined_Date__c=ant.VGP_Accepted_Declined_Date__c;
                    }
                    accId.ZTS_US_MVP_BIOS__c=ant.ZTS_US_MVP_BIOS__c;
                    accId.ZTS_US_MVP_Account__c=ant.ZTS_US_MVP_Account__c;
                    toBeupdated.add(accId);
                }
            }
        }
        update toBeupdated;
    }  
    
    
    /***********
    * Method name  : updateAccountContractDetails
    * Description  : This will update contract details on Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/    
    public static void updateAccountContractDetails(List<Account> triggerNew)
    {
        
        Set <Id> setParentIds= new Set<Id>();
        for(Account acc:triggerNew)
        setParentIds.add(acc.ParentId);
        
        Map<Id,Account> mapAccount = new Map<Id,Account>([Select Id,ZTS_US_Contract_Tier__c,MZR_Accepted_Declined_Date__c,MZR_Account__c, MZR_Account_data_change__c,MZR_Decline_Additional_Notes__c,MZR_Enrollment_Date__c,ZTS_US_MVP_BIOS__c,ZTS_US_MVP_Account__c,
        MZR_Enrollment_Experience__c,MZR_Feedback__c,MZR_Reason_for_Not_Enrolling__c,MZR_Status__c,MZR_Tier__c,VGP_Accepted_Declined_Date__c,VGP_Enrollment_Date__c,ZTS_US_VGP_Enrollment_Status__c from Account where Id in :setParentIds AND ZTS_EU_Market__c = 'United States']);
        List<Account> Acctobeupdated = new List<Account>(); 
        
        for(Account acc:triggerNew)
        {
            Account ac = new Account(Id = acc.Id);
            
            if(mapAccount.containsKey(acc.ParentId))
            {
                ac.ZTS_US_Contract_Tier__c=mapAccount.get(acc.ParentId).ZTS_US_Contract_Tier__c;
                if(mapAccount.get(acc.ParentId).MZR_Status__c=='Active'||mapAccount.get(acc.ParentId).MZR_Status__c=='Un-enrolled in MZR')
                {
                    ac.MZR_Accepted_Declined_Date__c=mapAccount.get(acc.ParentId).MZR_Accepted_Declined_Date__c;
                    ac.MZR_Account__c=mapAccount.get(acc.ParentId).MZR_Account__c;
                    ac.MZR_Decline_Additional_Notes__c=mapAccount.get(acc.ParentId).MZR_Decline_Additional_Notes__c;
                    ac.MZR_Enrollment_Date__c=mapAccount.get(acc.ParentId).MZR_Enrollment_Date__c;
                    ac.MZR_Reason_for_Not_Enrolling__c=mapAccount.get(acc.ParentId).MZR_Reason_for_Not_Enrolling__c;
                    ac.MZR_Status__c=mapAccount.get(acc.ParentId).MZR_Status__c;
                    ac.MZR_Tier__c=mapAccount.get(acc.ParentId).MZR_Tier__c;
                }
                else
                {
                    ac.MZR_Accepted_Declined_Date__c=null;
                    ac.MZR_Account__c=false;
                    ac.MZR_Decline_Additional_Notes__c=null;
                    ac.MZR_Enrollment_Date__c=null;
                    ac.MZR_Reason_for_Not_Enrolling__c=null;
                    ac.MZR_Status__c='Not Eligible';
                    ac.MZR_Tier__c=null;
                }
                if(mapAccount.get(acc.ParentId).ZTS_US_VGP_Enrollment_Status__c=='VGP Enrolled'||mapAccount.get(acc.ParentId).ZTS_US_VGP_Enrollment_Status__c=='Un-enrolled in VGP')
                {
                    ac.ZTS_US_VGP_Enrollment_Status__c=mapAccount.get(acc.ParentId).ZTS_US_VGP_Enrollment_Status__c;
                    ac.VGP_Enrollment_Date__c=mapAccount.get(acc.ParentId).VGP_Enrollment_Date__c;
                    ac.VGP_Accepted_Declined_Date__c=mapAccount.get(acc.ParentId).VGP_Accepted_Declined_Date__c;
                }
                else
                {
                    ac.ZTS_US_VGP_Enrollment_Status__c=null;
                    ac.VGP_Enrollment_Date__c=null;
                    ac.VGP_Accepted_Declined_Date__c=null;
                }
                ac.ZTS_US_MVP_BIOS__c=mapAccount.get(acc.ParentId).ZTS_US_MVP_BIOS__c;
                ac.ZTS_US_MVP_Account__c=mapAccount.get(acc.ParentId).ZTS_US_MVP_Account__c;                                              
            }
            Acctobeupdated.add(ac);
        }
        if(!Acctobeupdated.isEmpty())
        update(Acctobeupdated);
    }
    
    /***********
    * Method name  : updatenullvaluesonchildaccounts
    * Description  : This will update contract fields on Account when Parent Account is blanked out.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/    
    public static void updatenullvaluesonchildaccounts(Map<Id,Account> triggerNew)
    {
        /******Modified by: Poonam- Variables not used anywhere.*******************/
        /*Set<Account> allAccounts = new Set<Account>();
        List<Account> toBeupdated = new List<Account>();
        Map<Id, List<Account>> parentChildMap =  New Map<Id,List<Account>>();*/
        
        for(Account acc : triggerNew.Values())
        {
            //parentChildMap.put(acc.Id,null);
            acc.ZTS_US_Contract_Tier__c=null;
            acc.MZR_Accepted_Declined_Date__c=null;
            acc.MZR_Account__c=false;
            acc.MZR_Decline_Additional_Notes__c=null;
            acc.MZR_Enrollment_Date__c=null;
            acc.MZR_Reason_for_Not_Enrolling__c=null;
            acc.MZR_Status__c='Eligible';
            acc.MZR_Tier__c=null;
            acc.ZTS_US_VGP_Enrollment_Status__c=null;
            acc.VGP_Enrollment_Date__c=null;
            acc.VGP_Accepted_Declined_Date__c=null;
            acc.ZTS_US_MVP_BIOS__c=null;
            acc.ZTS_US_MVP_Account__c=false;
        }
        
    }   
    
    /** Defect - SC-002486 - saipraneeth ****
    * Method name  : updatecontractparentvaluesonchildaccounts
    * Description  : This will update contract fields from parent to child Account when an account added as Child account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/ 
    public static void updatecontractparentvaluesonchildaccounts(list<Account> triggerNew1)
    {
        Set<Id> setParentId = new Set<Id>();
        
        for(Account acc:triggerNew1)
        setParentId.add(acc.ParentId);
        
        Map<Id,Account> ParentDetailsMap = new Map<Id,Account>([select id, ZTS_US_Contract_Tier__c, MZR_Accepted_Declined_Date__c, MZR_Account__c, MZR_Decline_Additional_Notes__c, MZR_Enrollment_Date__c, MZR_Reason_for_Not_Enrolling__c, MZR_Status__c, MZR_Tier__c,
        ZTS_US_VGP_Enrollment_Status__c, VGP_Enrollment_Date__c, VGP_Accepted_Declined_Date__c, ZTS_US_MVP_BIOS__c, ZTS_US_MVP_Account__c From Account where id in :setParentId AND ZTS_EU_Market__c = 'United States']);
        
        List<Account> UpdateFinalList = new List<Account>();
        
        for(Account account : triggerNew1)
        {
            Account currchildacc = new account(Id = account.Id);
            if(ParentDetailsMap.containsKey(account.ParentId))
            {
                currchildacc.ZTS_US_Contract_Tier__c = ParentDetailsMap.get(account.ParentId).ZTS_US_Contract_Tier__c;
                currchildacc.MZR_Accepted_Declined_Date__c = ParentDetailsMap.get(account.ParentId).MZR_Accepted_Declined_Date__c;
                currchildacc.MZR_Account__c = ParentDetailsMap.get(account.ParentId).MZR_Account__c;
                currchildacc.MZR_Decline_Additional_Notes__c = ParentDetailsMap.get(account.ParentId).MZR_Decline_Additional_Notes__c;
                currchildacc.MZR_Enrollment_Date__c = ParentDetailsMap.get(account.ParentId).MZR_Enrollment_Date__c;
                currchildacc.MZR_Reason_for_Not_Enrolling__c = ParentDetailsMap.get(account.ParentId).MZR_Reason_for_Not_Enrolling__c;
                currchildacc.MZR_Status__c = ParentDetailsMap.get(account.ParentId).MZR_Status__c;
                currchildacc.MZR_Tier__c = ParentDetailsMap.get(account.ParentId).MZR_Tier__c;
                
                currchildacc.ZTS_US_VGP_Enrollment_Status__c = ParentDetailsMap.get(account.ParentId).ZTS_US_VGP_Enrollment_Status__c;
                currchildacc.VGP_Enrollment_Date__c = ParentDetailsMap.get(account.ParentId).VGP_Enrollment_Date__c;
                currchildacc.VGP_Accepted_Declined_Date__c = ParentDetailsMap.get(account.ParentId).VGP_Accepted_Declined_Date__c;
                
                currchildacc.ZTS_US_MVP_BIOS__c = ParentDetailsMap.get(account.ParentId).ZTS_US_MVP_BIOS__c;
                currchildacc.ZTS_US_MVP_Account__c = ParentDetailsMap.get(account.ParentId).ZTS_US_MVP_Account__c;
            } 
            UpdateFinalList.add(currchildacc);
        }
        if(!UpdateFinalList.isEmpty()){
            update(UpdateFinalList);
        }
        
    }
    
    @testVisible private static Boolean forceExceptionUpdateAddressRecord = false;
    @testVisible private static Boolean caughtExceptionUpdateAddressRecord = false;
    /***********
    * Method name  : updateAddressRecord
    * Description  : This will update Address record on updation of Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public static void updateAddressRecord(List<Account> triggerNew,Map<ID,Account> triggerOldMap)
    {
        // If chkUpdate is false, no Addresses will be added to lstAddrToUpdate.
        // Therefore, this method can exit early if it's false.
        if (!chkUpdate) {
            return;
        }

        Set<Id> setAccId = new Set<Id>();
        Map<Id,Address__c> mapAccIdAndAddr = new Map<Id,Address__c>();
        List<Address__c> lstAddrToUpdate = new List<Address__c>();
        String LINE_BREAK='\n';
        
        for(Account acc: triggerNew)
        {
            if( (acc.BillingStreet != triggerOldMap.get(acc.id).BillingStreet ) 
            || (acc.BillingPostalCode != triggerOldMap.get(acc.id).BillingPostalCode )
            ||(acc.BillingState != triggerOldMap.get(acc.id).BillingState ) 
            || (acc.BillingCountry != triggerOldMap.get(acc.id).BillingCountry ) 
            || (acc.BillingCity != triggerOldMap.get(acc.id).BillingCity ))
            setAccId.add(acc.Id);
        }
        List<Address__c> lstAddr = [Select a.Zip_Postal_Code__c, a.ZTS_US_Street__c, a.ZTS_Address_Line_1__c, a.ZTS_EU_Address_Line_2__c, a.ZTS_US_State_Province__c, a.ZTS_US_Primary__c, a.ZTS_EU_Country__c, a.ZTS_EU_City__c, a.ZTS_EU_Account__c From Address__c a
        where a.ZTS_EU_Account__c in :setAccId and a.ZTS_US_Primary__c = true];
        for(Address__c addr: lstAddr)
        mapAccIdAndAddr.put(addr.ZTS_EU_Account__c,addr); 
        
        for(Account acc: triggerNew)
        {
            if((acc.BillingStreet != triggerOldMap.get(acc.id).BillingStreet ) || (acc.BillingPostalCode != triggerOldMap.get(acc.id).BillingPostalCode )||(acc.BillingState != triggerOldMap.get(acc.id).BillingState ) ||
            (acc.BillingCountry != triggerOldMap.get(acc.id).BillingCountry )|| (acc.BillingCity != triggerOldMap.get(acc.id).BillingCity ))
            {
                if(mapAccIdAndAddr.containsKey(acc.Id) && mapAccIdAndAddr.get(acc.Id) != null && chkUpdate)
                {
                    Address__c addr = new Address__c();
                    addr = mapAccIdAndAddr.get(acc.Id);
                    
                    if(String.isNotBlank(acc.BillingStreet))
                    {
                        String [] addressLines=acc.BillingStreet.split(LINE_BREAK);
                        if(!addressLines.isEmpty())
                        {
                            addr.ZTS_Address_Line_1__c = addressLines[0];
                            addr.ZTS_EU_Address_Line_2__c='';
                            
                            for(Integer i=1;i<addressLines.size();i++)
                            addr.ZTS_EU_Address_Line_2__c+= addressLines[i]+LINE_BREAK;
                        }
                    }
                    else
                    {
                        addr.ZTS_Address_Line_1__c = '';
                        addr.ZTS_EU_Address_Line_2__c = '';
                    }
                    addr.Zip_Postal_Code__c = acc.BillingPostalCode;
                    addr.ZTS_US_State_Province__c = acc.BillingState;
                    addr.ZTS_EU_Country__c = acc.BillingCountry;
                    addr.ZTS_EU_City__c = acc.BillingCity;
                    lstAddrToUpdate.add(addr);
                }
            }
        }
        try
        { 
            if (forceExceptionUpdateAddressRecord) {
                integer y = 1 / 0;
            }
            chkUpdate = false;
            ZTS_addrUpdateOnAccount.chkUpdate=false;
            List<Database.Saveresult> results=Database.update(lstAddrToUpdate,false);
            
            LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                'Failed to sync Account Address details to Primary Address. Please review the following Address(es) to sync Address details manually: {0}',
                lstAddrToUpdate);

            Logger_Extension.errorLogIfSaveError(logMessage, lstAddrToUpdate, results);
        }
        catch(Exception e)
        {
            caughtExceptionUpdateAddressRecord = true;
            LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                'Failed to sync Account Address details to Primary Address. Please review the following Account(s), or Addresses if output, to sync Address manually: {0}',
                triggerNew);

            Logger.error(logMessage, lstAddrToUpdate, e);
        }     
    }
    
    @testVisible private static Boolean forceExceptionUpdateAccConAffInactive = false;
    @testVisible private static Boolean caughtExceptionUpdateAccConAffInactive = false;
    /***********
    * Method name  : updateAccConAffInactive
    * Description  : If an Account is Inactivated, then all Account Contact Affiliations for that Account is updated to Status = Inactive
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public static void updateAccConAffInactive(List<Account> triggerNew)
    {
        Set<Id> inactiveAccIds =  new Set<Id>();
        for(Account acc: triggerNew)
        {
            if(acc.ZTS_EU_Account_Status__c == ZTS_GlobalConstants.INACTIVE_STATUS)
            inactiveAccIds.add(acc.Id);
        }
        
        List<ZTS_EU_Affiliations__c> accConAffListToUpdate =  new List<ZTS_EU_Affiliations__c>();
        List<ZTS_EU_Affiliations__c> accConAffList =  new List<ZTS_EU_Affiliations__c>();
        
        if(!inactiveAccIds.isEmpty())
        accConAffList = [Select Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c From ZTS_EU_Affiliations__c where ZTS_EU_Account__c IN: inactiveAccIds AND ZTS_EU_Market_from_Parent__c = 'United States' ];
        
        if(!accConAffList.isEmpty())
        {
            for(ZTS_EU_Affiliations__c accConAff : accConAffList)
            {
                accConAff.ZTS_EU_Affiliation_Status__c = ZTS_GlobalConstants.INACTIVE_STATUS;
                accConAffListToUpdate.add(accConAff);
            }
            try
            { 
                if (forceExceptionUpdateAccConAffInactive) {
                    integer y = 1/0;
                }
                List<Database.Saveresult> results=Database.update(accConAffListToUpdate,false);

                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to change Status on Affiliations to Inactive. Please review the following Affiliations to confirm they are Inactive: {0}', 
                    accConAffListToUpdate);
                    
                Logger_Extension.errorLogIfSaveError(logMessage, accConAffListToUpdate, results);
            }
            catch(Exception e)
            {
                caughtExceptionUpdateAccConAffInactive = true;
                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to change Status on Affiliations to Inactive. Please review the following Affiliations to confirm they are Inactive: {0}', 
                    accConAffListToUpdate);

                Logger.error(logMessage, e).setRecord(accConAffListToUpdate);
            }     
        }
    }
    
    
    /***********
    * Method name  : updateAccountContactAddress
    * Description  : If an Account Billing Address,then all Contacts Address for that Accounts is updated
    * Return Type  : None.
    * Parameters   : Account List.
    ***********/
    public static void updateAccContactsAddress(Map<Id,Account> oldAccMap, Map<Id, Account> mapAccountNew)
    {
        Set<Id> accIds =  new Set<Id>();
        
        for(Account acc: mapAccountNew.values())
        {
            if(oldAccMap.get(acc.Id) != null && (oldAccMap.get(acc.Id).BillingCity!=acc.BillingCity || oldAccMap.get(acc.Id).BillingStreet!=acc.BillingStreet || oldAccMap.get(acc.Id).BillingCountry!=acc.BillingCountry ||  
            oldAccMap.get(acc.Id).BillingState!=acc.BillingState  || oldAccMap.get(acc.Id).BillingPostalCode!=acc.BillingPostalCode))
            accIds.add(acc.Id);
        }
        
        //Map<Id,Account> acc_map=new Map<Id,Account>(newaccountList);
        List<Contact> modifycontactList =  new List<Contact>();
        
        if(!accIds.isEmpty())
        {
            List<Contact> contactList = [SELECT AccountId, Id, MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode 
            FROM Contact WHERE AccountId IN :accIds AND ZTS_EU_Market__c = 'United States'];
            
            for(Contact con:contactList)
            {
                Account acc=mapAccountNew.get(con.AccountId);
                
                if(isAddressChanged(oldAccMap.get(acc.Id),acc))
                {
                    con.MailingCity=acc.BillingCity;
                    con.MailingCountry=acc.BillingCountry;
                    con.MailingState=acc.BillingState;
                    con.MailingStreet=acc.BillingStreet;
                    con.MailingPostalCode=acc.BillingPostalCode;
                    modifycontactList.add(con);
                }
            }
        }
        if(!modifycontactList.isEmpty())
        {
            // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 			Database.DMLOptions dml = new Database.DMLOptions(); 
 			dml.DuplicateRuleHeader.allowSave = true;
 			dml.DuplicateRuleHeader.runAsCurrentUser = true;
            dml.OptAllOrNone = false;
            List<Database.Saveresult> results=Database.update(modifycontactList,dml);
            //List<Database.Saveresult> results=Database.update(modifycontactList,false);-- commented for SC-008149

            LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                'Failed to sync Address details from Account to Contact. Please review the following Contact(s) to confirm their Address matches the Account: {0}',
                modifycontactList);

            Logger_Extension.errorLogIfSaveError(logMessage, modifycontactList, results);
        }
    }
    
    
    
    /***********
    * Method name  : updateAContactAddress
    * Description  : If an Account Billing Address,then all Contacts Address for that Accounts is updated
    * Return Type  : None.
    * Parameters   : Account List.
    ***********/
    public static void updateContactsAddress(List<Contact> newcontactlist,Map<Id,Contact> oldcontactMap){
        //Accessing PetOwner record type
        Id petOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_Pet_Owner').getRecordTypeId();
        Id producerOwnerContactRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Producer_Account').getRecordTypeId();
        Id equineOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_SER_Equine_Account').getRecordTypeId();
        List<Contact> filteredContactList = new List<Contact>();
        Set<Id> accIds =  new Set<Id>();
        for(Contact con: newcontactlist){
            //Access those contacts which are not PetOwner,Producer Owner,Equine Owner
            
            if((con.RecordTypeId != petOwnerContactRecTypeId) 
            && (con.RecordTypeId != producerOwnerContactRecTypeId) && (con.RecordTypeId != equineOwnerContactRecTypeId)){
                filteredContactlist.add(con);
                if(con.accountId!=null){
                    accIds.add(con.accountId);
                }
            }
        }
        
        if(!accIds.isEmpty()){
            Map<Id,Account> acc_map =new Map<Id,Account>([SELECT Id, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode FROM Account WHERE Id IN :accIds AND ZTS_EU_Market__c = 'United States']);
            
            for(Contact con:filteredContactlist){
                if(con.accountId!=null){
                    Account acc=acc_map.get(con.accountId);
                    con.MailingCity=acc.BillingCity;
                    if(!String.isBlank(acc.BillingCountry)){
                        con.MailingCountry=acc.BillingCountry;
                        con.MailingState=acc.BillingState;
                    }
                    
                    else{
                        con.MailingCountry=null;
                        con.MailingState=null;
                    }
                    con.MailingStreet=acc.BillingStreet;
                    con.MailingPostalCode=acc.BillingPostalCode;
                }
                
                else{
                    con.MailingCity='';
                    con.MailingCountry=null;
                    con.MailingState=null;
                    con.MailingStreet='';
                    con.MailingPostalCode='';
                }
                
            }
        }
    }
    
    
    
    
    /***********
    * Method name  : isAddressChanged
    * Description  : This method  compares old and new Account record for Address changes.
    * Return Type  : boolean.
    * Parameters   : Old Account and New Account record.
    ***********/
    private static boolean isAddressChanged(Account oldAcc,Account newAcc){
        
        boolean changed=false;
        /** TEMP FORCE UPDATE 
        boolean FORCE_UPDATE=true;
        changed=FORCE_UPDATE;
        **/
        if((oldAcc.BillingCity!=newAcc.BillingCity || oldAcc.BillingStreet!=newAcc.BillingStreet || oldAcc.BillingCountry!=newAcc.BillingCountry ||  
        oldAcc.BillingState!=newAcc.BillingState  || oldAcc.BillingPostalCode!=newAcc.BillingPostalCode)){
            changed=true;
        }
        return changed;
        
    }
    
    @testVisible private static Boolean forceExceptionCreateAnimalCountFTE = false;
    @testVisible private static Boolean caughtExceptionCreateAnimalCountFTE = false;
    /***********
    * Method name  : createAnimalCountFTE
    * Description  : Creation of Animal Count and FTE records based on Business Class value on Account Creation
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public static void createAnimalCountFTE(List<Account> triggerNew){
        
        List<ZTS_Animal_Count_Potential__c> listAnimalCountFTE = new List<ZTS_Animal_Count_Potential__c>();
        //since two records needs to be created with different record types so declaring two instances.
        Map<String, Id> mapRecordType = new Map<String, ID>();
        
        for(RecordType oRec: [select Id, Name from RecordType where SobjectType = 'ZTS_Animal_Count_Potential__c'])
        mapRecordType.put(oRec.Name, oRec.Id);
        
        Set<Id> accIds =  new Set<Id>();
        for(Account oAcc: triggerNew)
        {
            ZTS_Animal_Count_Potential__c oAnimalCountFTE1 = new ZTS_Animal_Count_Potential__c();
            ZTS_Animal_Count_Potential__c oAnimalCountFTE2 = new ZTS_Animal_Count_Potential__c();
            if(oAcc.ZTS_US_Business_Class__c == ZTS_GlobalConstants.ACCNT_BUSINESSCLASS_PRODUCERS || oAcc.ZTS_US_Business_Class__c == ZTS_GlobalConstants.ACCNT_BUSINESSCLASS_SELECTPRODUCER ||
            oAcc.ZTS_US_Business_Class__c == ZTS_GlobalConstants.ACCNT_BUSINESSCLASS_STRATEGICPRODUCER)
            {
                oAnimalCountFTE1.ZTS_EU_Account__c = oAcc.Id;
                oAnimalCountFTE1.ZTS_Bypass_Val_Rule__c = true ;
                oAnimalCountFTE1.RecordTypeId = mapRecordType.get(ZTS_GlobalConstants.RECTYPE_CATTLECOUNT);
                oAnimalCountFTE2.ZTS_EU_Account__c = oAcc.Id;
                oAnimalCountFTE2.ZTS_Bypass_Val_Rule__c = true ;
                oAnimalCountFTE2.RecordTypeId = mapRecordType.get(ZTS_GlobalConstants.RECTYPE_PORKCOUNT);
                listAnimalCountFTE.add(oAnimalCountFTE1);
                listAnimalCountFTE.add(oAnimalCountFTE2);
            }
            else if(oAcc.ZTS_US_Business_Class__c == ZTS_GlobalConstants.ACCNT_BUSINESSCLASS_VETERINARIAN)
            {
                oAnimalCountFTE1.ZTS_EU_Account__c = oAcc.Id;
                oAnimalCountFTE1.ZTS_Bypass_Val_Rule__c = true ;
                oAnimalCountFTE1.RecordTypeId = mapRecordType.get(ZTS_GlobalConstants.RECTYPE_EQUINECOUNT);
                oAnimalCountFTE2.ZTS_EU_Account__c = oAcc.Id;
                oAnimalCountFTE2.ZTS_Bypass_Val_Rule__c = true ;
                oAnimalCountFTE2.RecordTypeId = mapRecordType.get(ZTS_GlobalConstants.RECTYPE_VETFTE);
                listAnimalCountFTE.add(oAnimalCountFTE1);
                listAnimalCountFTE.add(oAnimalCountFTE2);
            }
        }
        if(!listAnimalCountFTE.isEmpty())
        {
            try{ 
                if (forceExceptionCreateAnimalCountFTE) {
                    integer y = 1 /0;
                }
                List<Database.Saveresult> results=Database.insert(listAnimalCountFTE,false);

                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to create Animal Count Potentials for the following Accounts. Please review the Accounts and determine if they need an Animal Count FTE: {0}',
                    triggerNew);

                Logger_Extension.errorLogIfSaveError(logMessage, listAnimalCountFTE, results);
            }
            catch(Exception e)
            {
                caughtExceptionCreateAnimalCountFTE = true;
                LogMessage logMessage = Logger_Extension.buildLogMessageWithRecordIdList(
                    'Failed to create Animal Count Potentials for the following Accounts. Please review the Accounts and determine if they need an Animal Count FTE: {0}',
                    triggerNew);

                Logger.error(logMessage, listAnimalCountFTE, e);
            }     
        }
    }
}