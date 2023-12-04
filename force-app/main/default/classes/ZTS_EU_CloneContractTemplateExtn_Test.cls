/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_CloneContractTemplateExtn_Test.cls
   Description: Test Class for ExtensionClass ZTS_EU_CloneContractTemplateExtn.cls
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   25-11-2014   1.0     CloudSense(Bimba)   Initial Version          
------------------------------------------------------------------------------------------------------------------------ */
@isTest
public class ZTS_EU_CloneContractTemplateExtn_Test{

 /*******************************************************************
     Purpose:  Method to create test data                                                     
     Parameters: none
     Returns: none
     *******************************************************************/ 
    
    public static String busUnit = 'Business Unit';
    public static String brand = 'Brand';
    public static String UK = 'United Kingdom';
    
     static testMethod void testCTCloneController(){
        User user = ZTS_EU_DataUtilityTest.createUtilityUser(true,' ',' ',UK);
        List<ZTS_EU_Species_Product__c> prodHierList = new List<ZTS_EU_Species_Product__c>();
        System.runAs(user){
            PageReference pgRef = Page.ZTS_EU_CloneContractTemplate;
            Test.setCurrentPage(pgRef);
            
            
            //Test data creation
            String busUnitRecordTypeId = [SELECT Id FROM RecordType 
                                            WHERE DeveloperName = 'Business_Unit'].Id;
            String contractTemplateRecTypeId = [SELECT Id FROM RecordType
                                    WHERE DeveloperName = 'Contract_Template_non_Expired'].Id;
            String brandRecordTypeId = [SELECT Id FROM RecordType 
                                    WHERE DeveloperName = 'Brand'].Id;
            //Create a Business Unit record
            ZTS_EU_Species_Product__c prodHier1 = TestUtilities.createNoInsertBusUnit('Companion Animals',busUnit,UK,'CA',busUnitRecordTypeId);
            ZTS_EU_Species_Product__c prodHier2 = TestUtilities.createNoInsertBusUnit('Draxxin',brand,UK,'CA',brandRecordTypeId);
            prodHierList.add(prodHier1);
            prodHierList.add(prodHier2);
            database.insert(prodHierList,false);
            system.debug('TestClass--->inserted Business Unit and Brand---->'+prodHierList);
            //Create a Contract template record
            ZTS_EU_ContractTemplate__c conTem = new ZTS_EU_ContractTemplate__c();
            conTem.Name = 'TestContractTemplate';
            conTem.RecordTypeId = contractTemplateRecTypeId;
            conTem.ZTS_EU_CTBusiness_Unit__c = prodHierList[0].Id;
            conTem.ZTS_EU_Discount__c = 30.00;
            conTem.ZTS_EU_Discount_Type__c = 'Fixed Discount';
            conTem.ZTS_EU_End_Date__c = Date.newInstance(2016,01,01);
            conTem.ZTS_EU_Fiscal_Year__c = '2014';
            conTem.ZTS_EU_Short_Code__c = '124';
            conTem.ZTS_EU_Start_Date__c = System.Today();
            conTem.ZTS_EU_Status__c = 'Active';
            conTem.ZTS_EU_Type__c = 'Bonus';
            
            insert conTem;
            system.debug('TestClass--->inserted Contract Template---->'+conTem);
            //Id testctidparam = ApexPages.currentPage().getParameters().put('id',conTem.Id);
            Id testctidparam = pgRef.getParameters().put('id',conTem.Id);
            //system.debug('TestClass---->idParamset--->'+testctidparam);
            
            //Create the Product Contract Template Association record 
            Product_Contract_Template_Association__c pcta = new Product_Contract_Template_Association__c();
            pcta.ZTS_EU_Contract_Template__c = conTem.Id ;
            pcta.ZTS_EU_Product_Hierarchy__c = prodHierList[1].Id;
            database.insert(pcta,false);
            system.debug('TestClass--->inserted PCTA---->'+pcta);
            
            
            //Construct the standard controller
            ApexPages.StandardController con = new ApexPages.StandardController(conTem);
            
            //Create the controller
            ZTS_EU_CloneContractTemplateExtn ext = new ZTS_EU_CloneContractTemplateExtn(con);
            
            Test.startTest();
            //Call the Cloning Action method
            PageReference pg = ext.clonePCTA();
            
            //Create a matching page reference
            PageReference redirect = new PageReference('/'+ext.newCTRecId+'/e?retURL=%2f'+conTem.Id);
            //PageReference redirect = new PageReference('/'+ext.newCTRecId);
            //check if the user is sent to the right URL
            system.debug('TestClass--->newCTRecIDValue--->'+ext.newCTRecId);
            
            Test.stopTest();
            //system.assertEquals(pg.getURL(),redirect.getURL());
            
            
            
        }
     }
}