/*
Class Name	    : iDevelopConfigurationsServiceTest
Description	    : Test Class created as part of TPDEV-167 for Code Coverage of iDevelopConfigurationsService. 
Created By		: Sibin Kuriakose
Created Date	: 02-15-2023 
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver   Developer				Date		  Description
-------------------------------------------------------------------------------------------------------------------------
01    Sibin Kuriakose       02-15-2023   Added methods to cover iDevelopConfigValidations method in iDevelopConfigurationsService Class
02	  Kalyan Nayak			03-02-2023	 Added method to cover oldMap in iDevelopConfigValidations method in iDevelopConfigurationsService Class
*/
@isTest 
public class iDevelopConfigurationsServiceTest {
    /**     * @Description This method will setup the Test data      
			* @Author      Sibin Kuriakose @ Zoetis Inc | 02-15-2023 
    */
    @testSetup static void setupData() {
        //Creating a Configuration record
        List<iDevelop_Configuration__c> lstIdevConf = new List<iDevelop_Configuration__c>();
        //First Configuration record
        iDevelop_Configuration__c IDevConfTest1 = new iDevelop_Configuration__c();
        IDevConfTest1.Market__c = 'United States';
        IDevConfTest1.Role__c = 'SAM';
        lstIdevConf.add(IDevConfTest1);
        //Second Configuration record
        iDevelop_Configuration__c IDevConfTest2 = new iDevelop_Configuration__c();
        IDevConfTest2.Market__c = 'United States';
        IDevConfTest2.Role__c = 'ABM';
        lstIdevConf.add(IDevConfTest2);
        
        insert lstIdevConf;
        
    }
    
    /**     * @Description This method will test iDevelopConfigValidations method     
			* @Author      Sibin Kuriakose @ Zoetis Inc | 02-15-2023 
    */
	 @isTest 
     public static void  iDevelopConfigurationsServiceTest1(){
         Map<Id, iDevelop_Configuration__c> mapIDevConf = new Map<Id, iDevelop_Configuration__c>([SELECT id, Market__c, Role__c FROM iDevelop_Configuration__c]);
         Test.startTest();
         iDevelopConfigurationsService.iDevelopConfigValidations(mapIDevConf.values(),mapIDevConf);
         try{
             mapIDevConf.values()[0].Role__c = 'ABM';
             update mapIDevConf.values()[0];
         }
         catch(Exception e){
             Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.iDevelopConfigExistingConfig) ? true : false;
             System.AssertEquals(expectedExceptionThrown, true);
         }
         Test.stopTest();
     }
    
    /**     * @Description This method will test iDevelopConfigValidations method     
			* @Author      Kalyan Nayak @ Zoetis Inc | 03-02-2023 
    */
    @isTest
    public static void  iDevelopConfigurationsServiceTest2(){
         Map<Id, iDevelop_Configuration__c> mapIDevConf = new Map<Id, iDevelop_Configuration__c>([SELECT id, Market__c, Role__c FROM iDevelop_Configuration__c]);
         Test.startTest();
         iDevelopConfigurationsService.iDevelopConfigValidations(mapIDevConf.values(),null);
         try{
             mapIDevConf.values()[0].Role__c = 'ABM';
             update mapIDevConf.values()[0];
         }
         catch(Exception e){
             Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.iDevelopConfigExistingConfig) ? true : false;
             System.AssertEquals(expectedExceptionThrown, true);
         }
         Test.stopTest();
     }
    
}