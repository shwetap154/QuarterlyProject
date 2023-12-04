/*************************************************************************************
* Name          :    ZTS_EU_MyLastCallDateController .
* Description   :    Controller for Dispalyinglast call date for user on inline VF on contact.
* Author        :    Ninad
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
02/24/2014       Ninad                Created

11/18/2021       Chanbasha NBSK       Updated SOQL  query to filter only Submitted & Completed calls

**************************************************************************************/
public class ZTS_EU_MyLastCallDateController {
    
    //Variables declared to hold ids and date fields
    public String id;
    public Date myLastCallDate = null;
    public String stringMyLastCallDate{get;set;}
    public String stringLastCallDate {get;set;}
    public List<Attendee__C> listCallId = new List<Attendee__C>(); 
    public list<id> listId = new List<id>();
    //public contact oCon{get; set;} - This line is not used anywhere hence commenting. Modified by Chanbasha on 01/25.
    public Date lastcallDate{get; set;}    
    public ZTS_EU_MyLastCallDateController(ApexPages.StandardController controller) {
    
        //Fetching id of contact record opened.
        if(apexpages.currentpage().getparameters().containskey('id')){
        
            id = apexpages.currentpage().getparameters().get('id');
            //Fetching all Call ids related to all attendee of Contact record opened.
            //Updated SOQL Query to filter only Submitted & Completed Calls - NoorbashaSheik Chanbasha - 11/18/2021 - [SC-008964]
            List <AggregateResult> listCallId = [SELECT MAX(ZTS_EU_call__r.ZTS_EU_Start_Date_Time__c) maxDate from Attendee__C WHERE ZTS_EU_Contact__r.id = :id AND (ZTS_EU_call__r.ZTS_EU_Status__c= 'Submitted' OR ZTS_EU_call__r.ZTS_EU_Status__c='Completed') AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            for(AggregateResult oAtt: listCallID){
       //       listId.add(oAtt.ZTS_EU_call__r.id);
              LastcallDate = Date.valueof(oAtt.get('maxDate'));
              stringLastCallDate =(Date.valueof(oAtt.get('maxDate')))!= null?Date.valueof(oAtt.get('maxDate')).format():''; 
            }

        }

    }
    public Date getMyLastCallDate() {

        
        //fetching maximum of start date for all calls which are related to contac opened.
        // And contaning logged in User id as one of the attendee of the calls.
        //Updated SOQL Query to filter only Submitted & Completed Calls - NoorbashaSheik Chanbasha - 01/19/2021 - [SC-008964]
        List<AggregateResult> results = [SELECT MAX(ZTS_EU_Call__r.ZTS_EU_start_Date_time__C) maxDate FROM Attendee__C 
                                                WHERE ZTS_EU_call__r.createdById = :userInfo.getUserid()
                                                 AND ZTS_EU_Contact__r.id = :id AND ZTS_EU_Contact__r.id = :id AND (ZTS_EU_call__r.ZTS_EU_Status__c= 'Submitted' OR ZTS_EU_call__r.ZTS_EU_Status__c='Completed')
                                                 AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        for(AggregateResult ar: results){
        
            myLastCallDate = Date.valueof(ar.get('maxDate'));
            stringMyLastCallDate = (Date.valueof(ar.get('maxDate')))!= null?Date.valueof(ar.get('maxDate')).format():'';
        }
        return myLastCallDate;
   }
}