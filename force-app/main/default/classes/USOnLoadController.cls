/**
* File Name     :  USOnLoadController
* description  :  Controller extension for SAPBO_Reports.vfp
* author       :  ?
* Modification Log
===================================================================================================
* Ver.  Date        Author                 Modification
---------------------------------------------------------------------------------------------------
* 1.0   ?           ?                      Created controller
* 1.1   04/20/2021  Chelsea Paice          Updated to add FAST report link
* 1.2   09/24/2021  Pranija Nagavelly      Updated to add FASTDX report link
* 1.3   05/15/2023  Yadagiri Avula         Updated to add ACP report link

**/

public class USOnLoadController {
    public String Page {get; set;}
    public String OpenPageURL {get; set;}
    public Boolean check {get;set;}
    
    public USOnLoadController()
    {
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        if (userAgent.contains('iPhone')||userAgent.contains('iPad')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Access to SAP BO Reports via iPad/iPhone is not supported.  Please use the web browser (i.e. IE) on your computer to access this content.'));
            check=true;
        }
        else{    
            Page = '' ;
            List<User> userList = [SELECT Id FROM User WHERE Profile.Name IN ('US Small Animal Rep','US Small Animal Manager','US Inside Sales Rep','US Inside Sales Manager','US Home Office Profile','US Business Administrator','US Contract Admin','System Administrator') AND Id =: UserInfo.getUserId()];
            String DashboardName = 'My_Performance_New';
            if(userList.size() > 0) {
                DashboardName = 'RXDX_Dashboard';
            }
            OpenPageURL = SAP_BO_Reports__c.getValues(DashboardName).SAP_URL__c;
        }
    }
    
    public void redirect()
    {
        if(Page == 'Customer_360'){
            OpenPageURL = SAP_BO_Reports__c.getValues('Customer_360').SAP_URL__c;
        }else if(Page == 'My_Performance'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Performance_New').SAP_URL__c;
        }else if(Page == 'My_Customers'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Customers_New').SAP_URL__c;
        }else if(Page == 'My_Activities'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Activities').SAP_URL__c;
        }else if(Page == 'RXDX_Dashboard'){                                             //Pooja added for SC-009735   
            OpenPageURL =SAP_BO_Reports__c.getValues('RXDX_Dashboard').SAP_URL__c;
        }else if(Page == 'FAST_Report'){
            FAST_Report_Base_URL__c baseURL = FAST_Report_Base_URL__c.getOrgDefaults();
            OpenPageURL = baseURL.URL__c;
        }else if(Page == 'FAST_DX_Report'){
            FAST_Report_Base_URL__c baseDXURL = FAST_Report_Base_URL__c.getOrgDefaults();
            OpenPageURL = baseDXURL.FASTDx_URL__c;
        }else if(Page == 'ACP'){
            OpenPageURL =SAP_BO_Reports__c.getValues('ACP').SAP_URL__c;
        }
    }
}