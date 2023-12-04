/*******************************************************************************************************************************************
* File Name     :  ZTS_GL_AddSampleDrop_ControllerTest
* Description   :  Test class for ZTS_GL_AddSampleDrop_Controller class
* @author       :  Deloitte Consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/2          Akanksha          Created the Class.

***************************************************************************************************************/
@isTest
public with sharing class ZTS_GL_AddSampleDrop_ControllerTest {
    
    public static testMethod void validate_ZTS_GL_AddSampleDrop_Controller(){
    try{
        
        Test.startTest();
        List<Account> accList = ZTS_DataUtilityTest.createAccountRecord(1);
        insert accList ;
        ZTS_US_Sample__c sample= new ZTS_US_Sample__c(ZTS_US_Item_Code__c='ABC1233',ZTS_US_Lot__c='LOT1',ZTS_US_Start_Quantity__c=15);
        insert sample;
        List<ZTS_US_Sample__c> sampleList=new List <ZTS_US_Sample__c>();
        sampleList.add(sample);
        List<ZTS_US_Sample__c> newsampleList=new List <ZTS_US_Sample__c>();
        ZTS_US_Sample_Drop__c samdrop= new ZTS_US_Sample_Drop__c(ZTS_US_Sample__c=sampleList[0].Id,ZTS_EU_Quantity__c=3);
        insert samdrop;
        List<ZTS_US_Sample_Drop__c> newsamdropList=new List <ZTS_US_Sample_Drop__c>();
        newsamdropList.add(samdrop);
        PageReference pageRef = Page.ZTS_GL_AddSampleDrop;
        Test.setCurrentPage(pageRef);
        List<Call__c> callObj= new List<Call__c>();
        callObj=ZTS_DataUtilityTest.createCallRecord(1);
        insert callObj;
        //List<Call__c> callObj = [SELECT Id FROM Call__c];
        system.debug('************callObj************'+callObj);
        if(callObj.size() > 0)
            ApexPages.currentPage().getParameters().put('callId',callObj[0].Id);  
            ApexPages.currentPage().getParameters().put('searchString','TestSample');  
            ApexPages.StandardSetController setSDropCont = new ApexPages.StandardSetController(sampleList); 
        ZTS_GL_AddSampleDrop_Controller addsamplcon= new ZTS_GL_AddSampleDrop_Controller();
        newsampleList=addsamplcon.getAssoSamples();
        addsamplcon.searchString='TestSample';
        addsamplcon.addSampleId=sampleList[0].Id;
        addsamplcon.addedSample();
        addsamplcon.sampleDropId=newsamdropList[0].Id;
        addsamplcon.addSampleDrop();
        addsamplcon.removeSamples();
        addsamplcon.querySampleDrop();
        
      }catch(Exception e){}  
      }
}