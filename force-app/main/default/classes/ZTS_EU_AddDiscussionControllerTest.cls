/**
 * @description       : Test class for ZTS_EU_AddDiscussionController class
 * @author            : Teresa @ Deloitte Consulting
 * @group             : 
 * @last modified on  : 07-07-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   06-14-????   Teresa @ Deloitte               Created the Class.
 * 1.1   07-07-2022   Ethan Hirsch @ Zoetis Inc       Fix compilation issue with ZTS_EU_DataUtilityTest1.createProductBrandRecord method.
 *                                                    Move where Test.startTest() appears in Tests to avoid SOQL Limits
**/
@isTest(SeeAllData = false)
public with sharing class ZTS_EU_AddDiscussionControllerTest {
    
    public static testMethod void validate_ProductsInDiscussion(){
    try{
        DispatchTriggerHandler.bypass('AccountSpeciesPotentialTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        
        List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest1.createAttendee(1);
        insert attendeeList;
        List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
        insert aspList;
        List<Campaign>campaignList = ZTS_EU_DataUtilityTest1.createCampaignRecord(4);
        insert campaignList;
        List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        insert discItemList;
        Call__c call = new Call__c(ZTS_EU_Account__c = accList[0].id, ZTS_EU_Sub_Type__c = 'Account Call');
        insert call;
        List<ZTS_EU_Species_Product__c> speciesProduct = ZTS_EU_DataUtilityTest1.createProductBrandRecord(1, false);
        insert speciesProduct;      
        Test.startTest();

        PageReference pageRef = Page.ZTS_EU_AddDiscussion;
        Test.setCurrentPage(pageRef);
        List<Call__c> callObj = [SELECT Id FROM Call__c];
        system.debug('************callObj************'+callObj);
        //if(callObj.size() > 0)
            ApexPages.currentPage().getParameters().put('callId',callObj[0].Id); 
            //ApexPages.currentPage().getParameters().put('callId',call.Id);  
            ApexPages.currentPage().getParameters().put('searchString','Brand - Product1 (Product)');  
        List<ZTS_EU_Species_Product__c> productList = [SELECT Id,Name from ZTS_EU_Species_Product__c];
        system.debug('************productList************'+productList);
        ApexPages.StandardSetController setProdCont = new ApexPages.StandardSetController(productList); 
        ZTS_EU_AddDiscussionController addDisc = new ZTS_EU_AddDiscussionController ();
        addDisc.populateProducts();
        addDisc.addSearchString();
        //addDisc.searchProduct();
        addDisc.addProdId = productList[0].Id;
        addDisc.prodName = productList[0].Name;
        addDisc.addProduct();
        addDisc.getProducts();
        
        addDisc.showAttendeesAF();
       
        addDisc.removeProduct();
        Test.stopTest();
       } catch(Exception e){
       }
    }
    
    public static testMethod void validate_CampaignInDiscussion(){
    try{
        DispatchTriggerHandler.bypass('AccountSpeciesPotentialTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        
        List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest1.createAttendee(1);
        insert attendeeList;
        List<ZTS_EU_Account_Species_Potential__c> aspList = ZTS_EU_DataUtilityTest1.createAcctSpeciesPotRecords(4,accList[0].id);
        insert aspList;
        List<Campaign>campaignList = ZTS_EU_DataUtilityTest1.createCampaignRecord(4);
        insert campaignList;
        List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        insert discItemList;
        CampaignMember campMember = new CampaignMember();
        campMember.CampaignId = campaignList[0].Id;
        campMember.ContactId = attendeeList[0].ZTS_EU_Contact__c;
        insert campMember;
         List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
            for (Attendee__c deletedAttendee : attendeeList) {
                ZTS_EU_Discussion__c discussion = new ZTS_EU_Discussion__c(
                    Name = 'Test DI 1',
                    ZTS_EU_Campaign__c=campaignList[0].Id,
                    ZTS_EU_Call_Attendee__c = attendeeList[0].id
                    
                );
                discussionList.add(discussion);
            }
            insert discussionList;
        Test.startTest();
        PageReference pageRef = Page.ZTS_EU_AddDiscussion;
        Test.setCurrentPage(pageRef);
        List<Call__c> callObj = [SELECT Id FROM Call__c];
        system.debug('************callObj************'+callObj);
        if(callObj.size() > 0)
            ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','TestCampaign1 (Campaign)');  
        ApexPages.StandardSetController setCampCont = new ApexPages.StandardSetController(campaignList); 
        ZTS_EU_AddDiscussionController addDisc = new ZTS_EU_AddDiscussionController ();
        addDisc.populateProducts();
        addDisc.addSearchString();
       // addDisc.searchProduct();
        addDisc.addCampId = campaignList[1].Id;
        addDisc.campName = campaignList[1].Name;
        addDisc.addCampaign();
        addDisc.getCampaigns();
        Test.stopTest();
       } catch(Exception e){}
        
    }
    
     public static testMethod void validate_DIInDiscussion(){
    try{
        DispatchTriggerHandler.bypass('AccountSpeciesPotentialTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        
        List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest1.createAttendee(1);
        insert attendeeList;
        List<ZTS_EU_Discussion_Item__c> diList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        insert diList;
        List<Campaign>campaignList = ZTS_EU_DataUtilityTest1.createCampaignRecord(4);
        insert campaignList;
        List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        insert discItemList;
        Test.startTest();
        PageReference pageRef = Page.ZTS_EU_AddDiscussion;
        Test.setCurrentPage(pageRef);
        List<Call__c> callObj = [SELECT Id FROM Call__c];
        system.debug('************callObj************'+callObj);
        if(callObj.size() > 0)
            ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','Description Text title (Discussion Item)');  
        system.debug('************campaignList************'+campaignList);
        ApexPages.StandardSetController setDiscItemsCont = new ApexPages.StandardSetController(diList); 
        ZTS_EU_AddDiscussionController addDisc = new ZTS_EU_AddDiscussionController ();
        addDisc.populateProducts();
        addDisc.addSearchString();
        //addDisc.searchProduct();
        addDisc.addDIId = diList[0].Id;
        addDisc.DIName = diList[0].ZTS_EU_Discussion_Item_Title__c;
        addDisc.addDI();
        addDisc.getdiscitems();
        addDisc.prodName = diList[0].ZTS_EU_Discussion_Item_Title__c;
        addDisc.removeProduct();
        addDisc.hideAttendeesAF();
        addDisc.removeAttendees();
        Test.stopTest();
       } catch(Exception e){}
        
    }
    
    public static testMethod void validate_AddDiscussionClntrl(){
    try{
        DispatchTriggerHandler.bypass('AccountSpeciesPotentialTriggerHandler');
        DispatchTriggerHandler.bypass('AttendeeTriggerHandler');
        DispatchTriggerHandler.bypass('callTriggerHandler');
        DispatchTriggerHandler.bypass('EUSpeciesProductTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('CampaignTriggerHandler');
        
        List<Account> accList = ZTS_EU_DataUtilityTest1.createAccountRecord(1);
        insert accList ;
        List<Attendee__c>attendeeList = ZTS_EU_DataUtilityTest1.createAttendee(1);
        insert attendeeList;
        List<ZTS_EU_Discussion_Item__c> diList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        diList[0].ZTS_EU_Discussion_Item_Title__c = 'test';
        insert diList;
        List<Campaign>campaignList = ZTS_EU_DataUtilityTest1.createCampaignRecord(4);
        campaignList[0].name =  'test';
        insert campaignList;
        List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_EU_DataUtilityTest1.createDiscussionItemsRecord(4);
        insert discItemList;
        List<ZTS_EU_Discussion__c> list_disc = ZTS_EU_DataUtilityTest.createDiscussions(1);
        list_disc[0].ZTS_EU_Call_Attendee__c = attendeeList[0].id;
        insert list_disc;
        List<ZTS_EU_Species_Product__c> list_prod = ZTS_EU_DataUtilityTest1.createProductBURecord(1);
        list_prod[0].ZTS_EU_Type__c = 'Brand';
        list_prod[0].name = 'test';
        insert list_prod;
        Test.startTest();
        PageReference pageRef = Page.ZTS_EU_AddDiscussion;
        Test.setCurrentPage(pageRef);
        List<Call__c> callObj = [SELECT Id FROM Call__c];
        system.debug('************callObj************'+callObj);
        if(callObj.size() > 0)
            ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString',' (Product) (Discussion Item) (Campaign) (Discussion Item)');  
        system.debug('************campaignList**@@**********'+campaignList);
        ApexPages.StandardSetController setDiscItemsCont = new ApexPages.StandardSetController(diList); 
        ZTS_EU_AddDiscussionController addDisc = new ZTS_EU_AddDiscussionController ();
        system.debug('******@@*********');
        addDisc.searchString = ' (Product) (Campaign) (Discussion Item)';
        addDisc.addSearchString();
        addDisc.searchString = ' (Product)test';
        addDisc.addSearchString();
         addDisc.searchString = ' (Campaign)test';
        addDisc.addSearchString();
        addDisc.searchString = ' (Discussion Item)test';
        addDisc.addSearchString();
        addDisc.attendeeRemoveId = attendeeList[0].id;
        addDisc.removeAttendees();
        addDisc.discuname = 'test';
        addDisc.removeAttendees();
        Test.stopTest();
       } catch(Exception e){}
        
    }
	

}