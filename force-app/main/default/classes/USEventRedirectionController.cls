/*************************************************************************************************************************
  Class Name     : USEventRedirectionController
  Description    : This is a controller class for Event Redirection page. Includes logic to redirect new event page based on recordtype
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/16/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/16/2014              Created

***************************************************************************************************************************/
public with sharing class USEventRedirectionController {

    // controller variable
    string recordTypeName;
    string recordId;
    Event eventRecord;
     
    // Hardcoded Strings
    public static final string STARTDATE_PARAM = 'evt4';
    public static final string STARTTIME_PARAM = 'evt13';
    
    static final string RETURL_STR = 'retURL';
    static final string RECORDTYPE_STR = 'RecordType';
    static final string EVENT_STR = 'Event';
    static final string EVENT_RT_SALESCALL_STR = 'Sales Call';
    static final string SAVE_NEW_PARAMETER_STR = '&save_new=1';
    static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    static final string OVERRIDE_PARAMETER_STR = '&sfdc.override=1';
    
     
    // public constructor
    public USEventRedirectionController(ApexPages.StandardController controller){
        string recordTypeId = '';
        
        recordId = controller.getId();
        eventRecord = (Event)controller.getRecord();
        
        if(ApexPages.currentPage().getParameters().containskey(RECORDTYPE_STR)){
            recordTypeId = ApexPages.currentPage().getParameters().get(RECORDTYPE_STR);
        }
        else{ 
            recordTypeId = '';
        }
        
        if(recordTypeId!=null && recordTypeId!=''){
            recordTypeName = UtilityService.getRecordTypeName(EVENT_STR, recordTypeId);
        }
    }
    
    /*
     * Method to return landing page based on recordtype selected for event
     * @param none
     * @return pagereference - to final landing page 
    */
    public PageReference newRedirect(){
        
        PageReference redirectedPage    = null;
        String url                      = ApexPages.currentPage().getUrl();
        map<string,string> parameters   = ApexPages.currentPage().getParameters();
        string eventPrefix              = Schema.SObjectType.Event.getkeyprefix();
        string retURL                   = eventPrefix;
        
        // get return URL of current page 
        if(parameters.containskey(RETURL_STR)){
            retURL = parameters.get(RETURL_STR);
        }
        
        // check recordtype name 
        // set sales call VF page if selected record type is Sales Call otherwise set standard event layout
        if(recordTypeName.equalsIgnoreCase(EVENT_RT_SALESCALL_STR)){
            redirectedPage = Page.SalesCall;
            redirectedPage.getParameters().put(RETURL_STR,retURL);
            if(parameters.containsKey(STARTDATE_PARAM))
                redirectedPage.getParameters().put(STARTDATE_PARAM,parameters.get(STARTDATE_PARAM));
            if(parameters.containsKey(STARTTIME_PARAM))
                redirectedPage.getParameters().put(STARTTIME_PARAM,parameters.get(STARTTIME_PARAM));
            
        }
        
        else{
            url = '/' + eventPrefix + '/e?' + url.split('\\?')[1];
            url = url.replace(SAVE_NEW_PARAMETER_STR, '');
            url = url.replace(OVERRIDE_PARAMETER_STR, '');
            url = url + '&' +NOOVERRIDE_PARAMETER_STR;
            redirectedPage = new PageReference(url);
        }
        
        // set redirect attribute to true 
        redirectedPage.setRedirect(true);
        return redirectedPage;
    }
    
    /*
     * Method to return landing page based on recordtype selected for event
     * @param none
     * @return pagereference - to final landing page 
    */
    public PageReference viewRedirect(){
    
        PageReference redirectedPage    = null;
        string eventPrefix              = Schema.SObjectType.Event.getkeyprefix();
        string retURL                   = eventPrefix;
        String url;
        
        // get return URL of current page 
        if(ApexPages.currentPage().getParameters().containskey(RETURL_STR)){
            retURL = ApexPages.currentPage().getParameters().get(RETURL_STR);
        }
        
        Event e;
        
        for (Event event : [SELECT  CallRecordId__c,recordtype.Name FROM Event WHERE ID = :recordId AND ZTS_EU_Market__c = 'United States'])
            e = event;

        if (e == null)
        {
            PageReference pageRef = new PageReference('/apex/EventViewRedirection?Id=' + recordId);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            eventRecord = e;
        }
        recordTypeName = eventRecord.recordtype.Name;
        system.debug('***********recordTypeName US***********'+recordTypeName);

        // check recordtype name 
        // set sales call VF page if selected record type is Sales Call otherwise set standard event layout
        if(recordTypeName.equalsIgnoreCase(EVENT_RT_SALESCALL_STR)){
            redirectedPage = Page.ViewSalesCall;
            redirectedPage.getParameters().put(RETURL_STR,retURL);
           redirectedPage.getParameters().put('id',eventRecord.CallRecordId__c);
        }
        
        else{
            url = '/' + recordId + '?'; 
            url = url + NOOVERRIDE_PARAMETER_STR;
            redirectedPage = new PageReference(url);
        }
        // set redirect attribute to true 
        redirectedPage.setRedirect(true);
        return redirectedPage;
    }   
}