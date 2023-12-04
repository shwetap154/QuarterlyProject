/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AddGiftFromCallController
* Description   :  This is the controller of the vf page: ZTS_EU_AddGiftFromCall.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     30th-Dec-14   Shreyas             Created the class.
* 1.1	  20th-Feb-15   Ilirjana Predojević	Updated the class.

********************************************************************************************************************************************/
public class ZTS_EU_AddGiftFromCallController {


    public string callId {get; set;}
    public List<ZTS_EU_Gift__c> existingGifts {get; set;}
    public string giftId {get; set;}
    public integer existingGiftListSize {get; set;}
    public boolean showNewGift {get; set;}
    public ZTS_EU_Gift__c newGift {get; set;}
    public string contactId; 


    // Constructor
    public ZTS_EU_AddGiftFromCallController(){
        callId = ApexPages.currentPage().getParameters().get('callId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        if (callId == null){ //IP 20-Feb-15 If there is no parameter callId, we are on the main call page, so take value from parameter Id
            callId = ApexPages.currentPage().getParameters().get('Id');
        }
        getExistingGifts();
        existingGiftListSize = existingGifts.size();
        showNewGift = false;
    }
    
    /*
        Name: getExistingGifts
        Purpose: fetch the existing gifts
        arguments: none
        return type: none
    */
    public void getExistingGifts(){
        
        existingGifts = new List<ZTS_EU_Gift__c>();
        existingGifts = [Select Id, Name, ZTS_EU_Contact__c, ZTS_EU_Gift_type__c, ZTS_EU_Quantity__c, ZTS_EU_Product_Hierarchy__c, ZTS_EU_Call__c, 
                        ZTS_EU_Year__c, ZTS_EU_Description__c from ZTS_EU_Gift__c where ZTS_EU_Call__c =: callId order by Name];
    }

    /*
        Name: deleteGift
        Purpose: delete the selected gift
        arguments: none
        return type: none
    */
    public pagereference deleteGift(){
        
        ZTS_EU_Gift__c giftToDelete = new ZTS_EU_Gift__c();
        giftToDelete = [select Id from ZTS_EU_Gift__c where Id =: giftId];
        
        try{
            delete giftToDelete;
        }
        catch(exception e){
            system.debug('Exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
        }
        getExistingGifts();
        existingGiftListSize = existingGifts.size();
        return null;
    }
    
    /*
        Name: showNewGift
        Purpose: show the section on the page on click of 'New Gift' link. 
        arguments: none
        return type: none
    */
    public pagereference showNewGift(){
        showNewGift = true;
        newGift = new ZTS_EU_Gift__c();
        if(contactId != 'null'){
            newGift.ZTS_EU_Contact__c = contactId;
        }
        return null;
    }
    
    /*
        Name: saveNewGift
        Purpose: Save the newly created Gift record. 
        arguments: none
        return type: none
    */
    public pagereference saveNewGift(){
        try{
            newGift.ZTS_EU_Call__c = callId;
            insert newGift;
        }
        catch(exception e){
            system.debug('Exception'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
        }
        getExistingGifts();
        existingGiftListSize = existingGifts.size();
        newGift = new ZTS_EU_Gift__c();
        showNewGift = false;
        return null;
    }
    
     /*
        Name: cancelNewGift
        Purpose: to hide the section for adding new Gift on click of cancel button. 
        arguments: none
        return type: none
    */
    public pagereference cancelNewGift(){
        showNewGift = false;
        return null;
    }
    
}