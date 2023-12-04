/*************************************************************************************************************************
      Class Name     : ZTS_EU_Update_Address
      Description    : This class is called from trigger on address for updating account/contact address details
                       as per address marked primary
      Created By     : Teresa
      Created On     : 04/30/2014
                                                               
      Modification Log    :
       -----------------------------------------------------------------------------------------------------------------------
      Developer                            Date                   Description
      ---------                            ----                 -----------
      Teresa                            04/30/2014              Created
      Shreyas                           3-Sep-2014              Added the field 'ZTS_EU_City_Country__c' in 'updateAccountContactAddress', 'updateAddressRecordWithContactFields', 
                                                                'updateAddressFieldsOfAccount', 'updateAddressRecordWithAccountFields' and 'updateAddressFieldsOfContact' methods for CLAR.
      Shreyas                           17-Mar-2015             Added the field 'Address line 4' for accounts.   
      Shreyas                           21-May-2015             Added the field 'District' field for accounts/contact/address. 
      Shreyas                           08-Jun-2015             Added the field 'Commune' field for accounts/contact/address.                              
    ***************************************************************************************************************************/
    public with sharing class ZTS_EU_Update_Address {
            /***********
            * Method name  : updateAccountContactAddress
            * Description  : This will update address details of Account/Contact on change of Address marked primary
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
            public static void updateAccountContactAddress(List<Address__c> triggerNew, Map<Id,Address__c> triggerOldMap,Map<Id,Address__c> triggerNewMap, Boolean triggerIsUpdate, Boolean triggerIsInsert){
                try{
                    
                    Map<Id,Id> mpAcctAddr = new Map<Id,Id>();
                    Map<Id,Id> mpAcctAddrNull = new Map<Id,Id>();
                    Map<Id,Id> mpContAddr = new Map<Id,Id>();
                    Map<Id,Id> mpContAddrNull = new Map<Id,Id>();
                    
                    for(Address__c addr : triggerNew){
                        if(triggerIsUpdate){
                          
                            if(addr.ZTS_EU_Primary_Address__c 
                               &&
                                   ( addr.ZTS_EU_Primary_Address__c != triggerOldMap.get(addr.id).ZTS_EU_Primary_Address__c 
                                    || (addr.Name != triggerOldMap.get(addr.id).Name 
                                    || addr.ZTS_EU_Address_Line_3__c != triggerOldMap.get(addr.id).ZTS_EU_Address_Line_3__c 
                                    || addr.Address_Line_4__c != triggerOldMap.get(addr.id).Address_Line_4__c 
                                    || addr.ZTS_EU_Address_Line_2__c != triggerOldMap.get(addr.id).ZTS_EU_Address_Line_2__c 
                                    || addr.ZTS_EU_District__c != triggerOldMap.get(addr.id).ZTS_EU_District__c 
                                    || addr.ZTS_EU_Commune_Lookup__c != triggerOldMap.get(addr.id).ZTS_EU_Commune_Lookup__c 
                                    || addr.ZTS_EU_State_County__c != triggerOldMap.get(addr.id).ZTS_EU_State_County__c 
                                    || addr.Zip_Postal_Code__c != triggerOldMap.get(addr.id).Zip_Postal_Code__c 
                                    || addr.ZTS_EU_City__c != triggerOldMap.get(addr.id).ZTS_EU_City__c
                                    || addr.ZTS_EU_Country__c != triggerOldMap.get(addr.id).ZTS_EU_Country__c 
                                    || addr.ZTS_EU_Phone__c != triggerOldMap.get(addr.id).ZTS_EU_Phone__c 
                                    || addr.ZTS_EU_City_Country__c != triggerOldMap.get(addr.id).ZTS_EU_City_Country__c)
                                   )
                              ){
                                    if(addr.ZTS_EU_Account__c != null){
                                        mpAcctAddr.put(addr.ZTS_EU_Account__c,addr.Id);
                                    }
                                    
                                    if(addr.ZTS_EU_Contact__c != null){
                                        mpContAddr.put(addr.ZTS_EU_Contact__c,addr.Id);
                                    }
                                }
                        }
                        
                        //if new address is inserted with primary address type put it in a map with associated account and contact
                        if(triggerIsInsert){
                            if(addr.ZTS_EU_Primary_Address__c){
                                mpAcctAddr.put(addr.ZTS_EU_Account__c,addr.Id);
                                mpContAddr.put(addr.ZTS_EU_Contact__c,addr.Id);
                            }
                        }
                    }
                    
                    /* 
                    Author: Shreyas
                    Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                    Date: 3rd Sep 2014
                    */
                    
                    if(mpAcctAddr.size() > 0){
                        
                        Map<Id, Account> mpAcc = new Map<id, Account>([SELECT id,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,
                        ZTS_EU_Address_Line_3__c,ZTS_EU_District__c,ZTS_EU_City__c, ZTS_EU_State_County__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Country__c, 
                        ZTS_EU_Commune_Lookup__c 
                        FROM Account 
                        WHERE Id IN: mpAcctAddr.keyset()
                        AND ZTS_EU_Market__c != 'United States']);
                        
                        for(Account acc : mpAcc.values()){
                            acc.ZTS_EU_Address_Line_1__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).Name;
                            acc.ZTS_EU_Address_Line_2__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Address_Line_2__c;    
                            acc.ZTS_EU_Address_Line_3__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Address_Line_3__c;
                            acc.ZTS_EU_Address_Line_4__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).Address_Line_4__c;
                            acc.ZTS_EU_District__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_District__c;  
                            acc.ZTS_EU_Commune_Lookup__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Commune_Lookup__c;   
                            acc.ZTS_EU_State_County__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_State_County__c;    
                            acc.ZTS_EU_Zip_Postal_Code__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).Zip_Postal_Code__c;    
                            acc.ZTS_EU_Country__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Country__c;    
                            acc.ZTS_EU_City__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_City__c; 
                            acc.ZTS_EU_City_Country__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_City_Country__c;
                            
                            if(triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Phone__c!=null && 
                            triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Phone__c!=''){
                                
                                acc.ZTS_EU_Main_Phone__c = triggerNewMap.get(mpAcctAddr.get(acc.id)).ZTS_EU_Phone__c;
                            }
                            
                            acc.ZTS_EU_Primary_Address__c = mpAcctAddr.get(acc.id);
                        }
                        
                        UtilityService.setAddressTriggerRunFalse();
                        upsert mpAcc.values();
                    }
                    
                    if(mpContAddr.size()>0){
                        
                        Map<Id, Contact> mpCont = new Map<id, Contact>([SELECT id,ZTS_EU_Address_Line_1__c,ZTS_EU_Address_Line_2__c,
                        ZTS_EU_Address_Line_3__c,ZTS_EU_District__c,ZTS_EU_City__c, ZTS_EU_State_County__c,ZTS_EU_Zip_Postal_Code__c,ZTS_EU_Country__c 
                        FROM Contact 
                        WHERE Id IN: mpContAddr.keyset()
                        AND ZTS_EU_Market__c != 'United States'
                        ]);
                        
                        for(Contact cont : mpCont.values()){
                            cont.ZTS_EU_Address_Line_1__c = triggerNewMap.get(mpContAddr.get(cont.id)).Name;
                            cont.ZTS_EU_Address_Line_2__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_Address_Line_2__c;    
                            cont.ZTS_EU_Address_Line_3__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_Address_Line_3__c;    
                            cont.ZTS_EU_State_County__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_State_County__c; 
                            cont.ZTS_EU_District__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_District__c;
                            cont.ZTS_EU_Commune_Lookup__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_Commune_Lookup__c;    
                            cont.ZTS_EU_Zip_Postal_Code__c = triggerNewMap.get(mpContAddr.get(cont.id)).Zip_Postal_Code__c;    
                            cont.ZTS_EU_Country__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_Country__c;    
                            cont.ZTS_EU_City__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_City__c;  
                            cont.ZTS_EU_City_Country__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_City_Country__c; 
                            cont.ZTS_EU_Private_Phone__c = triggerNewMap.get(mpContAddr.get(cont.id)).ZTS_EU_Phone__c;   
                            cont.ZTS_EU_Primary_Address__c = mpContAddr.get(cont.Id);
                        }
                        
                        UtilityService.setAddressTriggerRunFalse();
                        upsert mpCont.values();
                    }
                    
                    
                }catch(DmlException e) {
                
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Update_Address-updateAccountContactAddress');
                }catch(Exception ex) {
                    ZTS_EU_Logger.error('DMLException : '+ex.getMessage(), null, 'ZTS_EU_Update_Address-updateAccountContactAddress');
                }
            }
       
       
       
            /***********
            * Method name  : updateAddressFieldsOfAccount
            * Description  : This will update address fields on Account when the look up to Address Primary is filled
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
            public static void updateAddressFieldsOfAccount(List<Account> triggerNew,Map<Id,Account> triggerOldMap){
                try{
                    
                    List<String> addressIds = new List<String>();
                    for(Account acc : triggerNew){
                        if(acc.ZTS_EU_Primary_Address__c != null && acc.ZTS_EU_Primary_Address__c !=triggerOldMap.get(acc.Id).ZTS_EU_Primary_Address__c ){
                            addressIds.add(acc.ZTS_EU_Primary_Address__c);
                        }
                    }
                    /* 
                        Author: Shreyas
                        Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                        Date: 4th Sep 2014
                    */            
                    Map<Id,Address__c> add = new Map<Id,Address__c>([SELECT Id,ZTS_EU_Is_Account__c,ZTS_EU_Is_Contact__c,ZTS_EU_Account__c,ZTS_EU_Contact__c,Name, 
                    ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,Address_Line_4__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,Zip_Postal_Code__c,ZTS_EU_District__c,
                    ZTS_EU_State_County__c,ZTS_EU_Country__c,ZTS_EU_Phone__c, ZTS_EU_Commune_Lookup__c 
                    FROM Address__c WHERE id IN: addressIds]);
                    
                    for(Account acc : triggerNew){
                        if(acc.ZTS_EU_Primary_Address__c != null && acc.ZTS_EU_Primary_Address__c !=triggerOldMap.get(acc.Id).ZTS_EU_Primary_Address__c ){
                            if(add.get(acc.ZTS_EU_Primary_Address__c) != null){
                                acc.ZTS_EU_Address_Line_1__c = add.get(acc.ZTS_EU_Primary_Address__c).Name;
                                acc.ZTS_EU_Address_Line_2__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_2__c;
                                acc.ZTS_EU_Address_Line_3__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_3__c;
                                acc.ZTS_EU_Address_Line_4__c = add.get(acc.ZTS_EU_Primary_Address__c).Address_Line_4__c;
                                acc.ZTS_EU_City__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_City__c;
                                acc.ZTS_EU_City_Country__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_City_Country__c;
                                acc.ZTS_EU_State_County__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_State_County__c;
                                acc.ZTS_EU_Zip_Postal_Code__c = add.get(acc.ZTS_EU_Primary_Address__c).Zip_Postal_Code__c;
                                acc.ZTS_EU_Country__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Country__c; 
                                acc.ZTS_EU_District__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_District__c;
                                acc.ZTS_EU_Commune_Lookup__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Commune_Lookup__c;
                                if(add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c!=null && add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c !='') {
                                    acc.ZTS_EU_Main_Phone__c = add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c;   
                                }         
                            }
                        }
                    }
                    
                }catch(DmlException e) {
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressFieldsOfAccount');
                    
                }catch(Exception ex) {
                    ZTS_EU_Logger.error('DMLException : '+ex.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressFieldsOfAccount');
                }
            }
       
            /***********
            * Method name  : updateAddressFieldsOfContact
            * Description  : This will update address fields on Contact when the look up to Address Primary is filled
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
            public static void updateAddressFieldsOfContact(List<Contact> triggerNew,Map<Id,Contact> triggerOldMap){
                try{
                    
                    List<String> addressIds = new List<String>();
                    for(Contact cont : triggerNew){
                        if(cont.ZTS_EU_Primary_Address__c != null && cont.ZTS_EU_Primary_Address__c !=triggerOldMap.get(cont.Id).ZTS_EU_Primary_Address__c ){
                            addressIds.add(cont.ZTS_EU_Primary_Address__c);
                        }
                    }
                    /* 
                        Author: Shreyas
                        Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                        Date: 3rd Sep 2014
                    */
                    Map<Id,Address__c> add = new Map<Id,Address__c>([SELECT Id,ZTS_EU_Is_Account__c,ZTS_EU_Is_Contact__c,ZTS_EU_Account__c,ZTS_EU_Contact__c,
                    Name,ZTS_EU_District__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,Zip_Postal_Code__c,
                    ZTS_EU_State_County__c,ZTS_EU_Country__c,ZTS_EU_Phone__c, ZTS_EU_Commune_Lookup__c 
                    FROM Address__c WHERE id IN: addressIds]);
                    
                    for(Contact cont : triggerNew){
                        if(cont.ZTS_EU_Primary_Address__c != null && cont.ZTS_EU_Primary_Address__c != triggerOldMap.get(cont.Id).ZTS_EU_Primary_Address__c ){
                            if(add.get(cont.ZTS_EU_Primary_Address__c) != null){
                                cont.ZTS_EU_Address_Line_1__c = add.get(cont.ZTS_EU_Primary_Address__c).Name;
                                cont.ZTS_EU_Address_Line_2__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_2__c;
                                cont.ZTS_EU_Address_Line_3__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_3__c;
                                cont.ZTS_EU_City__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_City__c;
                                cont.ZTS_EU_City_Country__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_City_Country__c;
                                cont.ZTS_EU_State_County__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_State_County__c;
                                cont.ZTS_EU_Zip_Postal_Code__c = add.get(cont.ZTS_EU_Primary_Address__c).Zip_Postal_Code__c;
                                cont.ZTS_EU_Country__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Country__c;     
                                cont.ZTS_EU_Private_Phone__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c; 
                                cont.ZTS_EU_District__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_District__c;
                                cont.ZTS_EU_Commune_Lookup__c = add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Commune_Lookup__c;
                            }
                        }
                    }
                    
                }catch(DmlException e) {
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressFieldsOfContact');
                
                }catch(Exception ex) {
                    ZTS_EU_Logger.error('DMLException : '+ex.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressFieldsOfContact');
                    
                }
            }
       
            /***********
            * Method name  : updateAddressRecordWithAccountFields
            * Description  : This will update address record with address fields from Account
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
            public static void updateAddressRecordWithAccountFields(List<Account> triggerNew,Map<Id,Account> triggerOldMap){
                try{
                    
                    List<String> addressIds = new List<String>();
                    List<Address__c> updateAddressList = new List<Address__c>();
           
                    /* 
                        Author: Shreyas
                        Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                        Date: 3rd Sep 2014
                    */
                    
                    for(Account acc : triggerNew){
                        if(acc.ZTS_EU_Primary_Address__c != null && acc.ZTS_EU_Primary_Address__c == triggerOldMap.get(acc.Id).ZTS_EU_Primary_Address__c){
                            if(acc.ZTS_EU_Address_Line_1__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_1__c
                                || acc.ZTS_EU_Address_Line_2__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_2__c
                                || acc.ZTS_EU_Address_Line_3__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_3__c
                                || acc.ZTS_EU_Address_Line_4__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_4__c
                                || acc.ZTS_EU_District__c != triggerOldMap.get(acc.Id).ZTS_EU_District__c
                                || acc.ZTS_EU_Commune_Lookup__c != triggerOldMap.get(acc.Id).ZTS_EU_Commune_Lookup__c
                                || acc.ZTS_EU_City__c != triggerOldMap.get(acc.Id).ZTS_EU_City__c
                                || acc.ZTS_EU_State_County__c != triggerOldMap.get(acc.Id).ZTS_EU_State_County__c
                                || acc.ZTS_EU_Zip_Postal_Code__c != triggerOldMap.get(acc.Id).ZTS_EU_Zip_Postal_Code__c
                                || acc.ZTS_EU_Country__c != triggerOldMap.get(acc.Id).ZTS_EU_Country__c
                                || acc.ZTS_EU_Main_Phone__c != triggerOldMap.get(acc.Id).ZTS_EU_Main_Phone__c 
                                || acc.ZTS_EU_City_Country__c != triggerOldMap.get(acc.Id).ZTS_EU_City_Country__c ){
                                    
                                    addressIds.add(acc.ZTS_EU_Primary_Address__c);
                                }
                        }
                    }
                    
                    if(addressIds.size() > 0){
                        
                        Map<Id,Address__c> add = new Map<Id,Address__c>([SELECT Id,ZTS_EU_Is_Account__c,ZTS_EU_Is_Contact__c,ZTS_EU_Account__c,ZTS_EU_Contact__c,
                        Name,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,ZTS_EU_City_Country__c,ZTS_EU_District__c,Zip_Postal_Code__c,
                        ZTS_EU_State_County__c,ZTS_EU_Country__c,ZTS_EU_Phone__c, ZTS_EU_Commune_Lookup__c 
                        FROM Address__c 
                        WHERE id IN: addressIds 
                        AND ZTS_EU_Is_Account__c = true]);
                        
                        for(Account acc : triggerNew){
                            if(acc.ZTS_EU_Primary_Address__c != null && acc.ZTS_EU_Primary_Address__c == triggerOldMap.get(acc.Id).ZTS_EU_Primary_Address__c){
                                if(acc.ZTS_EU_Address_Line_1__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_1__c 
                                    || acc.ZTS_EU_Address_Line_2__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_2__c
                                    || acc.ZTS_EU_Address_Line_3__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_3__c
                                    || acc.ZTS_EU_Address_Line_4__c != triggerOldMap.get(acc.Id).ZTS_EU_Address_Line_4__c
                                    || acc.ZTS_EU_District__c != triggerOldMap.get(acc.Id).ZTS_EU_District__c
                                    || acc.ZTS_EU_Commune_Lookup__c != triggerOldMap.get(acc.Id).ZTS_EU_Commune_Lookup__c
                                    || acc.ZTS_EU_City__c != triggerOldMap.get(acc.Id).ZTS_EU_City__c
                                    || acc.ZTS_EU_State_County__c != triggerOldMap.get(acc.Id).ZTS_EU_State_County__c
                                    || acc.ZTS_EU_Zip_Postal_Code__c != triggerOldMap.get(acc.Id).ZTS_EU_Zip_Postal_Code__c
                                    || acc.ZTS_EU_Country__c != triggerOldMap.get(acc.Id).ZTS_EU_Country__c
                                    || acc.ZTS_EU_Main_Phone__c != triggerOldMap.get(acc.Id).ZTS_EU_Main_Phone__c 
                                    || acc.ZTS_EU_City_Country__c != triggerOldMap.get(acc.Id).ZTS_EU_City_Country__c ){
                                        
                                        if(add.get(acc.ZTS_EU_Primary_Address__c) != null){
                                            add.get(acc.ZTS_EU_Primary_Address__c).Name = acc.ZTS_EU_Address_Line_1__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_2__c = acc.ZTS_EU_Address_Line_2__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_3__c = acc.ZTS_EU_Address_Line_3__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).Address_Line_4__c = acc.ZTS_EU_Address_Line_4__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_District__c = acc.ZTS_EU_District__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Commune_Lookup__c = acc.ZTS_EU_Commune_Lookup__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_City__c = acc.ZTS_EU_City__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_City_Country__c= acc.ZTS_EU_City_Country__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_State_County__c = acc.ZTS_EU_State_County__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).Zip_Postal_Code__c = acc.ZTS_EU_Zip_Postal_Code__c;
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Country__c = acc.ZTS_EU_Country__c;   
                                            add.get(acc.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c = acc.ZTS_EU_Main_Phone__c;        
                                            updateAddressList.add(add.get(acc.ZTS_EU_Primary_Address__c));
                                        }
                                    }
                            }
                        }
                        
                        UtilityService.setAccountTriggerRunFalse();     
                        List<Database.Saveresult> results=Database.update(updateAddressList,false);
                        ZTS_EU_Logger.error(results, 'ZTS_EU_Update_Address-updateAddressRecordWithAccountFields');
                    }
                    
                }catch(DmlException e) {
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressRecordWithAccountFields');
                    
                }catch(Exception ex) {
                    ZTS_EU_Logger.error('DMLException : '+ex.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressRecordWithAccountFields');
                }
            }
       
       
            /***********
            * Method name  : updateAddressRecordWithContactFields
            * Description  : This will update address record with address fields from Contact
            * Return Type  : None.
            * Parameters   : trigger parameters.
            ***********/
            public static void updateAddressRecordWithContactFields(List<Contact> triggerNew,Map<Id,Contact> triggerOldMap){
                try{
                    List<String> addressIds = new List<String>();
                    List<Address__c> updateAddressList = new List<Address__c>();
                    
                    for(Contact cont : triggerNew){
                        //check whether address fields on Account have been modified
                        if(cont.ZTS_EU_Primary_Address__c != null && cont.ZTS_EU_Primary_Address__c == triggerOldMap.get(cont.Id).ZTS_EU_Primary_Address__c){
                            if(cont.ZTS_EU_Address_Line_1__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_1__c
                                || cont.ZTS_EU_Address_Line_2__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_2__c
                                || cont.ZTS_EU_Address_Line_3__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_3__c
                                || cont.ZTS_EU_City__c != triggerOldMap.get(cont.Id).ZTS_EU_City__c
                                || cont.ZTS_EU_District__c != triggerOldMap.get(cont.Id).ZTS_EU_District__c
                                || cont.ZTS_EU_Commune_Lookup__c != triggerOldMap.get(cont.Id).ZTS_EU_Commune_Lookup__c
                                || cont.ZTS_EU_State_County__c != triggerOldMap.get(cont.Id).ZTS_EU_State_County__c
                                || cont.ZTS_EU_Zip_Postal_Code__c != triggerOldMap.get(cont.Id).ZTS_EU_Zip_Postal_Code__c
                                || cont.ZTS_EU_Country__c != triggerOldMap.get(cont.Id).ZTS_EU_Country__c
                                || cont.ZTS_EU_Private_Phone__c != triggerOldMap.get(cont.Id).ZTS_EU_Private_Phone__c 
                                || cont.ZTS_EU_City_Country__c != triggerOldMap.get(cont.Id).ZTS_EU_City_Country__c){
                                    
                                    addressIds.add(cont.ZTS_EU_Primary_Address__c);
                                }
                        }
                    }
            
                    /* 
                        Author: Shreyas
                        Change description: Added the field 'ZTS_EU_City_Country__c' for CLAR. 
                        Date: 3rd Sep 2014
                    */
                    if(addressIds.size() > 0){
                        Map<Id,Address__c> add = new Map<Id,Address__c>([SELECT Id,ZTS_EU_Is_Account__c,ZTS_EU_Is_Contact__c,ZTS_EU_Account__c,ZTS_EU_Contact__c,
                                                                Name, ZTS_EU_Commune_Lookup__c,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,ZTS_EU_City__c,
                                                                Zip_Postal_Code__c,ZTS_EU_District__c,ZTS_EU_State_County__c,ZTS_EU_Country__c,
                                                                ZTS_EU_Phone__c FROM Address__c 
                                                                WHERE id IN: addressIds 
                                                                AND ZTS_EU_Is_Contact__c = true]);
                                                                
                        for(Contact cont : triggerNew){
                            if(cont.ZTS_EU_Primary_Address__c != null && cont.ZTS_EU_Primary_Address__c == triggerOldMap.get(cont.Id).ZTS_EU_Primary_Address__c){
                                if(cont.ZTS_EU_Address_Line_1__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_1__c 
                                    || cont.ZTS_EU_Address_Line_2__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_2__c
                                    || cont.ZTS_EU_Address_Line_3__c != triggerOldMap.get(cont.Id).ZTS_EU_Address_Line_3__c
                                    || cont.ZTS_EU_District__c != triggerOldMap.get(cont.Id).ZTS_EU_District__c
                                    || cont.ZTS_EU_Commune_Lookup__c != triggerOldMap.get(cont.Id).ZTS_EU_Commune_Lookup__c
                                    || cont.ZTS_EU_City__c != triggerOldMap.get(cont.Id).ZTS_EU_City__c
                                    || cont.ZTS_EU_State_County__c != triggerOldMap.get(cont.Id).ZTS_EU_State_County__c
                                    || cont.ZTS_EU_Zip_Postal_Code__c != triggerOldMap.get(cont.Id).ZTS_EU_Zip_Postal_Code__c
                                    || cont.ZTS_EU_Country__c != triggerOldMap.get(cont.Id).ZTS_EU_Country__c
                                    || cont.ZTS_EU_Private_Phone__c != triggerOldMap.get(cont.Id).ZTS_EU_Private_Phone__c 
                                    || cont.ZTS_EU_City_Country__c != triggerOldMap.get(cont.Id).ZTS_EU_City_Country__c ){
                                        
                                        if(add.get(cont.ZTS_EU_Primary_Address__c) != null){
                                            add.get(cont.ZTS_EU_Primary_Address__c).Name = cont.ZTS_EU_Address_Line_1__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_2__c = cont.ZTS_EU_Address_Line_2__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Address_Line_3__c = cont.ZTS_EU_Address_Line_3__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_District__c = cont.ZTS_EU_District__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Commune_Lookup__c = cont.ZTS_EU_Commune_Lookup__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_City__c = cont.ZTS_EU_City__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_City_Country__c = cont.ZTS_EU_City_Country__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_State_County__c = cont.ZTS_EU_State_County__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).Zip_Postal_Code__c = cont.ZTS_EU_Zip_Postal_Code__c;
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Country__c = cont.ZTS_EU_Country__c;   
                                            add.get(cont.ZTS_EU_Primary_Address__c).ZTS_EU_Phone__c = cont.ZTS_EU_Private_Phone__c;
                                            
                                            updateAddressList.add(add.get(cont.ZTS_EU_Primary_Address__c));
                                        }
                                    }
                            }
                        } 
                        
                        UtilityService.setContactTriggerRunFalse();    
                        List<Database.Saveresult> results=Database.update(updateAddressList,false);
                        ZTS_EU_Logger.error(results, 'ZTS_EU_Update_Address-updateAddressRecordWithContactFields');
                    }
                    
                }catch(DmlException e) {
                    ZTS_EU_Logger.error('DMLException : '+e.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressRecordWithContactFields');
                }catch(Exception ex) {
                    ZTS_EU_Logger.error('NonDMLException : '+ex.getMessage(), null, 'ZTS_EU_Update_Address-updateAddressRecordWithContactFields');
                }
            }
    }