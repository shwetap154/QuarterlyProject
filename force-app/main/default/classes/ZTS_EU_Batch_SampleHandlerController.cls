/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Batch_SampleHandlerController
* Description   :  This is the controller of the classes: ZTS_EU_Batch_SampleHandlerForContact and ZTS_EU_Batch_SampleHandlerForProducts                         

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     21st-Nov-14   Shreyas             Created the class.
* 1.1     12th-Mar-15   Sohil(CloudSense)   Modified the code for DEF-000673(Break the Contacts on Products creation)       
********************************************************************************************************************************************/

public class ZTS_EU_Batch_SampleHandlerController{
    
    
    // contructor. 
    public void ZTS_EU_Batch_SampleHandlerController(){
    
    }

    /*
        Name: processSampleDataForContacts
        Purpose: to handle creation and deactivation of Samples on creation and deactivation of contacts.  
        Argument: List<Contact>
        Return type: none
    */
    public static void processSampleDataForContacts(List<Contact> contactList){
    
        List<ZTS_EU_Sample__c> newSampleList = new List<ZTS_EU_Sample__c>();
        List<string> contactListForDeactivatingSamples = new List<string>();
        List<ZTS_EU_Sample__c> samplesListToDeactivateFetch = new List<ZTS_EU_Sample__c>();
        List<ZTS_EU_Sample__c> samplesListToDeactivate = new List<ZTS_EU_Sample__c>();
         List<Contact> contactListToUpdate = new List<Contact>();
        
        List<String> contactIdList = new List<String>();
        for(Contact c: contactList){
            contactIdList.add(c.Id);
        }
        system.debug(Logginglevel.ERROR, 'contactIdList----'+contactIdList);
        system.debug(Logginglevel.ERROR, 'contactIdList-Size---'+contactIdList.size());
        
        
        List<ZTS_EU_Species_Product__c> samplableProductList = new List<ZTS_EU_Species_Product__c>();
        samplableProductList = getAllSamplableProducts();
        
        System.debug(Logginglevel.ERROR, 'samplableProductList-Size------------'+samplableProductList.size());
        
        List<String> skuIdList = new List<String>();
        for(ZTS_EU_Species_Product__c sku: samplableProductList){
            skuIdList.add(sku.Id);
        }
        
        System.debug(Logginglevel.ERROR, 'skuIdList-Size------------'+skuIdList.size());
        
        List<ZTS_EU_Sample__c> existingSampleList = new List<ZTS_EU_Sample__c>();
        existingSampleList = getExistingSamples(contactIdList, skuIdList);
        
        System.debug(Logginglevel.ERROR, 'existingSampleList-Size------------'+existingSampleList.size());
        
        Set<String> existingSampleUniqueIdList= new Set<String>();
        Set<String> existingOldSkuSampleUniqueIdList= new Set<String>();
        
        for(ZTS_EU_Sample__c sample: existingSampleList){
            string cId = sample.ZTS_EU_Contact__c;
            string fifteenDigitId = cId.substring(0,15);
            if(!sample.ZTS_EU_Is_used_for_old_SKUs__c){
                existingSampleUniqueIdList.add(sample.ZTS_EU_Product__r.name + '_' + sample.ZTS_EU_Year__c + '_' + fifteenDigitId);
            }
            else{
                existingSampleUniqueIdList.add('_' + sample.ZTS_EU_Year__c + '_' + fifteenDigitId);
            }
        }
        
        system.debug(Logginglevel.ERROR, 'existingSampleUniqueIdList-- ' + existingSampleUniqueIdList );
        
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        
        for(Contact c: contactList){
            
            /*if(c.ZTS_EU_Contact_Status__c != 'Active' || c.ZTS_EU_Contact_type__c != 'Veterinarian'){
                
                contactListForDeactivatingSamples.add(c.Id);
            }*/
            
            if(c.ZTS_EU_Create_Samples__c == False){
                
                string cId = c.Id;
                string fifteenDigitId = cId.substring(0,15);
                    
                // create samples for all the samplable and active prducts.  
                for(ZTS_EU_Species_Product__c sku: samplableProductList){
                
                    
                    string uniqueKey = sku.Name + '_' + currentYearString + '_' + fifteenDigitId;
                    system.debug(Logginglevel.ERROR, 'uniqueKey-- ' + uniqueKey);
                    
                    if(!existingSampleUniqueIdList.contains(uniqueKey) && c.ZTS_EU_Market__c == sku.ZTS_EU_Market__c){
                        
                        ZTS_EU_Sample__c newSample = new ZTS_EU_Sample__c();
                        newSample.ZTS_EU_Contact__c = c.Id;
                        newSample.ZTS_EU_Product__c = sku.Id;
                        newSample.ZTS_EU_Year__c = currentYearString;
                        newSample.ZTS_EU_Is_Active__c = true;
                        newSample.ZTS_EU_Start_Quantity__c = 10;
                        newSample.ZTS_EU_Account__c = c.Account.Id;
                        newSampleList.add(newSample);
                    }
                }
                
                // Create a Sample record for Old SKU. 
                string oldSKUSampleUniqueKey = '_' + currentYearString + '_' + fifteenDigitId;
                system.debug(Logginglevel.ERROR, 'oldSKUSampleUniqueKey-- ' + oldSKUSampleUniqueKey);
                
                if(!existingSampleUniqueIdList.contains(oldSKUSampleUniqueKey)) {
                    ZTS_EU_Sample__c newSample_Old = new ZTS_EU_Sample__c();
                    newSample_Old.ZTS_EU_Contact__c = c.Id;
                    newSample_Old.ZTS_EU_Is_Used_For_Old_SKUs__c = true;
                    newSample_Old.ZTS_EU_Year__c = currentYearString;
                    newSample_Old.ZTS_EU_Is_Active__c = true;
                    newSample_Old.ZTS_EU_Start_Quantity__c = 10;
                    newSample_Old.ZTS_EU_Account__c = c.Account.Id;
                    newSampleList.add(newSample_Old);
                }
                
                if(newSampleList.size() > 0){
                    contactListToUpdate.add(c);
                }
                
            }
                       
        }
        system.debug(Logginglevel.ERROR, 'newSampleList---Size-- ' + newSampleList.size());
        system.debug(Logginglevel.ERROR, 'contactListToUpdate---Size-- ' + contactListToUpdate.size());
        
        /*if(contactListForDeactivatingSamples.size() > 0){
                
                samplesListToDeactivateFetch = [Select Id, ZTS_EU_Is_Active__c, ZTS_EU_Contact__c from ZTS_EU_Sample__c where ZTS_EU_Contact__c in: contactListForDeactivatingSamples];
                if(samplesListToDeactivateFetch.size() > 0){
                    for(ZTS_EU_Sample__c sample: samplesListToDeactivateFetch){
                        sample.ZTS_EU_Is_Active__c = False;
                        samplesListToDeactivate.add(sample);
                    }
                }
        }*/
        
        if(contactListToUpdate.size() > 0){
            for(Contact c: contactListToUpdate){
                c.ZTS_EU_Create_Samples__c = True;
            }
        }
        
        //update samplesListToDeactivate;
        //insert newSampleList;
        Database.insert(newSampleList,false);
        update contactListToUpdate;
    }

    public static void processSampleDataForInactivatedContacts(List<ZTS_EU_Sample__c> samplesListToDeactivateFetch)
    {   
        List<ZTS_EU_Sample__c> samplesListToDeactivate = new List<ZTS_EU_Sample__c>();
        if(samplesListToDeactivateFetch.size() > 0){
            for(ZTS_EU_Sample__c sample: samplesListToDeactivateFetch){
                sample.ZTS_EU_Is_Active__c = False;
                samplesListToDeactivate.add(sample);
            }
        }
        System.debug('samplesListToDeactivate---Size-------------'+samplesListToDeactivate.Size()); 
        update samplesListToDeactivate;
        
    }       
        

    /*
        Name: processSampleDataForProducts
        purpose: to handle creation and deactivation of Samples on creation and deactivation of SKU products.          
        Argument: List<ZTS_EU_Species_Product__c>
        Return type: none
    */
     /* 
        Modified & Added by Sohil Shah (DEF-000673) Take two arguments : One batched Contact List and second Newly created Product List
    */
    public static void processSampleDataForProducts(List<ZTS_EU_Species_Product__c> skuProductList, List<Contact> contactList){

        
        List<ZTS_EU_Sample__c> newSampleList = new List<ZTS_EU_Sample__c>();
        List<string> productListForDeactivatingSamples = new List<string>();
        List<ZTS_EU_Sample__c> samplesListToDeactivateFetch = new List<ZTS_EU_Sample__c>();
        List<ZTS_EU_Sample__c> samplesListToDeactivate = new List<ZTS_EU_Sample__c>();
        List<ZTS_EU_Species_Product__c> productListToUpdate = new List<ZTS_EU_Species_Product__c>();
        
        List<String> skuIdlist= new List<String>();
        System.debug('skuProductList-----------'+skuProductList);
        for(ZTS_EU_Species_Product__c sku: skuProductList){
            skuIdlist.add(sku.Id);
        }
        
        List<Contact> veterinarianContactList = new List<Contact>();
        //veterinarianContactList = getAllVeterinarianContacts();
        List<String> vetContactIdlist = new List<String>();
        
        for(Contact vetContact: contactList){
            vetContactIdlist.add(vetContact.Id);
        }
        System.debug('vetContactIdlist----------'+vetContactIdlist.size());
        List<ZTS_EU_Sample__c> existingSampleList = new List<ZTS_EU_Sample__c>();
        existingSampleList = getExistingSamples(vetContactIdlist, skuIdlist);
        
        Set<String> existingSampleUniqueIdList= new Set<String>();
        System.debug('existingSampleList----------'+existingSampleList.size());
        for(ZTS_EU_Sample__c sample: existingSampleList){
            string cId = sample.ZTS_EU_Contact__c;
            string fifteenDigitId = cId.substring(0,15);
            existingSampleUniqueIdList.add(sample.ZTS_EU_Product__r.name + '_' + sample.ZTS_EU_Year__c + '_' + fifteenDigitId);
        }
        
        system.debug('existingSampleUniqueIdList-- ' + existingSampleUniqueIdList );
        
        integer currentYear = System.Today().year();
        string currentYearString = string.valueof(currentYear);
        for(ZTS_EU_Species_Product__c sku: skuProductList){
            
            /*if(sku.ZTS_EU_Is_Active__c == False){
                productListForDeactivatingSamples.add(sku.Id);
            }*/
            
            if(sku.ZTS_EU_Create_Samples__c == False ){
                
                // create samples for all the active and Veterinarian contacts.
                 system.debug('contactList-- ' + contactList.size() );
                for(Contact c: contactList){
                
                    string cId = c.Id;
                    string fifteenDigitId = cId.substring(0,15);
                    string uniqueKey = sku.Name + '_' + currentYearString + '_' + fifteenDigitId;
                    system.debug('uniqueKey-- ' + uniqueKey);
                    
                    if(!existingSampleUniqueIdList.contains(uniqueKey) && c.ZTS_EU_Market__c == sku.ZTS_EU_Market__c){
                        ZTS_EU_Sample__c newSample = new ZTS_EU_Sample__c();
                        newSample.ZTS_EU_Product__c = sku.Id;
                        newSample.ZTS_EU_Contact__c = c.Id;
                        newSample.ZTS_EU_Year__c = currentYearString;
                        newSample.ZTS_EU_Is_Active__c = true;
                        newSample.ZTS_EU_Start_Quantity__c = 10;
                        newSample.ZTS_EU_Account__c = c.Account.Id;
                        newSampleList.add(newSample);
                        
                    }
                }
                
                if(newSampleList.size() > 0){
                    productListToUpdate.add(sku);
                }
            }
            
        }
       /* if(productListForDeactivatingSamples.size() > 0){
                //samplesListToDeactivateFetch = [Select Id, ZTS_EU_Is_Active__c, ZTS_EU_Product__c from ZTS_EU_Sample__c where ZTS_EU_Product__c in: productListForDeactivatingSamples];
                if(samplesListToDeactivateFetch.size() > 0){
                    for(ZTS_EU_Sample__c sample: samplesListToDeactivateFetch){
                        sample.ZTS_EU_Is_Active__c = False;
                        samplesListToDeactivate.add(sample);
                    }
                }
         }*/
         
         /*if(productListToUpdate.size() > 0){
            for(ZTS_EU_Species_Product__c sku: productListToUpdate){
                sku.ZTS_EU_Create_Samples__c = True;
            }
         }*/
       
        system.debug('IP newSampleList sz ' + newSampleList.size());
        system.debug('IP productListToUpdate sz ' + productListToUpdate.size());
        //update samplesListToDeactivate;
        insert newSampleList;
        update productListToUpdate;
       
    }
    
    public static void processSampleDataForInactivatedProducts(List<ZTS_EU_Sample__c> samplesListToDeactivateFetch)
    {   
        List<ZTS_EU_Sample__c> samplesListToDeactivate = new List<ZTS_EU_Sample__c>();
        if(samplesListToDeactivateFetch.size() > 0){
            for(ZTS_EU_Sample__c sample: samplesListToDeactivateFetch){
                sample.ZTS_EU_Is_Active__c = False;
                samplesListToDeactivate.add(sample);
            }
        }
        System.debug('samplesListToDeactivate---Size-------------'+samplesListToDeactivate.Size()); 
        update samplesListToDeactivate;
        
    }   
    
    /*
        Name: getAllSamplableProducts
        purpose: to fetch the list of all the samplable and active products
        Argument: none
        Return type: List<ZTS_EU_Species_Product__c>
    */
    public static List<ZTS_EU_Species_Product__c> getAllSamplableProducts(){
    
        List<String> listOfApplicableMarkets = new  List<String>();
        listOfApplicableMarkets = getListOfApplicableMarkets();
        List<ZTS_EU_Species_Product__c> samplableProductList = new List<ZTS_EU_Species_Product__c>();
        samplableProductList = [Select Id, Name, ZTS_EU_Is_Active__c, ZTS_EU_is_Samplable__c, ZTS_EU_Type__c, ZTS_EU_Is_Old__c, ZTS_EU_Market__c from ZTS_EU_Species_Product__c 
        where ZTS_EU_Is_Active__c = true AND ZTS_EU_is_Samplable__c = true AND ZTS_EU_Type__c = 'SKU' AND ZTS_EU_Is_Old__c = false AND ZTS_EU_Market__c IN: listOfApplicableMarkets];
        return samplableProductList;
    }
    
    /*
        Name: getAllVeterinarianContacts
        purpose: to fetch the list of all the active veterinarian contacts
        Argument: none
        Return type: List<Contact>
    */
    public static List<Contact> getAllVeterinarianContacts(){
    
        List<String> listOfApplicableMarkets = new  List<String>();
        listOfApplicableMarkets = getListOfApplicableMarkets();
        List<Contact> veterinarianContactList = new List<Contact>();
        veterinarianContactList = [Select Id, ZTS_EU_Contact_type__c, ZTS_EU_Contact_Status__c, Account.Id, ZTS_EU_Market__c from Contact
        where ZTS_EU_Contact_Status__c = 'Active' AND ZTS_EU_Contact_type__c = 'Veterinarian' AND ZTS_EU_Market__c IN: listOfApplicableMarkets];
        return veterinarianContactList;
    }
    
     /*
        Name: processSamplesOnYearChange
        purpose: to deactivate the old Samples and create new Samples on year change
        Argument: List<ZTS_EU_Sample__c>
        Return type: none
    */
    public static void processSamplesOnYearChange(List<ZTS_EU_Sample__c> samplesList){
    
           for(ZTS_EU_Sample__c sample: samplesList){
               sample.ZTS_EU_Year__c = System.label.ZTS_EU_YearValueForSamplesBatch;
           }
        
           update samplesList;
    }
    
    /*
        Name: getListOfApplicableMarkets
        Purpose: get the list of all the markets for which the samples batch is applicable.  
        Argument: none
        Return type: List<String>
    */
    public static List<String> getListOfApplicableMarkets(){
    
       List<MarketGeoMapping__c> marketGeoMappingList = new  List<MarketGeoMapping__c>();
       List<String> applicableMarkets = new  List<String>();
       marketGeoMappingList = [Select Name, Geo__c, Applicable_for_Samples_batch_process__c from MarketGeoMapping__c where Applicable_for_Samples_batch_process__c = True];
       for(MarketGeoMapping__c mapping: marketGeoMappingList){
           applicableMarkets.add(mapping.Name);
       }
       return applicableMarkets;
    
    }
    
    /*
        Name: getExistingSamples
        Purpose: get the list of all the existing samples for given contacts and products  
        Argument: List<String>, List<String>
        Return type: List<ZTS_EU_Sample__c>
    */
    public static List<ZTS_EU_Sample__c> getExistingSamples(List<String> contactIds, List<String> skuIds){
    
        List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();
        sampleList = [Select Id, Name, ZTS_EU_Contact__c, ZTS_EU_Contact__r.Name, ZTS_EU_Product__c, ZTS_EU_Product__r.Name, ZTS_EU_Year__c, ZTS_EU_Is_used_for_old_SKUs__c 
                      from ZTS_EU_Sample__c where ZTS_EU_Contact__c IN: contactIds AND (ZTS_EU_Product__c IN: skuIds OR ZTS_EU_Is_used_for_old_SKUs__c = True )];
        return sampleList;
    }

}