/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_Mass_Add_Account_Ext
 * Description      : The class acts as an extension for the mass add account page
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 5th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/06/2014          Created 
 * Chelsea Paice            08/31/2022          Updated to filter out inactive accounts, and clean up old commments/spacing
*****************************************************************************************************************************************/
public with sharing class ZTS_US_Mass_Add_Account_Ext 
{
   public ZTS_Events__c currentEventsRecord    {get;set;}
    public String eventId                       {get;set;}
    public String isError                       {get;set;}
    public String accountPrefix                 {get;set;}
    public Id AccountId;
    public String myaccountname                 {get;set;}
    public list<account> acc                    {get;set;}
    public list<wrapperlist> mywrapperlist      {get;set;}
    public String source                        {get;set;}
    public ZTS_US_Event_Account__c eventAcc     {get;set;}
    public list<Account> selectedlist           {get;set;}
    set<Id> dataholdingid = new set<id>();
  
    public ZTS_US_Mass_Add_Account_Ext(ApexPages.StandardController controller)
    {
        accountPrefix = '';
        source = '';
        
        currentEventsRecord = (ZTS_Events__c)controller.getRecord();
        System.debug('currentEventsRecord ::: '+currentEventsRecord);
        if(ApexPages.currentPage().getParameters().containsKey('eventId')){
            eventId = ApexPages.currentPage().getParameters().get('eventId');
            currentEventsRecord = [select Name, ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
        }
        if(ApexPages.currentPage().getParameters().containsKey('isError')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The selected Account(s) have already been added to the Event'));
            accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix() + '';
        }
        if(ApexPages.currentPage().getParameters().containsKey('Id')){
            eventId = ApexPages.currentPage().getParameters().get('Id');
            currentEventsRecord = [select Name, ZTS_US_Name__c from ZTS_Events__c where Id=: eventId AND ZTS_EU_Market__c != 'United States'];
        }
        System.debug('currentEventsRecord ::: '+currentEventsRecord);
        eventAcc = new ZTS_US_Event_Account__c();
        
    }   
   
   public class wrapperlist{
        public account acc1{get;set;}
        public boolean selected{get;set;}
        
        public wrapperlist(account a){
            
        acc1 = a;
        selected = false;
        } 
    }
    
    public void process(){
        selectedlist = new list<account>();
        dataholdingid = new set<Id>();
        try {
            for(wrapperlist my:mywrapperlist){
                If(my.selected == true) { 
                    selectedlist.add(my.acc1)  ;
                    dataholdingid.add(my.acc1.id);
                }
            }
            system.debug('selectlist'+selectedlist.size());
        }
        
        catch(exception e){
            system.debug('Please select a record');
        }
        List<ZTS_US_Event_Account__c> eventAcc = new list<ZTS_US_Event_Account__c>();
        if (eventId == null) {
            String eventId = ApexPages.currentPage().getParameters().get('id');
        }
        system.debug('EventId...'+eventId);
        if(eventId != null && eventId != ''){
            currentEventsRecord = [select Name,ZTS_US_Name__c from ZTS_Events__c where Id=: eventId];
            system.debug('currentEventsRecord...'+currentEventsRecord);
        }
        
        For (Integer i=0;i<selectedlist.size();i++){
            ZTS_US_Event_Account__c T1 = new ZTS_US_Event_Account__c();
            T1.ZTS_US_Event_Account__c =selectedlist[i].id;
            T1.zts_us_events__c =eventId;
            eventAcc.add(T1);
        }
            
        SYSTEM.DEBUG('DATAHOLDING' +dataholdingid.size());
        List<ZTS_US_Event_Account__c> listExistingEvntAcc = [select ZTS_US_Event_Account__c, ZTS_US_Events__c from ZTS_US_Event_Account__c 
                                                                            where ZTS_US_Event_Account__c IN: dataholdingid and ZTS_US_Events__c=: eventId];
        if(listExistingEvntAcc != null && listExistingEvntAcc.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The selected Account(s) have already been added to the Event'));
        }

        try{
            System.debug('Please select a record');
            IF (listExistingEvntAcc.size()==0)
                insert eventacc;
            If (eventacc.size()==0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please select a record'));
            IF (listExistingEvntAcc.size()==0 && eventacc.size()>0)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Records added successfully'));
        }
        catch(DMLEXCEPTION e1){
            system.debug('Please send record to process'+e1.getMessage());
        }
        catch(exception e)
        {
            System.debug('Please select a record'+ e.getMessage());
        }
    }
    
    public void search(){ 
        mywrapperlist = new list<wrapperlist>();
        string searchquery='Select name,id,type,ZTS_EU_Main_Phone__c,ZTS_EU_market__C,ZTS_EU_Address_Line_1__c,ZTS_EU_City__c,ZTS_EU_Zip_Postal_Code__c from account where ZTS_EU_Account_Status__c != \'Inactive\' AND name like \'%'+myaccountname+'%\' AND ZTS_EU_Market__c != \'United States\' order by name Limit 200';
        system.debug('searchquery'+searchquery);
        acc=Database.query(searchquery);
        system.debug('acc'+acc);
        For (Account a_search :acc){
            mywrapperlist.add(new wrapperlist(a_search));
        }
        
    }
    
    public void clear(){ 
        acc.clear(); 
    } 
    
}