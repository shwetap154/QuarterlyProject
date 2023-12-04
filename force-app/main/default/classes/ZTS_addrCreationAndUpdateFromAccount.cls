/*************************************************************************************************************************
  Class Name     : ZTS_addrCreationAndUpdateFromAccount
  Description    : This class is called from trigger on account for creation of Address record.
  Created By     : Ninad
  Created On     : 02/26/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
 * Thomas Glaess         Feb 16, 2019                       Created
 * Aritra (Cognizant)    Mar 04, 2019                       Added the name split and Vetsave functionality as per system change (SC-004119)
 * Avinash (Cognizant)   May 20, 2019            Added the name split on update as per system change (SC-004328

***************************************************************************************************************************/
public class ZTS_addrCreationAndUpdateFromAccount
{
    public static boolean chkUpdate = true;
    /***********
    * Method name  : createAddressRecord
    * Description  : This will create Address record on creation of Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    * 
    ***********/            
    
    
   
     /***********
    * Method name  : updateAddressRecord
    * Description  : This will update Address record on updation of Account.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public static void updateAddressRecord(List<Account> triggerNew,Map<ID,Account> triggerOldMap)
    {
        Set<Id> setAccId = new Set<Id>();
        Map<Id,Address__c> mapAccIdAndAddr = new Map<Id,Address__c>();
        List<Address__c> lstAddrToUpdate = new List<Address__c>();
        String LINE_BREAK='\n';

        System.debug(' chkUpdate ::: '+chkUpdate);

        for(Account acc: triggerNew)
        {
            System.debug('old street :'+triggerOldMap.get(acc.id));
            System.debug('new street :'+acc.BillingStreet);
            if( (acc.BillingStreet != triggerOldMap.get(acc.id).BillingStreet ) || (acc.BillingPostalCode != triggerOldMap.get(acc.id).BillingPostalCode )||(acc.BillingState != triggerOldMap.get(acc.id).BillingState ) || (acc.BillingCountry != triggerOldMap.get(acc.id).BillingCountry )|| (acc.BillingCity != triggerOldMap.get(acc.id).BillingCity ))
             setAccId.add(acc.Id);
        }
        List<Address__c> lstAddr = [Select a.Zip_Postal_Code__c, a.ZTS_EU_Street__c, a.ZTS_Address_Line_1__c, a.ZTS_EU_Address_Line_2__c, a.State_Province__c, a.ZTS_EU_Primary__c, a.ZTS_EU_Country__c, a.ZTS_EU_City__c, a.ZTS_EU_Account__c From Address__c a
                                      where a.ZTS_EU_Account__c in :setAccId and a.ZTS_EU_Primary__c = true];
        System.debug('address record :'+lstAddr);
        for(Address__c addr: lstAddr)
           mapAccIdAndAddr.put(addr.ZTS_EU_Account__c,addr); 

        for(Account acc: triggerNew)
        {

            if((acc.BillingStreet != triggerOldMap.get(acc.id).BillingStreet )|| (acc.BillingPostalCode != triggerOldMap.get(acc.id).BillingPostalCode )||(acc.BillingState != triggerOldMap.get(acc.id).BillingState ) ||(acc.BillingCountry != triggerOldMap.get(acc.id).BillingCountry )|| (acc.BillingCity != triggerOldMap.get(acc.id).BillingCity ))
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
                    addr.State_Province__c = acc.BillingState;
                    addr.ZTS_EU_Country__c = acc.BillingCountry;
                    addr.ZTS_EU_City__c = acc.BillingCity;
                    lstAddrToUpdate.add(addr);
                }
             }
         }
        try
        { 

            chkUpdate = false;
            ZTS_addrUpdateOnAccount.chkUpdate=false;
            List<Database.Saveresult> results=Database.update(lstAddrToUpdate,false);
            ZTS_Logger.error(results, 'ZTS_addrCreationAndUpdateFromAccount-updateAddressRecord');
        }catch(Exception e){ZTS_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_addrCreationAndUpdateFromAccount-updateAddressRecord');}   
    }
     
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
            accConAffList = [Select Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Account__c From ZTS_EU_Affiliations__c where ZTS_EU_Account__c IN: inactiveAccIds AND ZTS_EU_Market_from_Parent__c != 'United States' ];

        if(!accConAffList.isEmpty())
        {
            for(ZTS_EU_Affiliations__c accConAff : accConAffList)
            {
               accConAff.ZTS_EU_Affiliation_Status__c = ZTS_GlobalConstants.INACTIVE_STATUS;
               accConAffListToUpdate.add(accConAff);
            }
            try
            { 
                List<Database.Saveresult> results=Database.update(accConAffListToUpdate,false);
                ZTS_Logger.error(results, 'ZTS_addrCreationAndUpdateFromAccount-updateAccConAffInactive');
            }
            catch(Exception e)
            {
                ZTS_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_addrCreationAndUpdateFromAccount-updateAccConAffInactive');
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
            if(oldAccMap.get(acc.Id) != null && (oldAccMap.get(acc.Id).BillingCity!=acc.BillingCity || 
                                                 oldAccMap.get(acc.Id).BillingStreet!=acc.BillingStreet || 
                                                 oldAccMap.get(acc.Id).BillingCountry!=acc.BillingCountry ||  
                                                 oldAccMap.get(acc.Id).BillingState!=acc.BillingState  ||    
                                                 oldAccMap.get(acc.Id).BillingPostalCode!=acc.BillingPostalCode))
                accIds.add(acc.Id);
        }

        //Map<Id,Account> acc_map=new Map<Id,Account>(newaccountList);
        List<Contact> modifycontactList =  new List<Contact>();

        if(!accIds.isEmpty())
        {
            List<Contact> contactList = [SELECT AccountId, Id, MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode 
                                            FROM Contact WHERE AccountId IN :accIds AND ZTS_EU_Market__c != 'United States'];
        
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
            List<Database.Saveresult> results=Database.update(modifycontactList,false);
            ZTS_Logger.error(results,'ZTS_addrCreationAndUpdateFromAccount-updateAccContactsAddress');
        }
    }
     
     
     
      /***********
        * Method name  : updateAContactAddress
        * Description  : If an Account Billing Address,then all Contacts Address for that Accounts is updated
        * Return Type  : None.
        * Parameters   : Account List.
        ***********/
     /*public static void updateContactsAddress(List<Contact> newcontactlist,Map<Id,Contact> oldcontactMap){
       //Accessing PetOwner record type
         Id petOwnerContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ZTS_US_Pet_Owner').getRecordTypeId();
        //commenting the below lines since those record types are not existing in INTL 
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
        Map<Id,Account> acc_map =new Map<Id,Account>([SELECT Id, BillingCity, BillingCountry, BillingState, BillingStreet, BillingPostalCode FROM Account WHERE Id IN :accIds AND ZTS_EU_Market__c != 'United States']);
        
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
        } */

     
     
     /***********
        * Method name  : isAddressChanged
        * Description  : This method  compares old and new Account record for Address changes.
        * Return Type  : boolean.
        * Parameters   : Old Account and New Account record.
     ***********/
    @Testvisible
    private static boolean isAddressChanged(Account oldAcc,Account newAcc){
        
        boolean changed=false;
        /** TEMP FORCE UPDATE 
        boolean FORCE_UPDATE=true;
        changed=FORCE_UPDATE;
        **/
        if((oldAcc.BillingCity!=newAcc.BillingCity || oldAcc.BillingStreet!=newAcc.BillingStreet || oldAcc.BillingCountry!=newAcc.BillingCountry || oldAcc.BillingState!=newAcc.BillingState  || oldAcc.BillingPostalCode!=newAcc.BillingPostalCode)){
            changed=true;
        }
        return changed;
        
     }
     
    
        /***********
        * Method name  : splitAccountName
        * Description  : Split Account name into Account Name 1,2,3,4 (35 characters each) and then consolidate in Account Official Name
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
    public static void splitAccountName(Account acc){
        acc.ZTS_EU_Account_Name_1__c = '';
        acc.ZTS_EU_Account_Name_2__c = '';
        acc.ZTS_EU_Account_Name_3__c = '';
        acc.Account_Name_4__c = '';
        List<string> wordLst = acc.Name.split(' ');
        Integer lengthCounter = 0, accountNameFieldCount = 1;
        String splittedName = '';
        for(String strWord : wordLst){
        lengthCounter += strWord.length();
        if(lengthCounter < 35 ){
              if(splittedName == ''){
                         splittedName += strWord ;
                         lengthCounter +=1;
              }else{
                     splittedName += ' ' + strWord ;
                     lengthCounter +=2;
                    }
        }
          else{
                if(accountNameFieldCount ==1){
                     acc.ZTS_EU_Account_Name_1__c = splittedName.trim();
                     accountNameFieldCount++;
                }
                else if(accountNameFieldCount ==2){
                        acc.ZTS_EU_Account_Name_2__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                else if(accountNameFieldCount ==3){
                        acc.ZTS_EU_Account_Name_3__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                else{
                        acc.Account_Name_4__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                           
              splittedName = strWord ;
              lengthCounter = strWord.length() + 1;
                  }//--end of else
          }//--end of for
                    
        
        if(splittedName.trim() != ''){
             if(accountNameFieldCount ==1){
                 acc.ZTS_EU_Account_Name_1__c = splittedName.trim();
                 acc.Name = acc.ZTS_EU_Account_Name_1__c;
                 acc.ZTS_EU_Account_Official_Name__c = acc.ZTS_EU_Account_Name_1__c;                         
             } else if(accountNameFieldCount ==2){
                 acc.ZTS_EU_Account_Name_2__c = splittedName.trim();   
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c;
                 acc.ZTS_EU_Account_Official_Name__c = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c;
             }else if(accountNameFieldCount ==3){
                 acc.ZTS_EU_Account_Name_3__c = splittedName.trim(); 
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c;
                 acc.ZTS_EU_Account_Official_Name__c = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c;
             }else{
                 acc.Account_Name_4__c = splittedName.trim();
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c + ' ' + acc.Account_Name_4__c;
                 acc.ZTS_EU_Account_Official_Name__c = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c + ' ' + acc.Account_Name_4__c;                            
              }
           }                   
            
      } 
            /***********
        * Method name  : splitAccountNameonupdate
        * Description  : Split Account name into Account Name 1,2,3,4 (35 characters each) and then consolidate in Account Name on update
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
    public static void splitAccountNameonupdate(Account acc){
        acc.ZTS_EU_Account_Name_1__c = '';
        acc.ZTS_EU_Account_Name_2__c = '';
        acc.ZTS_EU_Account_Name_3__c = '';
        acc.Account_Name_4__c = '';
        List<string> wordLst = acc.Name.split(' ');
        Integer lengthCounter = 0, accountNameFieldCount = 1;
        String splittedName = '';
        for(String strWord : wordLst){
        lengthCounter += strWord.length();
        if(lengthCounter < 35 ){
              if(splittedName == ''){
                         splittedName += strWord ;
                         lengthCounter +=1;
              }else{
                     splittedName += ' ' + strWord ;
                     lengthCounter +=2;
                    }
        }
          else{
                if(accountNameFieldCount ==1){
                     acc.ZTS_EU_Account_Name_1__c = splittedName.trim();
                     accountNameFieldCount++;
                }
                else if(accountNameFieldCount ==2){
                        acc.ZTS_EU_Account_Name_2__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                else if(accountNameFieldCount ==3){
                        acc.ZTS_EU_Account_Name_3__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                else{
                        acc.Account_Name_4__c = splittedName.trim();
                        accountNameFieldCount++;
                }
                           
              splittedName = strWord ;
              lengthCounter = strWord.length() + 1;
                  }//--end of else
          }//--end of for
                    
        
        if(splittedName.trim() != ''){
             if(accountNameFieldCount ==1){
                 acc.ZTS_EU_Account_Name_1__c = splittedName.trim();
                 acc.Name = acc.ZTS_EU_Account_Name_1__c;
                                          
             } else if(accountNameFieldCount ==2){
                 acc.ZTS_EU_Account_Name_2__c = splittedName.trim();   
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c;
                 
             }else if(accountNameFieldCount ==3){
                 acc.ZTS_EU_Account_Name_3__c = splittedName.trim(); 
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c;
                 
             }else{
                 acc.Account_Name_4__c = splittedName.trim();
                 acc.Name = acc.ZTS_EU_Account_Name_1__c + ' ' + acc.ZTS_EU_Account_Name_2__c + ' ' + acc.ZTS_EU_Account_Name_3__c + ' ' + acc.Account_Name_4__c;
                 
              }
           }                   
            
      } 
    
    
        /***********
        * Method name  : updateContactonPrimAddrUpdate
        * Description  : Update Contact Address Fields when Primary Address Fields on Account is updated
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
    public static void updateContactonPrimAddrUpdate(List<Account> triggerNew,Map<Id,Account> triggeroldmap){
        List<Account> AccountList = new List<Account>();
            for(Account acc : triggerNew){
                Account accountObj = triggeroldmap.get(acc.id);
                if(acc.ZTS_EU_Primary_Address__c != accountObj.ZTS_EU_Primary_Address__c || acc.ZTS_EU_Address_Line_1__c !=accountObj.ZTS_EU_Address_Line_1__c 
                                       || acc.ZTS_EU_Address_Line_2__c != accountObj.ZTS_EU_Address_Line_2__c || acc.ZTS_EU_Address_Line_3__c != accountObj.ZTS_EU_Address_Line_3__c 
                                       ||  acc.ZTS_EU_Country__c != accountObj.ZTS_EU_Country__c || acc.ZTS_EU_State_County__c != accountObj.ZTS_EU_State_County__c 
                                       || acc.ZTS_EU_City_Country__c != accountObj.ZTS_EU_City_Country__c || acc.ZTS_EU_City__c != accountObj.ZTS_EU_City__c 
                                       || acc.ZTS_EU_Zip_Postal_Code__c != accountObj.ZTS_EU_Zip_Postal_Code__c || acc.ZTS_EU_District__c != accountObj.ZTS_EU_District__c){
                    AccountList.add(acc);
                    // system.debug('++++++AccountList++++++++'+AccountList);
                }
            } 
            PrimatyAddressUpdate.ContactsUpdateOnPrimaryAddressUpdate(AccountList);
    }
        /***********
        * Method name  : syncOptOutFlagGermany
        * Description  : Update the Opt Out flags on related contacts based on account
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
    public static void syncOptOutFlagGermany (List<Account> triggerNew){
        List<string> emailList = new List<string>();
            Set<Id> accountIDs = new Set<Id>();
            Map<string,boolean> emailMap= new Map<string,boolean>();
            for(Account a : triggerNew){
                if((a.ZTS_EU_Country__c == 'Germany' || a.ZTS_EU_Market__c == 'Germany') && a.Email__c != ''){
                    emailList.add(a.Email__c);
                    accountIDs.add(a.Id);
                    emailMap.put(a.Email__c, a.ZTS_EU_Opt_Out_Email__c); 
                }
            }
            AccountUtility.syncOptOutField(emailList,accountIDs,emailMap);
    }
     public static void setAccountStatus(List<Account> triggerNew,User usr)
     {
          //Account Status Update - Defect SC-004159 by Amitabh  
     for(Account acc: triggerNew){
    System.debug('Account Status insert ***');
            String usrProfileName = usr.Profile.name;
      if(usr.ZTS_EU_Market__c == 'Japan') 
      {
              if(usrProfileName == 'ZTS JPN Field Based Function' || usrProfileName == 'ZTS JPN Marketing Manager' || usrProfileName == 'ZTS JPN Technicals')
        {
                    acc.ZTS_EU_Account_Status__c = 'Pending';
                }
              else if(usrProfileName == 'ZTS JPN Business Administrator')
        {
                    acc.ZTS_EU_Account_Status__c = 'Active';                    
                }
            }
      else 
      {    
                acc.ZTS_EU_Account_Status__c = 'Active';
      }
    } 
     }
        /***********
        * Method name  : populatePotentialRegion
        * Description  : Update the PotentialRegion field for different markets
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
    public static void populatePotentialRegion (List<Account> triggerNew){
        for(Account acc: triggerNew) {
           /*Added for SC-003050*/
           if(acc.ZTS_EU_Market__c == 'Italy')
            {
                if(acc.Type != null){
                if((acc.Type==('Vet Practice')) ||  (acc.Type==('Vet Practice/Petshop') ))
                {
                    acc.ZTS_EU_Potential_Region__c = '1';
                }
                else if(acc.Type==('Farm'))
                {
                    acc.ZTS_EU_Potential_Region__c = '2';
                }
                else{
                    acc.ZTS_EU_Potential_Region__c = '3';
                }
              }
                        
             }//End of If clause for Italy
                        
          }//End For
        
    }
}