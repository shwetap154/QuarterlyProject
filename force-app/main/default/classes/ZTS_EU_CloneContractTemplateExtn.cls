/* -----------------------------------------------------------------------------------------------------------------------
   Name:        ZTS_EU_CloneContractTemplateExtn.cls
   Description: Extension class for the VF Page: ZTS_EU_CloneContractTemplate.
                -- Creates the productContractTemplate Association record.
                    
   Date         Version Author              Summary of Changes 
   -----------  ------- -----------------   ------------------------------------------------------------------------------
   24-11-2014   1.0     CloudSense(Bimba)   Initial Version       
------------------------------------------------------------------------------------------------------------------------ */

public class ZTS_EU_CloneContractTemplateExtn{
   
    private ApexPages.StandardController controller{get;set;}
    private ZTS_EU_ContractTemplate__c ct{get;set;}
    private Product_Contract_Template_Association__c pcta{get;set;}
    public List<ZTS_EU_ContractTemplate__c> currentCTRecList{get;set;}
    public List<Product_Contract_Template_Association__c> matchPCTARecList {get;set;}
    public List<Product_Contract_Template_Association__c> clonedPCTAList{get;set;}
    public Id newCTRecId{get;set;}
    public Id baseCTId{get;set;}
    
    //Initialising the Controller
    public ZTS_EU_CloneContractTemplateExtn(ApexPages.StandardController controller){
        this.controller = controller;
        ct = (ZTS_EU_ContractTemplate__c)controller.getRecord();
        currentCTRecList = new List<ZTS_EU_ContractTemplate__c>();
        matchPCTARecList = new List<Product_Contract_Template_Association__c>();
        clonedPCTAList = new List<Product_Contract_Template_Association__c>();
        baseCTId = ApexPages.currentPage().getParameters().get('id');
        system.debug('baseCTId--->'+baseCTId);
        
    }
    
    /**********************************************************************************************************************
    * author: Bimba
    * Date: 24-NOV-2014
    * Param: none
    * Return: PageReference
    * Description: This is an action method being called from the page.This will clone the 
        Contract Template and the Product Contract Template Association record. 
    * Summary of Changes : 
    **********************************************************************************************************************/
    public PageReference clonePCTA(){
        
        //Copy the contract template field values
        ct = [Select Id,Name,ZTS_EU_Discount__c,ZTS_EU_Discount_Type__c,
                    ZTS_EU_End_Date__c,ZTS_EU_Start_Date__c,ZTS_EU_Fiscal_Year__c,
                    ZTS_EU_Status__c,ZTS_EU_Type__c 
                    FROM ZTS_EU_ContractTemplate__c
                    WHERE id = :baseCTId];
                    
        //Clone the Contract Template
        ZTS_EU_ContractTemplate__c newCT = ct.clone(false);
        insert newCT;
        
        newCTRecId = newCT.Id;
        system.debug('Controller--->newCTRecIdValue--->'+newCTRecId);
        
        Product_Contract_Template_Association__c clonedPCTA;
        //Fetch the PCTA and clone it
        matchPCTARecList = [SELECT Id,ZTS_EU_Contract_Template__c,ZTS_EU_Product_Hierarchy__c 
                        FROM Product_Contract_Template_Association__c
                        WHERE ZTS_EU_Contract_Template__c = :ct.Id]; 
        system.debug('PCTA of the CT in picture---->'+matchPCTARecList);                 
        for(Product_Contract_Template_Association__c pcta : matchPCTARecList){
            clonedPCTA = pcta.clone(false);     
            //clonedPCTA.ZTS_EU_Contract_Template__c = newCTRecId;
            clonedPCTA.ZTS_EU_Contract_Template__c = newCT.Id;
            clonedPCTAList.add(clonedPCTA);     
        }
        database.insert(clonedPCTAList,false);
        system.debug('clonedPCTAList--->'+clonedPCTAList);
        
        PageReference newPgRef = new PageReference('/'+newCT.Id+'/e?retURL=%2F'+newCT.Id+'&cancelURL=%2F'+ct.Id);
        return newPgRef;
    }
}