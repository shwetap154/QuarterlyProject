//*****************************************
//Developed By: Cognizant Technology Solutions (Abir Bhattacharya)
//Created Date: 11/09/2016
//Purpose: This test class is used to check if the respective links are 
//Change log: 
//*****************************************

@IsTest(seeAlldata = false)
private class OnLoadControllerTest{
    
    
    //This is used to setup a test data required to execute the TestMethods
    @testSetup 
    private static void initialize(){
        
        //Set values for the custom Settings
        List<SAP_BO_Reports__c> configData = new List<SAP_BO_Reports__c>();
        configdata.add(new SAP_BO_Reports__c(Name = 'Summary', SAP_URL__c = 'http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FsJ9BljiSgcAkDAAAABXYq5JAFBWrRCN' ));
        //configdata.add(new SAP_BO_Reports__c(Name = 'My_Performance', SAP_URL__c = 'http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FsMxAVhpFgMAuSkAAAA3Qq5JAFBWrRCN' ));
        //configdata.add(new SAP_BO_Reports__c(Name = 'My_Customers', SAP_URL__c = 'http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=Fv14BliUgAYAkDAAAACnsKxJAFBWrRCN' ));      
        //configdata.add(new SAP_BO_Reports__c(Name = 'My_Activities', SAP_URL__c = 'http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FjKu6lcmNwoAxC8AAACnsqpJAFBWrRCN' )); 
    
        //Insert the values to the custom Settings
        insert configData;
    }
    
    //Case 1: Checks when the page loads should test the user agent and display message or load the summary report
    public static TestMethod void getInitialTest(){
        
        //Set the current Page
        PageReference pageRef = Page.SAPBO_Reports;            
        Test.setCurrentPage(pageRef);
        
        //Set the user agent to iPad
        System.currentPageReference().getHeaders().put('User-Agent','iPad');
        
        //Initialized to call the constructor
        OnLoadController objLoadCtrlr =  new OnLoadController();
        //Gets all the messages and checks the message that will be displyed to the user
        ApexPages.Message[] pageMessages = ApexPages.getMessages(); 
        system.assertEquals('Access to SAP BO Reports via iPad/iPhone is not supported.  Please use the web browser (i.e. IE) on your computer to access this content.', pageMessages[0].getSummary());
        
        system.assertEquals(true, objLoadCtrlr.check);      
        
            
        //Set the user agent to empty for desktop 
        System.currentPageReference().getHeaders().put('User-Agent','');
                
        //Initialized to call the constructor
        OnLoadController objLoadCntrlr =  new OnLoadController();
            
        //checks for the Page Value
        system.assertEquals('', objLoadCntrlr.Page);
        
        //Checks the default dashboard URL that will be loaded
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FsJ9BljiSgcAkDAAAABXYq5JAFBWrRCN', objLoadCntrlr.OpenPageURL);
        
    }
    
    //Case2: This testmethod is used to check the correct dashboard is loaded when user clicks the respective buttons
    /*public static TestMethod void redirectTest(){
        
        //Set the current Page
        PageReference pageRef = Page.SAPBO_Reports;            
        Test.setCurrentPage(pageRef);
        
        //Set the user agent to empty for desktop 
        System.currentPageReference().getHeaders().put('User-Agent','');
        
        //Initialized to call the constructor
        OnLoadController objLoadCtrlr =  new OnLoadController();
        
        //When user clicks on Summary button
        objLoadCtrlr.Page = 'Summary';
        objLoadCtrlr.redirect();
        //Check for the Summary dashboard URL
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FsJ9BljiSgcAkDAAAABXYq5JAFBWrRCN', objLoadCtrlr.OpenPageURL);

        
        //When user clicks on My Performance button
        objLoadCtrlr.Page = 'My_Performance';
        objLoadCtrlr.redirect();
        //Check for the My Performance dashboard URL
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FsMxAVhpFgMAuSkAAAA3Qq5JAFBWrRCN', objLoadCtrlr.OpenPageURL);

        
        //When user clicks on My Customers button
        objLoadCtrlr.Page = 'My_Customers';
        objLoadCtrlr.redirect();
        //Check for the My Customers dashboard URL
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=Fv14BliUgAYAkDAAAACnsKxJAFBWrRCN', objLoadCtrlr.OpenPageURL);

        //When user clicks on My Activities button
        objLoadCtrlr.Page = 'My_Activities';
        objLoadCtrlr.redirect();
        //Check for the My Activities dashboard URL
        system.assertEquals('http://bi1lr111:8080/BOE/OpenDocument/opendoc/openDocument.jsp?sIDType=CUID&iDocID=FjKu6lcmNwoAxC8AAACnsqpJAFBWrRCN', objLoadCtrlr.OpenPageURL);

        
        
    }*/
}