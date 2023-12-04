/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_Mass_Add_Account_to_Camp_ExTest
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     6/16         Mayank             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class ZTS_EU_Mass_Add_Account_to_Camp_ExTest 
{   
    static List<Campaign> listCamp;
    
    public static void createTestData(){
        listCamp = ZTS_EU_DataUtilityTest1.createCampaignRecord(1);
        insert listCamp;
    }
    
    static testMethod void constructorTest(){
        test.startTest();
        createTestData();
        
        ApexPAges.StandardController sc = new ApexPages.StandardController(listCamp[0]);
        PageReference massAddAccPage = Page.ZTS_EU_Mass_Add_Account_to_Campaign;
        Test.setCurrentPage(massAddAccPage);
        ApexPages.currentPage().getParameters().put('id', listCamp[0].Id);
        
        ZTS_EU_Mass_Add_Account_to_Campaign_Ext massContact = new ZTS_EU_Mass_Add_Account_to_Campaign_Ext(sc);
     
        test.stopTest();
    }
}