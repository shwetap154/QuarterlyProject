/*******************************************************************************************************************************************
* File Name     :  ZTS_GL_ChangeRequest_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Sonali             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class  ZTS_GL_ChangeRequest_Test 
{  
     public static testMethod void updateZTS_GL_ChangeRequestTest(){
    
        List<ZTS_EU_Request__c> changereqlist = ZTS_DataUtilityTest.createChangeRequestRecord(4);
        insert changereqlist;
        
        for (ZTS_EU_Request__c ad: changereqlist ){
        
         //ad.ZTS_EU_Requested_Change__c = 'Test Requested'; field not pushed
        }
        System.debug('TestList' + changereqlist);
        update changereqlist;
    }
}