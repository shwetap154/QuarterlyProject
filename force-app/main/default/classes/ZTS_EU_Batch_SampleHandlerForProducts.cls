/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_SampleHandlerForProducts
* Description   :  Batch class for handling creation and deactivation of Samples on creation and deactivation of SKU products.                       

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21st-Nov-14   Shreyas             Created the class.
* 1.1     12th-Mar-15   Sohil(CloudSense)   Modified the code for DEF-000673(Break the Contacts on Products creation)
* 1.2     17th-April-15 Sohil(CloudSense)   Modified the code for DEF-000673(Only for Active Products )       
********************************************************************************************************************************************/
global class ZTS_EU_Batch_SampleHandlerForProducts implements Database.Batchable<SObject>

{
    /* 
        Modified & Added by Sohil Shah (DEF-000673)
    */
    global final List<ZTS_EU_Species_Product__c> skuProductList;
    List<String> listOfApplicableMarkets;
    string skuType;    
    global ZTS_EU_Batch_SampleHandlerForProducts()
    {    
        listOfApplicableMarkets = ZTS_EU_Batch_SampleHandlerController.getListOfApplicableMarkets();
        skuType = 'SKU';      
        skuProductList = [Select Id, Name, ZTS_EU_Create_Samples__c, ZTS_EU_Is_Active__c, ZTS_EU_Market__c, ZTS_EU_Is_Old__c from ZTS_EU_Species_Product__c  where (ZTS_EU_Create_Samples__c = False AND ZTS_EU_Is_Active__c = true AND ZTS_EU_Market__c IN: listOfApplicableMarkets AND ZTS_EU_Is_Old__c = False AND ZTS_EU_Type__c =: skuType)] ;
               
    }
    
    
   global Database.queryLocator start(Database.BatchableContext bc) { 
      
       
       String contactStatus_Active = 'Active';
       String contactType = 'Veterinarian';
       
            String query = 'Select Id, ZTS_EU_Contact_type__c, ZTS_EU_Contact_Status__c, Account.Id, ZTS_EU_Market__c from Contact '; 
            
            if(skuProductList.size() > 0 )
            {
                System.debug('if loop-----------'+skuProductList.size());
                query = query + ' where ZTS_EU_Contact_Status__c =: contactStatus_Active AND ZTS_EU_Contact_type__c =: contactType AND ZTS_EU_Market__c IN: listOfApplicableMarkets';                           
            }
            return Database.getQueryLocator(query);   
    }
        
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
       
        
        List<Contact> contactList = new List<Contact>();
        for(Contact c: scope){
            contactList.add(c);     
        }
    
            
            for(ZTS_EU_Species_Product__c sku : skuProductList)
            {
                System.debug('sku.ZTS_EU_Create_Samples__c-------'+sku.ZTS_EU_Create_Samples__c);
            }
            ZTS_EU_Batch_SampleHandlerController.processSampleDataForProducts(skuProductList,contactList);
    }
     
    
    global void finish(Database.BatchableContext bc) {
    boolean flag = false;
    List<ZTS_EU_Species_Product__c> productListToUpdate = new List<ZTS_EU_Species_Product__c>();
        for(ZTS_EU_Species_Product__c sku: skuProductList){
                productListToUpdate.add(sku);
                if(sku.ZTS_EU_Create_Samples__c == false)
                {
                    flag = true;
                }
            }
    
        if(productListToUpdate.size() > 0 && flag == true){
            for(ZTS_EU_Species_Product__c sku: productListToUpdate){
                sku.ZTS_EU_Create_Samples__c = True;
            }
         }
        update productListToUpdate;
    } 
    /* 
        Modified & Added by Sohil Shah (DEF-000673)
    */

}