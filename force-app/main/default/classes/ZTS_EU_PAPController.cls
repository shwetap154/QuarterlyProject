/*******************************************************************************************************************************************
* File Name     :  ZTS_EU_PAPController
* Description   :  This is the controller class for the pages: ZTS_EU_NewPAP,ZTS_EU_ProductBarrierLookupOnPAP and ZTS_EU_CompetitorProductLookupOnPAP

* @author       :   CloudSense (Shreyas)
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4th-May-15   Shreyas             Created the class.
********************************************************************************************************************************************/

public class ZTS_EU_PAPController{

    public ZTS_EU_Product_Adoption_Profile__c papRecord {get; set;}
    public string mode {get; set;}
    public boolean showName {get; set;}
    public string papId;
    public string papName {get; set;}
    public string brandIndicationId {get; set;}
    public List<ZTS_EU_Product_Barrier__c> pbList {get; set;}
    public List<Competitor_and_BI_Association__c> cpList {get; set;}
    public string fieldName;
    public string cloneParam;
    public string parentId;
    public string contactId;
    public contact conRecord {get; set;}
    public boolean showContactAddressInfo {get; set;}
    
    public ZTS_EU_PAPController(){
    
        brandIndicationId = ApexPages.currentPage().getParameters().get('biId');
        fieldName = ApexPages.currentPage().getParameters().get('field');
        getDetails();
    }
    
    
    public ZTS_EU_PAPController(apexpages.standardcontroller std){
    
        mode = ApexPages.currentPage().getParameters().get('mode');
        cloneParam = ApexPages.currentPage().getParameters().get('clone');
        papId = ApexPages.currentPage().getParameters().get('Id');
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        contactId = ApexPages.currentPage().getParameters().get('contactId');
        showContactAddressInfo = false;
        
        if(papId != null){
            papRecord = [Select Name, ZTS_EU_Contact__c, ZTS_EU_Contact_Primary_Account__c, ZTS_EU_Brand_Indication__c, ZTS_EU_Product_Barrier__c, 
                          ZTS_EU_Competitor_Product__c, ZTS_EU_Usage__c 
                          from ZTS_EU_Product_Adoption_Profile__c where Id =: papId];
            papName = papRecord.Name;
            showName = true; 
                        
        }
        else if(papId == null && mode == 'new'){
            papRecord = new ZTS_EU_Product_Adoption_Profile__c();
            showName = false;
            if(contactId != null){
                showContactAddressInfo = true;
                conRecord = new Contact();
                conRecord = [Select Id, Name, accountId from Contact where Id =: contactId AND ZTS_EU_Market__c != 'United States'];
                if(conRecord != null){
                    papRecord.ZTS_EU_Contact__c = conRecord.Id;
                    papRecord.ZTS_EU_Contact_Primary_Account__c = conRecord.accountId;
                }
            }
            
        }
        
        ZTS_EU_Product_Adoption_Profile__c papToClone = new ZTS_EU_Product_Adoption_Profile__c();
        if(cloneParam == '1'){
            papToClone = new ZTS_EU_Product_Adoption_Profile__c();
            papToClone = [Select Name, ZTS_EU_Contact__c, ZTS_EU_Contact_Primary_Account__c, ZTS_EU_Brand_Indication__c, ZTS_EU_Product_Barrier__c, 
                          ZTS_EU_Competitor_Product__c, ZTS_EU_Usage__c 
                          from ZTS_EU_Product_Adoption_Profile__c where Id =: parentId];
            
            papRecord = new ZTS_EU_Product_Adoption_Profile__c();
            papRecord.ZTS_EU_Contact__c = papToClone.ZTS_EU_Contact__c;
            papRecord.ZTS_EU_Contact_Primary_Account__c = papToClone.ZTS_EU_Contact_Primary_Account__c;
            papRecord.ZTS_EU_Brand_Indication__c = papToClone.ZTS_EU_Brand_Indication__c ;
            papRecord.ZTS_EU_Product_Barrier__c = papToClone.ZTS_EU_Product_Barrier__c;
            papRecord.ZTS_EU_Competitor_Product__c= papToClone.ZTS_EU_Competitor_Product__c;
            papRecord.ZTS_EU_Usage__c  = papToClone.ZTS_EU_Usage__c;
        }
        
    }
    
    /*
        Name: editPAP
        Purpose: to edit the PAP record  
        Argument: none
        Return type: none
    */
    public pagereference editPAP(){
    
        string papRecordId = papId;
        pagereference pg = new pagereference('/apex/ZTS_EU_PAP?mode=edit&Id=' + papRecordId);
        pg.setRedirect(true);
        return pg; 
    
    }
    
    /*
        Name: savePAP
        Purpose: to save the PAP record  
        Argument: none
        Return type: none
    */
    public pagereference savePAP(){
    
        try{
            if(papId == null){
                insert papRecord;
            }
            else{
                update papRecord;
            }
            papId = papRecord.Id;
            string papRecordId = papId;
            string url = '';
            pagereference pg = new pagereference('/'+papId);
            pg.setRedirect(true);
            return pg; 
        }
        
        catch(exception e){
            string strErrorMessage = e.getMessage();
            if(strErrorMessage.contains('DUPLICATE_VALUE,')){
                strErrorMessage = System.Label.ZTS_EU_DuplicatePAP;
            }
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,strErrorMessage); 
            ApexPages.addMessage(msg);
            return null;
        }
    
    }
    
    /*
        Name: getDetails
        Purpose: to fetch the details of Product Barrier and Competitor product related to Brand indication. 
        Argument: none
        Return type: none
    */
    public void getDetails(){
    
        pbList = new List<ZTS_EU_Product_Barrier__c>();
        cpList = new List<Competitor_and_BI_Association__c>();
        
        if(fieldName == 'field_pb'){
            pbList = [Select Id, Name, ZTS_EU_Brand_Indication__c from ZTS_EU_Product_Barrier__c where ZTS_EU_Brand_Indication__c =: brandIndicationId ];
        }
        if(fieldName == 'field_cp'){
            cpList = [Select Id, Name, ZTS_EU_Brand_Indication__c, ZTS_EU_Competitor_Product__c, ZTS_EU_Competitor_Product__r.Name 
                       from Competitor_and_BI_Association__c where ZTS_EU_Brand_Indication__c =: brandIndicationId ];
        }
        
    }
    
    /*
        Name: redirectPAPrecord
        Purpose: to redirect the PAP record to new PAP page. 
        Argument: none
        Return type: none
    */
    public pagereference redirectToNewPAPrecord(){
    
        string url = '';
        url = '/apex/ZTS_EU_PAP?mode=new';
        pagereference pg = new pagereference(url);
        pg.setRedirect(true);
        return pg; 
        
    }
    
    /*
        Name: redirectToEditPAPrecord
        Purpose: to redirect the PAP record to edit PAP page. 
        Argument: none
        Return type: none
    */
    public pagereference redirectToEditPAPrecord(){
    
        string url = '';
        url = '/apex/ZTS_EU_PAP?mode=edit&Id=' + papId;
        pagereference pg = new pagereference(url);
        pg.setRedirect(true);
        return pg; 
        
    }

    /**
     * @description Returns the user to the lightning home page. Used to override the cancel behavior from the Visualforce behavior.
     * @returns PageReference to the Lightning Home Page.
     */
    public PageReference lightningCancel() {
        PageReference pg = new pagereference('/lightning/page/home');
        pg.setRedirect(true);
        return pg; 
    }
}