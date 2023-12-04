/*************************************************************************************
* Name          :    ZTS_EU_ContactAddinsertfromAccount .
* Description   :    This class has methods being called from ZTS_EU_Contact Trigger.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/13/2014       Chandra            Created
3/20/2014       Teresa             Modified
3-Sep-2014      Shreyas            Added the field 'ZTS_EU_City_Country__c' in 'insertAddress' method for CLAR.
21-May-2015     Shreyas            Added the field 'District' field for accounts/contact/address. 
08-Jun-2015     Shreyas            Added the field 'Commune' field for accounts/contact/address. 
22-May-2017     Abir               Changed code to accept null if proper State Country is not available in primary address
**************************************************************************************/
public with sharing class ZTS_EU_ContactAddinsertfromAccount{
/***********
            * Method name  : ContactAddinsertfromAccount
            * Description  : This for storing the account primary address to all related contacts 
            * Return Type  : Trigger parameters.
            * Parameters   : none.
 ***********/
public static void ContactAddinsertfromAccount(Set<Id> setAcc,List<Contact> lstcon)
    {
       try{
            List<Account> lstAcnt = [Select id,Account.ZTS_EU_Address_Line_1__c,Account.ZTS_EU_Address_Line_2__c,Account.ZTS_EU_Address_Line_3__c,Account.ZTS_EU_City__c, Account.ZTS_EU_State_County__c,Account.ZTS_EU_Zip_Postal_Code__c,Account.ZTS_EU_Country__c,ZTS_EU_Main_Phone__c from Account where Id IN : setAcc AND ZTS_EU_Market__c != 'United States'];
            Map<Id, Account> mpAcnt = new Map<Id, Account>(lstAcnt);
            
            for(Contact cont: lstCon){
                
                If(Cont.AccountId != null){
                
                Account acc = mpAcnt.get(cont.Accountid);
                
                cont.ZTS_EU_Address_Line_1__c = acc.ZTS_EU_Address_Line_1__c;
                cont.ZTS_EU_Address_Line_2__c = acc.ZTS_EU_Address_Line_2__c;  
                cont.ZTS_EU_Address_Line_3__c = acc.ZTS_EU_Address_Line_3__c;    
                cont.ZTS_EU_City__c = acc.ZTS_EU_City__c;
                cont.ZTS_EU_Country__c = acc.ZTS_EU_Country__c;    
                cont.ZTS_EU_State_County__c = acc.ZTS_EU_State_County__c;
                cont.ZTS_EU_Zip_Postal_Code__c = acc.ZTS_EU_Zip_Postal_Code__c;
                cont.ZTS_EU_Private_Phone__c = acc.ZTS_EU_Main_Phone__c;
            
            }
           }
        }catch(DmlException e) {
            //ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_ContactAddinsertfromAccount-ContactAddinsertfromAccount');
            System.debug('The following exception has occurred: ' + e.getMessage());
        }catch(Exception ex) {
            //ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_ContactAddinsertfromAccount-ContactAddinsertfromAccount');
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        
    



}
/***********
            * Method name  : insertAddress
            * Description  : This method is used to get the Primary address record of the Account related to the Contact.
                           : This address record is then inserted as the address record of the Contact and is marked as
                           : primary for the Contact. The address record created does store the related Account address 
                           : Id in a look up field.
            * Return Type  : Trigger parameters.
            * Parameters   : none.
 ***********/
public static void insertAddress(List<Contact> contacts)
    {
        //system.debug('##insertAddress');
        try {
            List<Address__c> lstAddress = new List<Address__c>();
            List<Contact> updateContactList = new List<Contact>();
            Map<Id,List<Id>> contactAccountIds = new Map<Id,List<Id>>();
            for(Contact cont: contacts){
                List<Id> contIds = new list<Id>();
                if(contactAccountIds.get(cont.AccountId) != null){
                    contIds = contactAccountIds.get(cont.AccountId);
                    contIds.add(cont.Id);
                    contactAccountIds.put(cont.AccountId,contIds);
                }else{
                    contIds.add(cont.Id);
                    contactAccountIds.put(cont.AccountId,contIds);
                }
                
            }
            
            //system.debug('##contactAccountIds: ' +  contactAccountIds );
            
            
            /* 
                Author: Shreyas
                Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                Date: 3rd Sep 2014
            */
            if(contactAccountIds != null && contactAccountIds.keySet()!= null && contactAccountIds.keySet().size() > 0){
                    // get the primary address record of the account related to the contact
                   
                    List<Address__c> lstAddressForAccounts = [Select Id,Name, Zip_Postal_Code__c, ZTS_EU_State_County__c, ZTS_EU_Country__c, ZTS_EU_Contact__c,ZTS_EU_District__c,
                                                              ZTS_EU_Address_Line_3__c, ZTS_EU_Address_Line_2__c, ZTS_EU_Primary_Address__c,ZTS_EU_Commune_Lookup__c, 
                                                              ZTS_EU_City__c, ZTS_EU_City_Country__c, ZTS_EU_Account__c,ZTS_EU_Phone__c From Address__c 
                                                              WHERE ZTS_EU_Account__c IN :contactAccountIds.keySet() AND ZTS_EU_Primary_Address__c  = true];
                    //system.debug('## lstAddressForAccounts:' +  lstAddressForAccounts);
                    // get the record type of Contact Address
                    List<RecordType> recordTypeId =[SELECT Id FROM RecordType where SObjectType = 'Address__c' AND Name='Contact Address' LIMIT 1];
                    for(Address__c address : lstAddressForAccounts){
                        for(Id id : contactAccountIds.get(address.ZTS_EU_Account__c)){
                            Address__c newAddress =  new Address__c();
                            newAddress.ZTS_EU_Contact__c = id;
                            newAddress.recordTypeId = recordTypeId[0].Id;
                            newAddress.ZTS_EU_Account_Address_Linked__c = address.Id;
                            newAddress.Name = address.Name!=null?address.Name:'';
                            newAddress.ZTS_EU_Address_Line_2__c = address.ZTS_EU_Address_Line_2__c!=null?address.ZTS_EU_Address_Line_2__c:'';
                            newAddress.ZTS_EU_Address_Line_3__c = address.ZTS_EU_Address_Line_3__c!=null?address.ZTS_EU_Address_Line_3__c:'';
                            newAddress.ZTS_EU_City__c = address.ZTS_EU_City__c!=null?address.ZTS_EU_City__c:'';
                            newAddress.ZTS_EU_City_Country__c = address.ZTS_EU_City_Country__c!=null?address.ZTS_EU_City_Country__c:null;
                            newAddress.ZTS_EU_District__c = address.ZTS_EU_District__c !=null?address.ZTS_EU_District__c:'';
                            newAddress.ZTS_EU_Commune_Lookup__c = address.ZTS_EU_Commune_Lookup__c !=null?address.ZTS_EU_Commune_Lookup__c:null;
                            newAddress.ZTS_EU_State_County__c = address.ZTS_EU_State_County__c!=null?address.ZTS_EU_State_County__c:null;
                            newAddress.Zip_Postal_Code__c = address.Zip_Postal_Code__c!=null?address.Zip_Postal_Code__c:'';
                            newAddress.ZTS_EU_Country__c = address.ZTS_EU_Country__c!=null?address.ZTS_EU_Country__c:'';
                            newAddress.ZTS_EU_Phone__c = address.ZTS_EU_Phone__c!=null?address.ZTS_EU_Phone__c:'';
                            lstAddress.add(newAddress);
                        }
                    }
                    //system.debug('******lstAddress********'+lstAddress);
                    
                    
                    // Insert Address record list.
                    if(lstAddress.size()>0)
                    {
                            // insert the primary address record for Contact    
                                    
                            Database.SaveResult[] results = Database.insert(lstAddress);
                            //system.debug('## results:' +  results);
                            //ZTS_EU_Logger.error(results, 'ZTS_EU_ContactAddinsertfromAccount-insertAddress');
                            List<Id> addressIds = new List<Id>();
                            for (Integer i = 0; i < results.size(); i++) {
                            if (results[i].isSuccess()) {
                                    addressIds.add(results[i].getId());
                                } 
                            }
                            Map<String,String> contactAddressIdMap = new Map<String,String>();
                            List<Address__c> addressList = new List<Address__c>([Select Id,ZTS_EU_Contact__c from Address__c where id IN: addressIds]);
                            for(Address__c add: addressList)
                            {
                                contactAddressIdMap.put(add.ZTS_EU_Contact__c,add.Id);
                            }
                            
                            //system.debug('## contactAddressIdMap:' +  contactAddressIdMap);
                            
                            for(Contact cont: contacts){
                                Contact updCont = new Contact();
                                if(contactAddressIdMap != null && contactAddressIdMap.get(cont.Id) != null){
                                    updCont.Id = cont.Id;
                                    updCont.ZTS_EU_Primary_Address__c = contactAddressIdMap.get(cont.Id);
                                    updateContactList.add(updCont);
                                }
                                
                            }
                            // update the Contact record Primary Address field with the Id of the Primary address record created
                            //UtilityService.setContactTriggerRunFalse();
                            List<Database.Saveresult> results1=Database.update(updateContactList,false);
                            //ZTS_EU_Logger.error(results1, 'ZTS_EU_ContactAddinsertfromAccount-insertAddress');
                     
                    
                }  
            }
           
       }catch(DmlException e) {
            //ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_ContactAddinsertfromAccount-insertAddress');
            System.debug('The following exception has occurred: ' + e.getMessage());
        }catch(Exception ex) {
        //  ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_ContactAddinsertfromAccount-insertAddress');
            System.debug('The following exception has occurred: ' + ex.getLineNumber() );
        }
        
    } 

}