/*
Class Name	    : iDevelopConfigurationsSelectorTest
Description	    : Test Class created as part of TPDEV-167 for Code Coverage of iDevelopConfigurationsSelector. 
Created By		: Sibin Kuriakose
Created Date	: 02-15-2023
Modification Log:
----------------------------------------------------------------------------
Var  Developer			         Date			Description
----------------------------------------------------------------------------
01   Sibin Kuriakose             02-15-2023     Added methods to cover selectIDevConfigByMarket method in iDevelopConfigurationsSelector Class
02   Raut, Pranav Krushnarao     02-15-2023     Added methods to cover selectIDevConfigurations method in iDevelopConfigurationsSelector Class
*/
@isTest
private class iDevelopConfigurationsSelectorTest {
    /**     * @Description This method will setup the Test data      
* @Author      Sibin Kuriakose @ Zoetis Inc | 02-15-2023 
*/
    @testSetup static void createTestDataiDevelopConfigurations()
    {
        //Creating multiple Configuration records
        List<iDevelop_Configuration__c> lstIDevCon = new List<iDevelop_Configuration__c>();
        for(Integer i=0; i<10; i++)
        {
            iDevelop_Configuration__c iDev = new iDevelop_Configuration__c(Market__c = 'United States',Role__c = 'SAM');
            lstIDevCon.add(iDev);
        }
        insert lstIDevCon;
    }
    
    /**     * @Description This method will test selectIDevConfigByMarket method     
* @Author      Sibin Kuriakose @ Zoetis Inc | 02-15-2023 
*/
    @isTest static void selectIDevConfigByMarketTest()
    {
        List<iDevelop_Configuration__c> lstIDevConfigTest = [Select Market__c from iDevelop_Configuration__c];
        set<string> setMarket = new set<string>();
        for(iDevelop_Configuration__c objIDevCon: lstIDevConfigTest){
            if((String.isNotBlank(objIDevCon.Market__c))                   
              ){
                  setMarket.add(objIDevCon.Market__c); 
              }
        } 
        
        Test.startTest();
        List<iDevelop_Configuration__c> lstIDevConfig = iDevelopConfigurationsSelector.selectIDevConfigByMarket(setMarket);
        Test.stopTest();
        System.assertEquals(10,lstIDevConfig.size());
    }
    
    /* 
*      @Description :This method will test selectIDevConfigurations method     
*      @Author      :Raut, Pranav Krushnarao @ Zoetis Inc | 02-15-2023 
*/
    @isTest static void selectIDevConfigurationsTest(){     
        Test.startTest();
        List<iDevelop_Configuration__c> lstIdevCofiguration = iDevelopConfigurationsSelector.selectAll();        
        Test.stopTest();
        System.assertEquals(10, lstIdevCofiguration.size());
    }
}