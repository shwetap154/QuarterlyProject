/*******************************************************************************************************************************************
* File Name     :  AddDiscussionControllerTest
* Description   :  Test class for AddDiscussionController class
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/2          Akanksha          Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class AddDiscussionControllerTest {
    
    static final String US_USER_FN = 'usUser';
    
    @TestSetup
    static void createTestData(){
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = US_USER_FN;
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(1);
            insert accList ;
            List<Attendee__c>attendeeList = ZTS_DataUtilityTest.createAttendee(1);
            insert attendeeList;
            List<Campaign>campaignList = ZTS_DataUtilityTest.createCampaignRecord(4);
            insert campaignList;
            List<ZTS_EU_Discussion_Item__c>discItemList = ZTS_DataUtilityTest.createDiscussionItemsRecord(4);
            insert discItemList;
        }
    }
    
    @isTest
    static void validate_ProductsInDiscussion(){
        
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            List<Account> accList = [SELECT Id FROM Account];
            List<Attendee__c> attendeeList = [SELECT Id FROM Attendee__c];
            List<Campaign> campaignList = [SELECT Id FROM Campaign];
            List<ZTS_EU_Discussion_Item__c> discItemList = [SELECT Id FROM ZTS_EU_Discussion_Item__c];
            
            PageReference pageRef = Page.AddDiscussion;
            Test.setCurrentPage(pageRef);
            
            ZTS_EU_Species_Product__c prod= new ZTS_EU_Species_Product__c(Name='Test Product',ZTS_Hierarchy_Level__c='Brand');
            List<ZTS_EU_Species_Product__c> productList= new List<ZTS_EU_Species_Product__c>();
            productList.add(prod);
            insert productList;
            
            List<Call__c> callObj = [SELECT Id FROM Call__c];
            
            System.debug('************callObj************'+callObj);
            
            if(callObj.size() > 0)
                ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','BrandProduct1 (Product)');  
            ApexPages.StandardSetController setProdCont = new ApexPages.StandardSetController(productList); 
            AddDiscussionController addDisc = new AddDiscussionController ();
            
            Test.startTest();
            addDisc.searchString = 'BrandProduct1 (Product)';
            addDisc.populateProducts();
            addDisc.addSearchString();
            addDisc.searchProduct();
            addDisc.addProdId = productList[0].Id;
            addDisc.prodName = productList[0].Name;
            addDisc.addProduct();
            List<ZTS_EU_Discussion__c> discListAfterAdd = [SELECT Id FROM ZTS_EU_Discussion__c];
            System.assertNotEquals(0, discListAfterAdd.size(), 'The expected size should of products should be greater than 0');
            
            addDisc.getProducts();
            addDisc.attendeeRemoveId = attendeeList[0].id;
            addDisc.removeAttendees();
            addDisc.showAttendeesAF();
            System.assertEquals(true, addDisc.showattendee , 'The expected value of ShowAttendee must be true');
            System.assertEquals(true, addDisc.hideattendee , 'The expected value of hideattendee must be true');
            
            addDisc.removeProduct();
            List<ZTS_EU_Discussion__c> discList = [SELECT Id FROM ZTS_EU_Discussion__c];
            System.assertEquals(0, discList.size(), 'The expected size should of products should be 0');
            
            addDisc.hideAttendeesAF(); 
            System.assertEquals(false, addDisc.showattendee , 'The expected value of ShowAttendee must be false');
            System.assertEquals(false, addDisc.hideattendee , 'The expected value of hideattendee must be false');       
            Test.stopTest();
        }
        
    }
    
    
    @isTest
    static void validate_CampaignInDiscussion(){
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            Test.startTest();
            List<Account> accList = [SELECT Id FROM Account];
            List<Attendee__c> attendeeList = [SELECT Id FROM Attendee__c];
            List<Campaign> campaignList = [SELECT Id, Name FROM Campaign];
            List<ZTS_EU_Discussion_Item__c> discItemList = [SELECT Id FROM ZTS_EU_Discussion_Item__c];
            
            PageReference pageRef = Page.AddDiscussion;
            Test.setCurrentPage(pageRef);
            List<Call__c> callObj = [SELECT Id FROM Call__c];
            system.debug('************callObj************'+callObj);
            if(callObj.size() > 0)
                ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','TestCampaign1 (Campaign)');  
            ApexPages.StandardSetController setCampCont = new ApexPages.StandardSetController(campaignList); 
            AddDiscussionController addDisc = new AddDiscussionController ();
            addDisc.searchString = 'TestCampaign1 (Campaign)';
            addDisc.populateProducts();
            
            addDisc.addSearchString();
            addDisc.searchProduct();
            addDisc.addCampId = campaignList[1].Id;
            addDisc.campName = campaignList[1].Name;
            addDisc.addCampaign();
            List<ZTS_EU_Discussion__c> discListAfterAdd = [SELECT Id FROM ZTS_EU_Discussion__c];
            System.assertNotEquals(0, discListAfterAdd.size(), 'The expected size of ZTS_EU_Discussion__c after addCampaign should be greater than 0');
            
            addDisc.getCampaigns();
            System.debug('Original CAMPAIGN LIST-->'+campaignList);
            System.debug('GET Campaign --->'+addDisc.getCampaigns());
            addDisc.showAttendeesAF();
            System.assertEquals(true, addDisc.showattendee , 'The expected value of ShowAttendee must be true');
            System.assertEquals(true, addDisc.hideattendee , 'The expected value of hideattendee must be true');
            
            addDisc.attendeeRemoveId = attendeeList[0].id;
            addDisc.removeAttendees();
            addDisc.hideAttendeesAF();  
            System.assertEquals(false, addDisc.showattendee , 'The expected value of ShowAttendee must be false');
            System.assertEquals(false, addDisc.hideattendee , 'The expected value of hideattendee must be false');   
            Test.stopTest();
        }
        
    }
    
    @isTest
    static void validate_DIInDiscussion(){
        User usr = [SELECT Id FROM User WHERE FirstName = :US_USER_FN];
        
        System.runAs(usr)
        {
            List<Account> accList = [SELECT Id FROM Account];
            List<Attendee__c> attendeeList = [SELECT Id FROM Attendee__c];
            List<Campaign> campaignList = [SELECT Id FROM Campaign];
            List<ZTS_EU_Discussion_Item__c> diList = [SELECT Id, ZTS_EU_Discussion_Item_Title__c FROM ZTS_EU_Discussion_Item__c];
            
            PageReference pageRef = Page.AddDiscussion;
            Test.setCurrentPage(pageRef);
            List<Call__c> callObj = [SELECT Id FROM Call__c];
            system.debug('************callObj************'+callObj);
            if(callObj.size() > 0)
                ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','Description Text title (Discussion Item)');  
            system.debug('************campaignList************'+campaignList);
            ApexPages.StandardSetController setDiscItemsCont = new ApexPages.StandardSetController(diList); 
            AddDiscussionController addDisc = new AddDiscussionController ();
            addDisc.searchString = 'Description Text title (Discussion Item)'; 
            Test.startTest();
            addDisc.populateProducts();
            addDisc.addSearchString();
            addDisc.searchProduct();
            addDisc.addDIId = diList[0].Id;
            addDisc.DIName = diList[0].ZTS_EU_Discussion_Item_Title__c;
            addDisc.addDI();
            List<ZTS_EU_Discussion__c> discListAfterAdd = [SELECT Id FROM ZTS_EU_Discussion__c];
            System.assertNotEquals(0, discListAfterAdd.size(), 'The expected size of ZTS_EU_Discussion__c after addDI() should be greater than 0');
            
            addDisc.getdiscitems();
            addDisc.prodName = diList[0].ZTS_EU_Discussion_Item_Title__c;
            
            addDisc.showAttendeesAF();
            System.assertEquals(true, addDisc.showattendee , 'The expected value of ShowAttendee must be true');
            System.assertEquals(true, addDisc.hideattendee , 'The expected value of hideattendee must be true');
            addDisc.removeProduct();
            List<ZTS_EU_Discussion__c> discList = [SELECT Id FROM ZTS_EU_Discussion__c];
            System.assertEquals(0, discList.size(), 'The expected size should of products should be 0');
            
            addDisc.attendeeRemoveId=attendeeList[0].id;
            addDisc.removeAttendees();
            
            addDisc.hideAttendeesAF();  
            System.assertEquals(false, addDisc.showattendee , 'The expected value of ShowAttendee must be false');
            System.assertEquals(false, addDisc.hideattendee , 'The expected value of hideattendee must be false');   
            
            Test.stopTest();
            
        }
    }
}