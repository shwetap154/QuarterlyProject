public class OnLoadController {

    public String Page {get; set;}
    public String OpenPageURL {get; set;}
    public Boolean check {get;set;}
    
    public OnLoadController()
    {
        String userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        if (userAgent.contains('iPhone')||userAgent.contains('iPad')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Access to SAP BO Reports via iPad/iPhone is not supported.  Please use the web browser (i.e. IE) on your computer to access this content.'));
                check=true;
            }
        else{     
            Page = '' ;
            OpenPageURL = SAP_BO_Reports__c.getValues('Summary').SAP_URL__c;
            }   

    }
    
    /*public void redirect()
    {
        if(Page == 'Summary'){
            OpenPageURL = SAP_BO_Reports__c.getValues('Summary').SAP_URL__c;
        }else if(Page == 'My_Performance'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Performance').SAP_URL__c;
        }else if(Page == 'My_Customers'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Customers').SAP_URL__c;
        }else if(Page == 'My_Activities'){
            OpenPageURL =SAP_BO_Reports__c.getValues('My_Activities').SAP_URL__c;
        }
    }*/

}