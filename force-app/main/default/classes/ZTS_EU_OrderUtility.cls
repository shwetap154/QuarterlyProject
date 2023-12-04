/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_OrderUtility
* Description   :  This is a Utility class for Order and Order Detail objects.

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     8th-July-15   Shreyas             Created the class.

********************************************************************************************************************************************/

public class ZTS_EU_OrderUtility{
    
    /*
        Name: restrictOrderDelete
        Purpose: restrict delete of order record if it is approved.
        arguments: none
        return type: none
    
     public static void restrictOrderDelete(List<Orders__c> orderList){
         
         string profileName = '';
         profileName = getLoggedInUserProfileName();
         
         string profileNameFromLabel = System.Label.ZTS_EU_TurkeyProfiles_RestrictDeleteOnOrder;
         List<string> profileNameList = new List<string>();
         profileNameList = profileNameFromLabel.split(';');
         Set<string> profileNameSet = new Set<string>();
         profileNameSet.addAll(profileNameList);
         
         for(Orders__c o: orderList){
             if(o.ZTS_EU_Market__c == 'Turkey' && o.ZTS_EU_Approval_Status__c == 'Approved' && profileNameSet.contains(profileName)){
                 o.addError(System.Label.ZTS_EU_CantDeleteApprovedOrder);
             }
         }
     
         
     }*/
     
     /*
        Name: restrictOrderDelete
        Purpose: restrict delete of order detail record if it is approved.
        arguments: none
        return type: none
    */
     public static void restrictOrderDetailDelete(List<Order_Detail__c> orderDetailList){
     
         string profileName = '';
         profileName = getLoggedInUserProfileName();
         
         string profileNameFromLabel = System.Label.ZTS_EU_TurkeyProfiles_RestrictDeleteOnOrder;
         List<string> profileNameList = new List<string>();
         profileNameList = profileNameFromLabel.split(';');
         Set<string> profileNameSet = new Set<string>();
         profileNameSet.addAll(profileNameList);
         
         for(Order_Detail__c o: orderDetailList){
             if(o.ZTS_EU_Market__c == 'Turkey' && o.ZTS_EU_Order_Approval_Status__c == 'Approved' && profileNameSet.contains(profileName)){
                 o.addError(System.Label.ZTS_EU_CantDeleteApprovedOrder);
             }
         }
         
     }
     
     /*
        Name: getLoggedInUserProfileName
        Purpose: to get the profile name of the logged in user
        arguments: none
        return type: none
    */
     public static string getLoggedInUserProfileName(){
     
         String profileName = '';
         string profileId = Userinfo.getProfileId();
         profile p = new profile();
         p = [Select Id, Name from profile where Id =: profileId];
         if(p != null){
             profileName = p.Name;
         }
         
         return profileName;
     }
     
    
    /*
        Name: deleteCallRecordForOrder
        Purpose: If an order is created selecting the call with type 'Order', the call should be deleted after order is created. 
        arguments: List<Orders__c>
        return type: none
    */
     public static void deleteCallRecordForOrder(List<Orders__c> orderList){
     
         List<Orders__c> orderListFetched = new List<Orders__c>();
         List<string> orderIdList = new List<string>();        
         //Luka 17/08/2015 List-->Set (System.ListException: Duplicate id in list)
         //List<Call__c> callRecordsToDelete = new List<Call__c>();
         Set<Call__c> callRecordsToDelete = new Set<Call__c>();
         List<Note> noteInsertList = new List<Note>();
         
         for(Orders__c o: orderList){
             orderIdList.add(o.Id);
         }
         
         orderListFetched = [Select Id, Call__c, Call__r.ZTS_EU_Sub_Type__c, Call__r.ZTS_EU_Additional_Notes__c, Call__r.Name from Orders__c where Id IN: orderIdList AND ZTS_EU_Market__c != 'United States'];
         
         for(Orders__c o: orderListFetched){
             
             if(o.Call__r.ZTS_EU_Sub_Type__c == 'Order' || o.Call__r.ZTS_EU_Sub_Type__c == 'Pedido'){
                
                 callRecordsToDelete.add(o.Call__r);  
                 Note n = new Note();
                 n.ParentId = o.Id;
                 n.Body = o.Call__r.ZTS_EU_Additional_Notes__c;
                 n.Title = 'Notes from Call: ' + o.Call__r.Name;
                 noteInsertList.add(n);  
             } 
             
         }
         
         insert noteInsertList;
         
         
         if(callRecordsToDelete.size() > 0){
             
             // serializing the list of call before sending this to the future method because future method doesnt support list<sObject>
             string jsonStringForCall = '';
             jsonStringForCall = JSON.serialize(callRecordsToDelete);
             
             deleteCallRecords(jsonStringForCall);
         }
         
     }
     
    
    /*
        Name: deleteCallRecords
        Purpose: perform delete operation on call record
        arguments: List<Call__c>
        return type: none
    */
    @future
    public static void deleteCallRecords(string jsonStringForCall){
    
        List<Call__c> callsDeserialized = new List<Call__c>();
        callsDeserialized = (List<Call__c>) JSON.deserialize(jsonStringForCall, List<Call__c>.class);
        delete callsDeserialized;
        
    }

    
    //Priya 30/09/2015 Added new method for Incident: INC0449142 
    /*
        Name: Create Order and Order details 
        Purpose: Create all the order details under a single order. 
        arguments: none
        return type: none
    */
    
    public static void createorderdetails(list<Orders__c> orderlist){            
            Id orderid;
            list<ID> ordrlist = new list<ID>();
            map<integer,string> ordrmap = new map<integer,string>();
            map<integer,decimal> SalesPriceMap = new map<integer,decimal>();
            string market;
            integer i = 0;
            for(Orders__c o: orderlist)
            {
                ordrlist.add(o.id);
                ordrmap.put(i,o.Product__c+ '-' + o.Quantity__c);
                //added by saurabh  03/10/17 -SC-003016
                SalesPriceMap.put(i,o.Sales_Price__c);
                //end by saurabh
                i=i+1;
                orderid = o.Id;
                market = o.ZTS_EU_Market__c;
            }
        
        list<Order_Detail__c> odlist = new list<Order_Detail__c>();
        for(integer j=0; j< ordrlist.size(); j++)
        {
            Order_Detail__c od = new Order_Detail__c();
            od.ZTS_EU_Order__c = orderid;   
                   
            if(od.Unit_Points__c != null)
            {
                od.Total_Line_Points__c = od.ZTS_EU_Quantity__c * od.Unit_Points__c;
            }
            system.debug('product' + ordrmap.get(j).split('-')[0]);
            system.debug('Quantity' + ordrmap.get(j).split('-')[1]);
           if(ordrmap.get(j).split('-')[0] != 'null' && ordrmap.get(j).split('-')[1] != 'null')
               {
                   od.ZTS_EU_Species_Product__c = ordrmap.get(j).split('-')[0];
                   od.ZTS_EU_Quantity__c = decimal.valueof(ordrmap.get(j).split('-')[1]);
                   //added by saurabh - 03/10/17
                   if(market=='Brazil' && SalesPriceMap.get(j)!=null)
                   od.ZTS_BR_Modified_Price__c = SalesPriceMap.get(j);
                   //end by saurabh
                   odlist.add(od);
               }
          }
        system.debug ('check flag-----' +ZTS_EU_CloneOrderAndDetailsController.cloneFlag);
        if(odlist!=null && odlist.size()>0 && ZTS_EU_CloneOrderAndDetailsController.cloneFlag!=Boolean.valueOf(true))
        {
            upsert odlist;
        }
        
        list<Orders__c> o1 = [select id,Product__c from Orders__c where id =: orderid AND ZTS_EU_Market__c != 'United States' limit 1];
        
        User currentUser = [Select ZTS_EU_Market__c from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States'];
        if(currentUser.ZTS_EU_Market__c == 'Mexico')
        {
            if(o1!=null && o1.size()>0)
                {
                    o1[0].Product__c = null;
                    o1[0].Quantity__c = null;
                    //o1[0].Offline__c = true;
                    upsert o1;
                }
        }
        ordrlist.remove(ordrlist.size()-1);
        list<orders__c> orlist = [select id from Orders__c where id in : ordrlist AND ZTS_EU_Market__c != 'United States'];
        if(orlist!=null && orlist.size()>0)
        {
              delete orlist;
        }
    }
    //Srinivas K: Added code part of Def:INC0583977 if Order Market is Brazil then assigning currency BRL to CurrencyIsoCode
      public static void updateCurrencyIsoCode(List<Orders__c> ordersList){
        Set<Id> accSetId = new Set<Id>();
        Map<id,Account> accMap = new Map<id,Account>();
        if(ordersList!= null && !ordersList.isEmpty()){           
            for(Orders__c ord :ordersList ){
                if(ord.ZTS_EU_Account__c != null){                
                    accSetId.add(ord.ZTS_EU_Account__c); // Adding order accounts to set 
                }
            }
        }
        if(!accSetId.isEmpty()){
            accMap = new Map<id,Account>([select id,ZTS_EU_Market__c from Account where Id in : accSetId AND ZTS_EU_Market__c != 'United States' ]); // Query accounts marketand adding into map
        }
        if(ordersList!= null && !ordersList.isEmpty()){ 
            for(Orders__c ords: ordersList){
                if(accMap.containsKey(ords.ZTS_EU_Account__c) && accMap.get(ords.ZTS_EU_Account__c) != null && accMap.get(ords.ZTS_EU_Account__c).ZTS_EU_Market__c == 'Brazil'){
                        ords.CurrencyIsoCode= 'BRL'; // Assign BRL to CurrencyIsoCode field     
                }
            }
        }
    }   
               
}