/**
	* File Name    :  USOnLoadControllerTest 
	* Description  :  Test class for USOnLoadController, This test class is introduced for Tableau Integration, used to check if the respective links are working and user is redirected to correct links when the respective buttons are clicked
	* Author       :  Cognizant Technology Solutions (Aritra Chakraborty)
	* Modification Log
	===================================================================================================
	* Ver.  Date        Author                 Modification
	---------------------------------------------------------------------------------------------------
	* 1.0   01/16/2018  Aritra Chakraborty     Created class
	* 1.1   04/20/2021  Chelsea Paice          Updated to add FAST report link test
    * 1.2   09/24/2021  Pranija Nagavelly      Updated to add FASTDX report link test
    * 1.3   05/15/2023  Yadagiri Avula         Updated to add ACP report link

**/

@IsTest(seeAlldata = false)
public class USOnLoadControllerTest {
     
    //This is used to setup a test data required to execute the TestMethods
    @testSetup 
    private static void initialize(){
        
        //Set values for the custom Settings
        List<SAP_BO_Reports__c> configData = new List<SAP_BO_Reports__c>();
        configdata.add(new SAP_BO_Reports__c(Name = 'Customer_360', SAP_URL__c = 'https://us-east-1.online.tableau.com/t/ztsus/views/Customer360_2/CustomerSearch?%20iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top' ));
        configdata.add(new SAP_BO_Reports__c(Name = 'My_Performance_New', SAP_URL__c = 'https://us-east-1.online.tableau.com/t/ztsus/views/MyPerformanceDashboard/Landing?iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top' ));
        configdata.add(new SAP_BO_Reports__c(Name = 'My_Customers_New', SAP_URL__c = 'https://us-east-1.online.tableau.com/t/ztsus/views/MyCustomersDashboard/Landing?iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top' ));      
        configdata.add(new SAP_BO_Reports__c(Name = 'My_Activities', SAP_URL__c = 'http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FjKu6lcmNwoAxC8AAACnsqpJAFBWrRCN' )); 
    	configdata.add(new SAP_BO_Reports__c(Name = 'RXDX_Dashboard', SAP_URL__c = 'https://test.rxdx.dashboard.com')); //Pooja
        configdata.add(new SAP_BO_Reports__c(Name = 'ACP', SAP_URL__c = 'https://acp.zoetis.com/')); //Pooja
        //Insert the values to the custom Settings
        insert configData;

        FAST_Report_Base_URL__c FASTsettings = FAST_Report_Base_URL__c.getOrgDefaults();
        FASTsettings.URL__c = 'http://test.test';
        FASTsettings.FASTDx_URL__c = 'http://test.test';
        upsert FASTsettings;
        
        
    }
    
    //Case 1: Checks when the page loads should test the user agent and display message or load the summary report
    public static TestMethod void getInitialTest(){
        
        //Set the current Page
        PageReference pageRef = Page.SAPBO_Reports;            
        Test.setCurrentPage(pageRef);
        
        //Set the user agent to iPad
        System.currentPageReference().getHeaders().put('User-Agent','iPad');
        
        //Initialized to call the constructor
        USOnLoadController objLoadCtrlr =  new USOnLoadController();
        //Gets all the messages and checks the message that will be displyed to the user
        ApexPages.Message[] pageMessages = ApexPages.getMessages(); 
        system.assertEquals('Access to SAP BO Reports via iPad/iPhone is not supported.  Please use the web browser (i.e. IE) on your computer to access this content.', pageMessages[0].getSummary());
        
        system.assertEquals(true, objLoadCtrlr.check);      
        
            
        //Set the user agent to empty for desktop 
        System.currentPageReference().getHeaders().put('User-Agent','');
                
        //Initialized to call the constructor
        USOnLoadController objLoadCntrlr =  new USOnLoadController();
            
        //checks for the Page Value
        system.assertEquals('', objLoadCntrlr.Page);
        
        //Checks the default dashboard URL (RXDX Dashboard) that will be loaded for Admin profile
        system.assertEquals('https://test.rxdx.dashboard.com', objLoadCntrlr.OpenPageURL); //Pooja
        
    }
    
    //Case2: This testmethod is used to check the correct dashboard is loaded when user clicks the respective buttons
    public static TestMethod void redirectTest(){
        
        //Set the current Page
        PageReference pageRef = Page.SAPBO_Reports;            
        Test.setCurrentPage(pageRef);
        
        //Set the user agent to empty for desktop 
        System.currentPageReference().getHeaders().put('User-Agent','');
        
        //Initialized to call the constructor
        USOnLoadController objLoadCtrlr =  new USOnLoadController();
        
        //When user clicks on Customer 360 button
        objLoadCtrlr.Page = 'Customer_360';
        objLoadCtrlr.redirect();
        //Check for the Customer 360 dashboard URL
        system.assertEquals('https://us-east-1.online.tableau.com/t/ztsus/views/Customer360_2/CustomerSearch?%20iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top', objLoadCtrlr.OpenPageURL);

        
        //When user clicks on My Performance button
        objLoadCtrlr.Page = 'My_Performance';
        objLoadCtrlr.redirect();
        //Check for the My Performance dashboard URL
        system.assertEquals('https://us-east-1.online.tableau.com/t/ztsus/views/MyPerformanceDashboard/Landing?iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top', objLoadCtrlr.OpenPageURL);

        
        //When user clicks on My Customers button
        objLoadCtrlr.Page = 'My_Customers';
        objLoadCtrlr.redirect();
        //Check for the My Customers dashboard URL
        system.assertEquals('https://us-east-1.online.tableau.com/t/ztsus/views/MyCustomersDashboard/Landing?iframeSizedToWindow=true&:embed=y&:showAppBanner=false&:display_count=no&:toolbar=top', objLoadCtrlr.OpenPageURL);

        //When user clicks on My Activities button
        objLoadCtrlr.Page = 'My_Activities';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FjKu6lcmNwoAxC8AAACnsqpJAFBWrRCN', objLoadCtrlr.OpenPageURL);
        
        //When user clicks on RXDX Dashboard button //Pooja
        objLoadCtrlr.Page = 'RXDX_Dashboard';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('https://test.rxdx.dashboard.com', objLoadCtrlr.OpenPageURL);

        //When user clicks on FAST button
        objLoadCtrlr.Page = 'FAST_Report';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('http://test.test', objLoadCtrlr.OpenPageURL);

        //When user clicks on FASTDX button
        objLoadCtrlr.Page = 'FAST_DX_Report';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('http://test.test', objLoadCtrlr.OpenPageURL);
        
     //When user clicks on FASTDX button
        objLoadCtrlr.Page = 'ACp';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('https://acp.zoetis.com/', objLoadCtrlr.OpenPageURL);
        
        
    }


}