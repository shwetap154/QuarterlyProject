/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AddSampleDropsController
* Description   :  This is the controller of the vf page: ZTS_EU_AddSampleDrops.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     20th-Nov-14   Shreyas             Created the class.

********************************************************************************************************************************************/

public with sharing class ZTS_EU_AddSampleDropsController {

    public string callId {get; set;}
    public List<Sample_Drop__c> existingSampleDropList {get; set;}
    public List<Attendee__c> existingAttendeeList {get; set;}
    public Sample_Drop__c newSampleDrop {get; set;}
    public boolean showNewSampleDrop {get; set;}
    public string sampleDropId {get; set;}
    public string selectedSampleId {get; set;}
    public boolean showProductLookup {get; set;}
    public string SAMPLEDROPTYPE = 'Sample Drop';
    public ZTS_EU_Sample__c sample {get; set;}
    public integer existingSampleDropListSize {get; set;}
    public string oldYear{get;set;}
    public Map<id,String> SampDropVSYear {get;set;}
    public Map<id,String> SampDropVSNewYear {get;set;}
    // Constructor
    public ZTS_EU_AddSampleDropsController(){
    
        callId = ApexPages.currentPage().getParameters().get('callId');
        existingSampleDropList = new List<Sample_Drop__c>();
        existingAttendeeList = new List<Attendee__c>();
        newSampleDrop = new Sample_Drop__c();
        showNewSampleDrop = false;
        showProductLookup = false;
        getExistingSampleDrops();
        existingSampleDropListSize = existingSampleDropList.size();
        getExistingAttendees();
    }
    
    /*
        Name: getExistingSampleDrops
        Purpose: fetch the sample drops associated to the base call record. 
        arguments: none
        return type: none
    */
    public void getExistingSampleDrops(){
        existingSampleDropList = [Select Id, Name, ZTS_EU_Sample__c,ZTS_EU_Sample__r.ZTS_EU_Contact__c, ZTS_EU_Sample_Drop_Type__c, ZTS_EU_Quantity__c, ZTS_EU_Product__c, 
                                  ZTS_EU_Sample__r.ZTS_EU_Product__c,ZTS_EU_Product__r.ZTS_EU_Is_Old__c,ZTS_EU_Species_Product_New_SKU__r.ZTS_EU_Is_Old__c , ZTS_EU_Species_Product_New_SKU__c,ZTS_EU_Species_Product_New_SKU__r.Year__C,ZTS_EU_Product__r.Year__C 
                                  from Sample_Drop__c where ZTS_EU_Call__c =: callId order by Name];
            
        
            SampDropVSYear = new Map<id,String>();
            SampDropVSNewYear =  new Map<id,String>();
            for(Sample_Drop__c sd : existingSampleDropList)
            {
                if(sd.ZTS_EU_Product__r.Year__C !=null )
                {
                    SampDropVSYear.put(sd.id,String.valueOf(integer.valueOf(sd.ZTS_EU_Product__r.Year__C)));
                    
                }
                else
                {
                    SampDropVSYear.put(sd.id,'---');
                }
                if(sd.ZTS_EU_Species_Product_New_SKU__r.Year__C !=null )
                {
                    SampDropVSNewYear.put(sd.id,String.valueOf(integer.valueOf(sd.ZTS_EU_Species_Product_New_SKU__r.Year__C)));
                }
                else
                {
                    SampDropVSNewYear.put(sd.id,'---');
                }                   
            }
        System.debug('SampDropVSYear-------'+SampDropVSYear);
        System.debug('SampDropVSNewYear-------'+SampDropVSNewYear); 
    
    }
    
    /*
        Name: getExistingAttendees
        Purpose: fetch the attendes associated to the base call record. 
        arguments: none
        return type: none
    */
    
    public void getExistingAttendees(){
        existingAttendeeList = [Select ZTS_EU_Contact__c, ZTS_EU_Contact_Profession__c, ZTS_EU_Represents_Account__c from Attendee__c where ZTS_EU_call__c =: callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
    }
    
    /*
        Name: saveNewSampleDrop
        Purpose: Save the newly created sample drop record. 
        arguments: none
        return type: none
    */
    public pagereference saveNewSampleDrop(){
        //newSampleDrop.Contact__c = newSampleDrop.ZTS_EU_Sample__r.ZTS_EU_Contact__c;
        List<ZTS_EU_Species_Product__c> productList = new List<ZTS_EU_Species_Product__c>();
        List<Contact> contactList = new List<Contact>();
         List<Contact> contactList1 = new List<Contact>();
        List<ZTS_EU_Species_Product__c> productList2 = new List<ZTS_EU_Species_Product__c>();
        System.debug('newSampleDrop+++'+newSampleDrop);
        productList2 = [Select Id, Name, ZTS_EU_Is_Old__c,Year__c from ZTS_EU_Species_Product__c where Id=:newSampleDrop.ZTS_EU_Product__c or Id=:newSampleDrop.ZTS_EU_Species_Product_New_SKU__c ];
        system.debug('productList--2---------'+productList2);
        
        if(productList2.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select the Species/Product.'));
            return null;
        }
        Integer year = Integer.valueOf(productList2[0].Year__c);
        
        decimal count = 0.0;
        decimal count1 = 0.0;
        decimal count2 = 0.0;
        System.debug('year----------'+year);
        //system.debug('isOld---------------'+newSampleDrop.ZTS_EU_Product__r.ZTS_EU_Is_Old__c);
        List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();
        sampleList = [select id, Name,ZTS_EU_Contact__c from ZTS_EU_Sample__c where id =:newSampleDrop.ZTS_EU_Sample__c];
                Id contactId = sampleList[0].ZTS_EU_Contact__c;
                 system.debug('contactId---------'+contactId);
                contactList = [Select Id, Name,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Product__r.ZTS_EU_Is_Old__c from  Sample_Drops__r where ZTS_EU_Product__r.ZTS_EU_Is_Old__c = true) from Contact where id =:contactId and ZTS_EU_Market__c != 'Italy' AND ZTS_EU_Market__c != 'United States'];
                contactList1 = [Select Id, Name,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Product__r.ZTS_EU_Is_Old__c from  Sample_Drops__r where ZTS_EU_Product__r.ZTS_EU_Is_Old__c = true) from Contact where id =:contactId and ZTS_EU_Market__c = 'Italy' AND ZTS_EU_Market__c != 'United States'];
                system.debug('contactList---------------'+contactList );
                system.debug('contactList -Size----------'+contactList .size());
        try{
            if(productList2[0].ZTS_EU_Is_Old__c == true)
            {
                
                //productList = [Select Id, Name, ZTS_EU_Is_Old__c,(Select Id, Name,ZTS_EU_Quantity__c from  Sample_Drops__r) from ZTS_EU_Species_Product__c where Year__c=:year and ZTS_EU_Is_Old__c = true ];
                system.debug('productList-----------'+productList);
                system.debug('productList-Size----------'+productList.size());
                
                contactList = [Select Id, Name,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Product__r.ZTS_EU_Is_Old__c,ZTS_EU_Product__r.Year__c from  Sample_Drops__r where ZTS_EU_Product__r.ZTS_EU_Is_Old__c = true and ZTS_EU_Product__r.Year__c=:year) from Contact where id =:contactId and ZTS_EU_Market__c != 'Italy' AND ZTS_EU_Market__c != 'United States']; 
                 contactList1 = [Select Id, Name,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Product__r.ZTS_EU_Is_Old__c from  Sample_Drops__r where ZTS_EU_Product__r.ZTS_EU_Is_Old__c = true) from Contact where id =:contactId and ZTS_EU_Market__c = 'Italy'];
                       
                for(Contact con: contactList)
                {
                    
                    for(Sample_Drop__c drop : con.Sample_Drops__r)
                    {                       
                    
                        count = count + drop.ZTS_EU_Quantity__c; 
                       
                    }                   
                        
                }
                
                count = count + newSampleDrop.ZTS_EU_Quantity__c;
                system.debug('count 2-----------'+count);
     /**************************************************************For Italy market**************************/           
                for(Contact con: contactList)
                {
                    
                    for(Sample_Drop__c drop : con.Sample_Drops__r)
                    {                       
                    
                        count1 = count1 + drop.ZTS_EU_Quantity__c; 
                       
                    }             
                        
                }
                
                count1 = count1 + newSampleDrop.ZTS_EU_Quantity__c;
                system.debug('count 2-----------'+count);
                
    /**************************************************************For Italy market**************************/   
                if (count > 10.0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quantity dropped can not be greater than 10 for all OLD SKUs for this contact' ));
                }
                else if(count1 > 10.0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quantity dropped can not be greater than 10 for all OLD SKUs for this contact' ));
                }
                else{
                    newSampleDrop.ZTS_EU_Call__c = callId;
                    newSampleDrop.ZTS_EU_Sample_Drop_Type__c = SAMPLEDROPTYPE;              
                    insert newSampleDrop;
                }
                count = 0;
                count1 =0;
            }
            else{
                
                decimal newCount = 0.0;
                List<ID> productIdList = new List<Id>();
                contactList = [Select Id, Name,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Species_Product_New_SKU__c,ZTS_EU_Species_Product_New_SKU__r.ZTS_EU_Is_Old__c,ZTS_EU_Species_Product_New_SKU__r.Year__c from  Sample_Drops__r where ZTS_EU_Species_Product_New_SKU__r.ZTS_EU_Is_Old__c = false and ZTS_EU_Species_Product_New_SKU__r.Year__c=:year) from Contact where id =:contactId AND ZTS_EU_Market__c != 'United States'];
                system.debug('else--------------------');
                for(contact con: contactList)
                {
                    system.debug('con.Sample_Drops__r-size-----'+con.Sample_Drops__r.Size());
                    for(Sample_Drop__c drop : con.Sample_Drops__r)
                    {
                        system.debug('abcdefinsidedrop'+drop);
                        system.debug('abcdef'+drop.ZTS_EU_Quantity__c);
                        system.debug('abcdef'+drop.ZTS_EU_Species_Product_New_SKU__r.ZTS_EU_Is_Old__c);                     
                        productIdList.add(drop.ZTS_EU_Species_Product_New_SKU__c);  
                    }   
                }
                system.debug('productIdList-----------'+productIdList);
                productList = [Select Id, Name, ZTS_EU_Is_Old__c,(Select Id, Name,ZTS_EU_Quantity__c,ZTS_EU_Sample__r.ZTS_EU_Contact__c from Sample_Drops1__r) from ZTS_EU_Species_Product__c where id IN : productIdList ];
                system.debug('productList-----------'+productList);
                system.debug('productList-Size----------'+productList.size());
                

                
                for(contact con: contactList)
                {
                    for(ZTS_EU_Species_Product__c prod: productList)
                    {  
                    
                        //if(prod.id == newSampleDrop.ZTS_EU_Species_Product_New_SKU__c && newSampleDrop.ZTS_EU_Sample__r.ZTS_EU_Contact__c == con.id )
                            for(Sample_Drop__c conDrop : con.Sample_Drops__r)
                            {
                                    
                                for(Sample_Drop__c prodDrop : prod.Sample_Drops1__r)
                                {                       
                                    if(conDrop.id == prodDrop.id && prod.id == newSampleDrop.ZTS_EU_Species_Product_New_SKU__c)
                                    {
                                        System.debug('Matched=========');
                                        newCount = newCount +prodDrop.ZTS_EU_Quantity__c;
                                        system.debug('newCount 1-----------'+newCount);
                                    }
                                    
                                } 
                            }   
                        
                    }   
                    
                }
                
                system.debug('newCount 1-----------'+newCount);
                newCount = newCount + newSampleDrop.ZTS_EU_Quantity__c;
                system.debug('newCount 2-----------'+newCount);
                if(newCount > 10.0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quantity dropped can not be greater than 10 per SKU for this Contact ' ));
                }
                else{
                    newSampleDrop.ZTS_EU_Call__c = callId;
                    newSampleDrop.ZTS_EU_Sample_Drop_Type__c = SAMPLEDROPTYPE;
                    insert newSampleDrop;
                } 
            }
            
            
        }
        catch(exception e){
            system.debug('Exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
        }
        getExistingSampleDrops();
        existingSampleDropListSize = existingSampleDropList.size();
        newSampleDrop = new Sample_Drop__c();
        showNewSampleDrop = false;
        return null;
    }
    
    /*
        Name: showNewSampleDrop
        Purpose: show the section on the page on click of new smaple drop link. 
        arguments: none
        return type: none
    */
    public pagereference showNewSampleDrop(){
        showNewSampleDrop = true;
        showProductLookup = false;
        sample = new ZTS_EU_Sample__c();
        return null;
    }
    
    /*
        Name: deleteSampleDrop
        Purpose: delete the selected sample drop 
        arguments: none
        return type: none
    */
    public pagereference deleteSampleDrop(){
        
        Sample_Drop__c sampleDropToDelete = new Sample_Drop__c();
        sampleDropToDelete = [select Id from Sample_Drop__c where Id =: sampleDropId];
        
        try{
            delete sampleDropToDelete;
        }
        catch(exception e){
            system.debug('Exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
        }
        getExistingSampleDrops();
        existingSampleDropListSize = existingSampleDropList.size();
        return null;
    }
    
    /*
        Name: cancelNewSampleDrop
        Purpose: to hide the section for adding new sample drop on click of cancel button. 
        arguments: none
        return type: none
    */
    public pagereference cancelNewSampleDrop(){
        showNewSampleDrop = false;
        newSampleDrop.ZTS_EU_Product__c = null;
        newSampleDrop.ZTS_EU_Species_Product_New_SKU__c = null;
        return null;
    }
    
    /*
        Name: determineOldSkuSample
        Purpose:  to determine whether the selected sample record is Old sku or not. If yes, then show the product lookup for new sample drop.
        arguments: none
        return type: none
    */
    public pagereference determineOldSkuSample(){
        
        newSampleDrop.ZTS_EU_Species_Product_New_SKU__c = null;
        sample = new ZTS_EU_Sample__c();
        sample = [Select Id, ZTS_EU_Is_used_for_old_SKUs__c, ZTS_EU_Product__c from ZTS_EU_Sample__c where Id =: selectedSampleId];
        if(sample.ZTS_EU_Is_used_for_old_SKUs__c){
            showProductLookup = true;
            newSampleDrop.ZTS_EU_Product__c = null;
        }
        else{
            showProductLookup = false;
            newSampleDrop.ZTS_EU_Species_Product_New_SKU__c = sample.ZTS_EU_Product__c;
        }
        
        return null;
    }
    
}