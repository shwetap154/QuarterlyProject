/*************************************************************************************************************************
Class Name     : ZTS_addrUpdateOnAccount
Description    : This class is called from trigger on Address__c to Update Address fields on Account 
whenever the Primary Address is changed or existing Primary Address is modified.
Created By     : Ketan Prakash Singh
Created On     : 03/23/2014

Modification Log    :
-----------------------------------------------------------------------------------------------------------------------
Developer                            Date                   Description
---------                            ----                 -----------
Ketan Prakash Singh                 03/23/2014              Created
Ethan Hirsch @ Zoetis Inc           01/09/2023              Update updateAccOnPrimAddrCreation and updateAccOnPrimAddrModification
                                                            to set chkUpdate to false in this class while updating the Account
                                                            ZTS_US_addrCreationAndUpdateFromAccount to prevent the Address
                                                            from being updated again on the Account or Address. (TPDEV-82)


***************************************************************************************************************************/
public class ZTS_addrUpdateOnAccount
{
    public static boolean chkUpdate = true;
    
    /***********       
* Method name  : updateAccOnPrimAddrCreation
* Description  : This will update Address fields on Account record on creation of Primary Address record.
* Return Type  : None.
* Parameters   : trigger parameters.
***********/       
    public static void updateAccOnPrimAddrCreation(List<Address__C> triggerNew,Map<Id,Address__C> addressNewMap){
       
        if(!chkUpdate){
            return;
        }
        Set<Id> setAccId = new Set<Id>();
        Map<Id,Id> mapAccIdAddrId = new Map<Id,Id>();
        List<Account> listAccToUpdate = new List<Account>();
        String LINE_BREAK='\n';        
        for(Address__C oAdd: triggerNew){
            // if Primary Address is created then update corresponding Address fields on Account record.    
            // TPDEV-1258 : ZTS_EU_Primary__c replaced with ZTS_US_Primary__c 
            if(oAdd.ZTS_US_Primary__c){
                setAccId.add(oAdd.ZTS_EU_Account__c);
                mapAccIdAddrId.put(oAdd.ZTS_EU_Account__c,oAdd.Id);
            }
            
        } 
        
        
        List<Account> lstAcc = [Select a.Id,a.BillingPostalCode, a.BillingStreet, a.ZTS_EU_Address_Line_1__c, a.ZTS_EU_Address_Line_2__c, a.BillingState, a.BillingCountry, a.BillingCity,a.ZTS_County__c, 
                                a.PIT_PrimaryLocation__latitude__s,a.PIT_PrimaryLocation__longitude__s From Account a where a.Id in :setAccId AND ZTS_EU_Market__c = 'United States'];     
        for(Account acc: lstAcc ){
            acc.BillingStreet = (addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Address_Line_1__c != null ? addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Address_Line_1__c : '')+LINE_BREAK+
                (addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Address_Line_2__c != null ? addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Address_Line_2__c : '');    
           //TPDEV-1258 : State_Province__c replaced with ZTS_US_State_Province__c
            acc.BillingState = addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_State_Province__c;    
            acc.BillingPostalCode = addressNewMap.get(mapAccIdAddrId.get(acc.id)).Zip_Postal_Code__c;    
            acc.BillingCountry = addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Country__c;    
            acc.BillingCity = addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_City__c;
                acc.ZTS_County__c=addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_County__c;//for county field
            //goelocation field update
                        
             if(addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Latitude__c != null)
                acc.PIT_PrimaryLocation__latitude__s=addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Latitude__c;
               else
                acc.PIT_PrimaryLocation__latitude__s=addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_Latitude__c;   
                if(addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Longitude__c != null)
                acc.PIT_PrimaryLocation__longitude__s=addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Longitude__c;
                else
                acc.PIT_PrimaryLocation__longitude__s=addressNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_Longitude__c;
            
        listAccToUpdate.add(acc);
        }       
        if(listAccToUpdate.size()>0){
            try{
                ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = false;
                chkUpdate = false;
                List<Database.Saveresult> results=Database.update(listAccToUpdate,false);
                ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
                chkUpdate = true;
                ZTS_Logger.error(results, 'ZTS_addrUpdateOnAccount-updateAccOnPrimAddrCreation');
            }
            catch(Exception e){
                ZTS_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_addrUpdateOnAccount-updateAccOnPrimAddrCreation');
            }
        }    
    }
    
    /***********       
* Method name  : updateAccOnPrimAddrModification
* Description  : This will update Address fields on Account record on modification of Primary Address record.
* Return Type  : None.
* Parameters   : trigger parameters.
***********/ 
    public static void updateAccOnPrimAddrModification(List<Address__C> triggerNew,Map<ID,Address__C> triggerOldMap,Map<ID,Address__C> triggerNewMap){
   
        Set<Id> setAccId = new Set<Id>();
        Map<Id,Id> mapAccIdAddrId = new Map<Id,Id>();
        List<Account> listAccToUpdate = new List<Account>();
        String LINE_BREAK='\n';
        //TEMP force update to be removed
        //boolean FORCE_UPDATE=true;
        if(chkUpdate ){

            for(Address__C addr: triggerNew){
                if(addr.ZTS_US_Primary__c && (addr.ZTS_US_Primary__c != triggerOldmap.get(addr.id).ZTS_US_Primary__c) || 
                   (addr.ZTS_EU_Primary__c != triggerOldmap.get(addr.id).ZTS_EU_Primary__c) ||
                   (addr.ZTS_Address_Line_1__c != triggerOldMap.get(addr.id).ZTS_Address_Line_1__c) || 
                   (addr.Zip_Postal_Code__c != triggerOldMap.get(addr.id).Zip_Postal_Code__c )||
                   (addr.State_Province__c != triggerOldMap.get(addr.id).State_Province__c ) ||
                   (addr.ZTS_EU_Country__c != triggerOldMap.get(addr.id).ZTS_EU_Country__c )|| 
                   (addr.ZTS_EU_City__c != triggerOldMap.get(addr.id).ZTS_EU_City__c ) || 
                   (addr.ZTS_EU_Address_Line_2__c != triggerOldMap.get(addr.id).ZTS_EU_Address_Line_2__c) ||
                   (addr.ZTS_County__c != triggerOldMap.get(addr.id).ZTS_County__c) ||
                   (addr.ZTS_Latitude__c != triggerOldMap.get(addr.id).ZTS_Latitude__c) ||
                   (addr.ZTS_Longitude__c != triggerOldMap.get(addr.id).ZTS_Longitude__c)){
                       setAccId.add(addr.ZTS_EU_Account__c);
                       mapAccIdAddrId.put(addr.ZTS_EU_Account__c,addr.Id);
                   }
            }
            
            List<Account> lstAcc = [Select Id,a.BillingPostalCode, a.BillingStreet, a.ZTS_EU_Address_Line_1__c, a.ZTS_EU_Address_Line_2__c, a.BillingState, a.BillingCountry, a.BillingCity,ZTS_County__c,
                                    a.PIT_PrimaryLocation__latitude__s,a.PIT_PrimaryLocation__longitude__s From Account a
                                    where a.Id in :setAccId AND ZTS_EU_Market__c = 'United States'];
            
            for(Account acc: lstAcc ){
                acc.BillingStreet = (triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Address_Line_1__c != null ? triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Address_Line_1__c : '')+LINE_BREAK+
                    (triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Address_Line_2__c != null ? triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Address_Line_2__c : '');    
                acc.BillingState = triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_State_Province__c;    
                acc.BillingPostalCode = triggerNewMap.get(mapAccIdAddrId.get(acc.id)).Zip_Postal_Code__c;    
                acc.BillingCountry = triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_Country__c;    
                acc.BillingCity = triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_EU_City__c;
                acc.ZTS_County__c=triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_County__c;//for county field
                //goelocation field update
                if(triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Latitude__c != null)
                acc.PIT_PrimaryLocation__latitude__s=triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Latitude__c;
               else
                acc.PIT_PrimaryLocation__latitude__s=triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_Latitude__c;   
                if(triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Longitude__c != null)
                acc.PIT_PrimaryLocation__longitude__s=triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_Longitude__c;
                else
                acc.PIT_PrimaryLocation__longitude__s=triggerNewMap.get(mapAccIdAddrId.get(acc.id)).ZTS_US_Longitude__c;    
                listAccToUpdate.add(acc);
            }
            
            if(listAccToUpdate.size()>0){
                try{
                    ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = false;
                    chkUpdate = false;
                    List<Database.Saveresult> results=Database.update(listAccToUpdate,false);
                    ZTS_US_addrCreationAndUpdateFromAccount.chkUpdate = true;
                    chkUpdate = true;
                    ZTS_Logger.error(results, 'ZTS_addrUpdateOnAccount-updateAccOnPrimAddrModification');
                }
                catch(Exception e){
                    ZTS_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_addrUpdateOnAccount-updateAccOnPrimAddrModification');
                }
            }           
        }
    }
    
    
}