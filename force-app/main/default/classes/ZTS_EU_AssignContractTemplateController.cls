/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_AssignContractTemplateController
* Description   :  This is the controller of the vf page: ZTS_EU_AssignContractTemplate.                          

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4th-Feb-15   Shreyas             Created the class.
* 1.1	  2nd-Jan-20   Elton Barbosa       Updated the class.
* 1.2     29th-Sept-20	Aritra(Cognizant)  Updated the class.
********************************************************************************************************************************************/
public with sharing class ZTS_EU_AssignContractTemplateController{


    public string accId;
    public string accName;
    public ZTS_EU_ContractTemplate__c contractTemplateDetail {get; set;}
    public list<ZTS_EU_ContractTemplate__c> contractTemplateList;
    public list<SelectOption> contractTemplateSelectList {get; set;}
    public string selectedTemplateId {get; set;}
    public map<string, ZTS_EU_ContractTemplate__c> ctMap;
    public string templateFieldId;
    public string templateLookupFieldId;
    public string buFieldId;
    public string buLookupFieldId;
    public string typeId;
    public string discountTypeFieldId;
    public string discountFieldId;
    public string startDateFieldId;
    public string endDateFieldId;
    public string fiscalYearFieldId;
    public Map<string, List<Product_Contract_Template_Association__c>> productTemplateAssociationMap;
    public List<Product_Contract_Template_Association__c> productTemplateAssociationList {get; set;}
    public integer productTemplateAssociationListSize {get; set;}
    
    // Constructor
    public ZTS_EU_AssignContractTemplateController(){
    
        accId = ApexPages.currentPage().getParameters().get('accId');
        if(accId != null){
            accName = [Select Id, name from Account where Id =: accId AND ZTS_EU_Market__c != 'United States' limit 1].Name;
        }
        contractTemplateSelectList = new list<SelectOption>();
        selectedTemplateId = '';
        ctMap = new map<string, ZTS_EU_ContractTemplate__c>();
        productTemplateAssociationMap = new Map<string, List<Product_Contract_Template_Association__c>>();
        productTemplateAssociationList = new List<Product_Contract_Template_Association__c>();
        productTemplateAssociationListSize = 0;
        
        getAvailableContractTemplates();
        
        templateFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_TemplateName_Id').ZTS_EU_ID__c;
        templateLookupFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_Template_Id').ZTS_EU_ID__c;
        buFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_BUName_Id').ZTS_EU_ID__c;
        buLookupFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_BU_Id').ZTS_EU_ID__c;
        typeId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_Type_Id').ZTS_EU_ID__c;
        discountTypeFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_DiscountType_Id').ZTS_EU_ID__c;
        discountFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_Discount_Id').ZTS_EU_ID__c;
        endDateFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_EndDate_Id').ZTS_EU_ID__c;
        fiscalYearFieldId = ZTS_EU_Field_ID__c.getall().get('ZTS_EU_Contract_FiscalYear_Id').ZTS_EU_ID__c;
    }
    
    
    
    /*
    Name: getAvailableContractTemplates
    Purpose: to fetch the Available Contract Templates to assign
    Arguments: null
    Return type: null 
    */

    public void getAvailableContractTemplates(){
        
        contractTemplateList = new list<ZTS_EU_ContractTemplate__c>();
        List<string> templateIdList = new List<string>();
        
        contractTemplateList = [Select Id, Name, ZTS_EU_CTBusiness_Unit__c, ZTS_EU_CTBusiness_Unit__r.Name, 
                                ZTS_EU_Discount__c, ZTS_EU_Discount_Type__c, ZTS_EU_End_Date__c,
                                ZTS_EU_Short_Code__c,ZTS_EU_Fiscal_Year__c,
                                ZTS_EU_Start_Date__c, ZTS_EU_Status__c, ZTS_EU_Type__c
                                from ZTS_EU_ContractTemplate__c where ZTS_EU_Status__c = 'Active' Order By Name];
        
        for(ZTS_EU_ContractTemplate__c ct: contractTemplateList){
            templateIdList.add(ct.Id);
        }
                                
        List<Product_Contract_Template_Association__c> productTemplateAssociationListFetch = new List<Product_Contract_Template_Association__c>();                        
        productTemplateAssociationListFetch = [Select Id, Name, ZTS_EU_Contract_Template__c, ZTS_EU_Product_Hierarchy__c, ZTS_EU_Product_Hierarchy__r.Name 
                                               from Product_Contract_Template_Association__c
                                               where ZTS_EU_Contract_Template__c IN: templateIdList];
                                
        for(ZTS_EU_ContractTemplate__c ct: contractTemplateList){
        
            ctMap.put(ct.Id, ct);
            contractTemplateSelectList.add(new SelectOption(ct.Id,ct.Name));
            if(selectedTemplateId == ''){
                selectedTemplateId = ct.Id;
            }
        }
        
        productTemplateAssociationMap = new Map<string, List<Product_Contract_Template_Association__c>>();
        
        for(Product_Contract_Template_Association__c pa: productTemplateAssociationListFetch){
            
            if(productTemplateAssociationMap.containsKey(pa.ZTS_EU_Contract_Template__c)){
                productTemplateAssociationMap.get(pa.ZTS_EU_Contract_Template__c).add(pa);
            }
            else{
                productTemplateAssociationMap.put( pa.ZTS_EU_Contract_Template__c, new List<Product_Contract_Template_Association__c>{pa} );
            }
        }
        
        getSelectedTemplateDetails(); 
    }

    /*
    Name: getSelectedTemplateDetails
    Purpose: to get the details of selected template
    Arguments: null
    Return type: null 
    */

    public void getSelectedTemplateDetails(){
    
        contractTemplateDetail = new ZTS_EU_ContractTemplate__c();
        productTemplateAssociationList = new List<Product_Contract_Template_Association__c>();
        contractTemplateDetail = ctMap.get(selectedTemplateId);
        productTemplateAssociationList = productTemplateAssociationMap.get(selectedTemplateId);
        
        if(productTemplateAssociationList != null){
            productTemplateAssociationListSize = productTemplateAssociationList.size();
        }
        else{
            productTemplateAssociationListSize = 0;
        }
        
    }
    
    /*
    Name: assignContractTemplate
    Purpose: to assigned the selected contract template. 
    Arguments: null
    Return type: null 
    */

    public pagereference assignContractTemplate(){
    
        string startDateString = '';
        string endDateString = '';
        
        startDateString = contractTemplateDetail.ZTS_EU_Start_Date__c.format();
        endDateString = contractTemplateDetail.ZTS_EU_End_Date__c.format();
               
        string discountValue = string.valueOf(contractTemplateDetail.ZTS_EU_Discount__c);
        //string discountValueFinal = ''; -- commented by Aritra (SC-008072) on 29-Sep-2020
        
        string loc = userinfo.getLocale();
        Set<string> frenchLocales = new Set<string>();
        frenchLocales.add('fr_BE');
        frenchLocales.add('fr_CA');
        frenchLocales.add('fr_LU');
        frenchLocales.add('fr_FR');
        frenchLocales.add('fr_MC');
        frenchLocales.add('fr');
      // Code of decimal point conversion for French locale is moved to classic module URL Creation block below
      // -- commented by Aritra (SC-008072) on 29-Sep-2020
       /* if( frenchLocales.contains(loc) ){
            discountValueFinal = discountValue.replace('.',',');
        }
        else{
            discountValueFinal = discountValue;
        }*/
            
        string contractTemplateName = contractTemplateDetail.Name;
        string contractTemplateNameFinal = contractTemplateName;
        
        if(contractTemplateName.contains('&')){
            contractTemplateNameFinal = contractTemplateName.replace('&','%26');
        }
        
        string accNameFinal = accName;
        if(accName.contains('&')){
            accNameFinal = accName.replace('&','%26');
        }
        
        String url;
        
        // Check for the Salesforce theme whether it is classic or lightning and accordingly redirect
        if(UserInfo.getUiThemeDisplayed() == 'Theme4d'){
            url = '/lightning/o/Contract/new?defaultFieldValues=AccountId=' + accId;
            url = url + ',' + 'ZTS_EU_Related_Contract_Template__c' + '=' + contractTemplateDetail.Id;
            if(contractTemplateDetail.ZTS_EU_Discount_Type__c == 'Fixed Discount'){
                url = url + ',' + 'ZTS_EU_Discount__c' + '=' + discountValue;
       		}
            
            if(contractTemplateDetail.ZTS_EU_CTBusiness_Unit__c != null){
                url = url + ',' + 'ZTS_EU_BusinessUnit__c' + '=' + contractTemplateDetail.ZTS_EU_CTBusiness_Unit__c;
        	}
            
            url = url  + ',' + 'ZTS_EU_Type__c' + '=' + contractTemplateDetail.ZTS_EU_Type__c;
            url = url + ',' + 'ZTS_EU_Discount_Type__c' + '=' + contractTemplateDetail.ZTS_EU_Discount_Type__c;
            url = url + ',' + 'ZTS_EU_Fiscal_Year__c' + '=' + contractTemplateDetail.ZTS_EU_Fiscal_Year__c;
            url = url + ',' + 'ZTS_EU_End_Date__c' + '=' + date.parse(endDateString);
            url = url + ',' + 'StartDate' + '=' + date.parse(startDateString);
        }
        
        else{
            url = '/800/e?clone=1';
            url = url + '&ctrc7_lkid=' + accId;
            url = url + '&' + 'ctrc5' + '=' + startDateString;       
            if(contractTemplateDetail.ZTS_EU_Discount_Type__c == 'Fixed Discount'){
                //Moved the decimal conversion logic inside classic module block, because decimal conversion for French locale
                // is not being supported in Lightning. by Aritra on 29-Sep-2020 as part of (SC-008072)
                if( frenchLocales.contains(loc) ){
                url = url + '&' + discountFieldId + '=' + discountValue.replace('.',',');
                }
                else
                {
                   url = url + '&' + discountFieldId + '=' + discountValue; 
                }
            }
    
            url = url + '&' + templateFieldId + '=' + contractTemplateNameFinal;
            url = url + '&' + templateLookupFieldId + '=' + contractTemplateDetail.Id;
            if(contractTemplateDetail.ZTS_EU_CTBusiness_Unit__c != null){
                url = url + '&' + buFieldId + '=' + contractTemplateDetail.ZTS_EU_CTBusiness_Unit__r.Name;
                url = url + '&' + buLookupFieldId + '=' + contractTemplateDetail.ZTS_EU_CTBusiness_Unit__c;
            }
            
            url = url  + '&' + typeId + '=' + contractTemplateDetail.ZTS_EU_Type__c;
            url = url + '&' + discountTypeFieldId + '=' + contractTemplateDetail.ZTS_EU_Discount_Type__c;
            url = url + '&ctrc7=' + accNameFinal;
            url = url + '&' + endDateFieldId + '=' + endDateString;
            url = url + '&' + fiscalYearFieldId + '=' + contractTemplateDetail.ZTS_EU_Fiscal_Year__c;
        }
		System.debug('url>>>>>'+url);
        pagereference pg = new pagereference(url);
        pg.setRedirect(true);
        return pg;  
    
    }

}