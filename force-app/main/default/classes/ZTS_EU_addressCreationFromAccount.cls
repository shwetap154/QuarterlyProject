/*************************************************************************************************************************
      Class Name     : ZTS_EU_addressCreationFromAccount
      Description    : This class is called from trigger on account for creation of an Address record.
      Created By     : Chandra
      Created On     : 03/05/2014
                                                               
      Modification Log    :
       -----------------------------------------------------------------------------------------------------------------------
      Developer                            Date                   Description
      ---------                            ----                 -----------
      Deloitte Consulting/Chandra       03/05/2014              Created
      Shreyas                           3rd-Sep-2014            Added the field 'ZTS_EU_City_Country__c' in 'createAddressRecord' method for CLAR.
      Shreyas                           17-Mar-2015             Added the field 'Address line 4' for accounts. 
      Shreyas                           21-May-2015             Added the field 'District' field for accounts/contact/address.
      Shreyas                           08-Jun-2015             Added the field 'Commune' field for accounts/contact/address.   
      Ethan Hirsch @ Zoetis Inc         09-Jan-2023             Bypass the Account Trigger Handler when setting Primary Address on Account to improve performance (TPDEV-82)
      Rahul Ramakrishnan                02-06-2023              Remove ZTS_EU_Main_Phone__c field from the Trigger(TPDEV-1248 )
    ***************************************************************************************************************************/
    public class ZTS_EU_addressCreationFromAccount
    {
           /***********
            * Method name  : createAddressRecord
            * Description  : This will create Address record on creation of Account.
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
        public static void createAddressRecord(List<Account> triggerNew)
        {
            List<Address__C> listAdd = new List<Address__C>();
            List<Account> updateAccountList = new List<Account>();
            List<RecordType> recordTypeId =[SELECT Id FROM RecordType where SObjectType = 'Address__c' AND Name='Account Address' LIMIT 1];
            for(Account oAcc: triggerNew)
            {
                
                /* 
                    Author: Shreyas
                    Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                    Date: 3rd Sep 2014
                */                
                // If Billing address on account is not null then carete a corresponding Address record.

              /*  if((oAcc.ZTS_EU_Address_Line_1__c != Null) || (oAcc.ZTS_EU_Address_Line_2__c != Null ) || (oAcc.ZTS_EU_Address_Line_3__c != Null ) 
                || (oAcc.ZTS_EU_Address_Line_4__c != Null ) || (oAcc.ZTS_EU_City__c != Null ) ||(oAcc.ZTS_EU_Zip_Postal_Code__c != Null) 
                ||(oAcc.ZTS_EU_State_County__c != Null)|| (oAcc.ZTS_EU_Country__c != Null) || (oAcc.ZTS_EU_Main_Phone__c != Null) 
                || (oAcc.ZTS_EU_City_Country__c != null) || (oAcc.ZTS_EU_District__c != null) || (oAcc.ZTS_EU_Commune_Lookup__c != null))
                {*/
                //Removed ZTS_EU_Main_Phone__c null check from the condition
                           if((oAcc.ZTS_EU_Address_Line_1__c != Null) || (oAcc.ZTS_EU_Address_Line_2__c != Null ) || (oAcc.ZTS_EU_Address_Line_3__c != Null ) 
                || (oAcc.ZTS_EU_Address_Line_4__c != Null ) || (oAcc.ZTS_EU_City__c != Null ) ||(oAcc.ZTS_EU_Zip_Postal_Code__c != Null) 
                ||(oAcc.ZTS_EU_State_County__c != Null)|| (oAcc.ZTS_EU_Country__c != Null)|| (oAcc.ZTS_EU_City_Country__c != null) || (oAcc.ZTS_EU_District__c != null) || (oAcc.ZTS_EU_Commune_Lookup__c != null))
                {
                
                    Address__C oAdd = new Address__c();
                    oAdd.Name = oAcc.ZTS_EU_Address_Line_1__c;
                    oAdd.ZTS_EU_Address_Line_2__c = oAcc.ZTS_EU_Address_Line_2__c;
                    oAdd.ZTS_EU_Address_Line_3__c = oAcc.ZTS_EU_Address_Line_3__c;
                    oAdd.Address_Line_4__c = oAcc.ZTS_EU_Address_Line_4__c;
                    oAdd.ZTS_EU_City__c = oAcc.ZTS_EU_City__c; 
                    oAdd.ZTS_EU_City_Country__c = oAcc.ZTS_EU_City_Country__c;                
                    oAdd.ZTS_EU_State_County__c = oAcc.ZTS_EU_State_County__c;
                    oAdd.ZTS_EU_Country__c = oAcc.ZTS_EU_Country__c;
                    oAdd.Zip_Postal_Code__c = oAcc.ZTS_EU_Zip_Postal_Code__c;
                    oAdd.ZTS_EU_District__c = oAcc.ZTS_EU_District__c;
                    oAdd.ZTS_EU_Commune_Lookup__c = oAcc.ZTS_EU_Commune_Lookup__c;
                    oAdd.recordTypeId = recordTypeId[0].Id;
                    oAdd.ZTS_EU_Account__c= oAcc.ID;
                    oAdd.ZTS_EU_Phone__c= oAcc.ZTS_EU_Main_Phone__c;
                    listAdd.add(oAdd);
                }   
                 
            }
            
            // Insert Address record list.
            if(listAdd.size()>0)
            {
                try{ 
                    Database.SaveResult[] results = Database.insert(listAdd);
                    ZTS_EU_Logger.error(results, 'ZTS_EU_addressCreationFromAccount-createAddressRecord');
                    List<Id> addressIds = new List<Id>();
                    for (Integer i = 0; i < results.size(); i++) {
                    if (results[i].isSuccess()) {
                            addressIds.add(results[i].getId());
                        } 
                    }
                    Map<String,String> accountAddressIdMap = new Map<String,String>();
                    List<Address__c> addressList = new List<Address__c>([Select Id,ZTS_EU_Account__c from Address__c where id IN: addressIds]);
                    for(Address__c add: addressList)
                    {
                        accountAddressIdMap.put(add.ZTS_EU_Account__c,add.Id);
                    }
                    for(Account oAcc: triggerNew){
                        Account updAcc = new Account();
                        if(accountAddressIdMap != null && accountAddressIdMap.get(oAcc.Id) != null){
                            updAcc.Id = oAcc.Id;
                            updAcc.ZTS_EU_Primary_Address__c = accountAddressIdMap.get(oAcc.Id);
                            updateAccountList.add(updAcc);
                        }
                        
                    }
                    
                    // Bypass the Account Trigger so it does not run again upon making a self-referential Account Update
                    DispatchTriggerHandler.bypass('AccountTriggerHandler');
                    List<Database.Saveresult> results1=Database.update(updateAccountList,false);
                    DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
                    ZTS_EU_Logger.error(results1, 'ZTS_EU_addressCreationFromAccount-createAddressRecord');
                    
                    system.debug('**********************************UtilityService.accountTriggerRun******1111*************'+UtilityService.isaccountTriggerRun());
                }catch(DmlException e) {
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_addressCreationFromAccount-createAddressRecord');
                    System.debug('The following exception has occurred: ' + e.getMessage());
                 }catch(Exception ex){
                    ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_addressCreationFromAccount-createAddressRecord');
                    system.debug('Exception*******>'+ex);
                }
            }    
         }
    }