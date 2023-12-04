/****************************************************************************************************************************************** 
* Class Name   	: ZTS_US_Mass_Add_Account_New_Ext
* Description  	: The class is a new class which will be used for adding Account to Events              
* Created By   	: Cognizant
* Created Date 	: April 04th, 2023
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Rachana Prabhu           4/4/2023          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_US_Mass_Add_Account_New_Ext{
    public boolean buttontf 					{get;set;}
    public String searchKey                     {get;set;}
    public List<ID> listAccID 					{get;set;}
    public List<Id> territoryId					{get;set;}
    public Boolean masterChechBoxVal			{get;set;}
    public Boolean checked						{get;set;}
    public Map<Id,Boolean> selected				{get;set;}
    public Integer offSetSize					{get;set;}
    public Integer QueryLimit					{get;set;}
    public Integer countTotalRecords			{get;set;}
    public String MessageOnAddAcc				{get;set;}
    public String SeverityOnResult				{get;set;}
    public String SuccssErrorMessageClass		{get;set;}
    
    public Boolean OldValMasterChechBoxVal = false;
    
    
    public String eventId = ApexPages.currentPage().getParameters().get('Id')!=null ? ApexPages.currentPage().getParameters().get('Id') : null;
    
    public ZTS_US_Mass_Add_Account_New_Ext(){
        territoryId = new List<Id>();
        offSetSize = 0;
        QueryLimit = 20;
        countTotalRecords= 0;
        masterChechBoxVal = false;
        selected = new Map<Id,Boolean>();
        MessageOnAddAcc = 'Select Account(s) To Add To The Event...';
        SeverityOnResult = 'INFO';
        SuccssErrorMessageClass = 'slds-hide';
        buttontf = true;
        checked = false;
        
        List<UserTerritory2Association> userTerritories = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()];
        for (UserTerritory2Association userTerritory : userTerritories) {
            territoryId.add(userTerritory.Territory2Id);
        }
        system.debug('Sayan territoryId size = '+territoryId.size());
        
        listAccID = new List<ID>();
        if(listAccID.size() == 0){
            if(String.isNotBlank(eventId)){
                for (ZTS_US_Event_Account__c evntAcc : [SELECT ZTS_US_Event_Account__c FROM ZTS_US_Event_Account__c WHERE ZTS_US_Events__c = :eventId]) {
                    if(!listAccID.contains(evntAcc.ZTS_US_Event_Account__c)){
                        listAccID.add(evntAcc.ZTS_US_Event_Account__c);
                    }
                }
            }
        }
    } 
    
    public List<AccountWrapper> getCategories(){
        List<AccountWrapper> accountList = new List<AccountWrapper>();
        String query = 'SELECT Id, Name, ZTS_US_NARC_ID__c, BillingStreet,'+
            'ZTS_US_City__c, ZTS_EU_City__c, ZTS_EU_State_County__c,'+
            'ZTS_US_State_Province__c, Phone, Email__c,'+
            'ZTS_US_Business_Class__c, ZTS_Business_Class__c,'+
            'ZTS_US_Sub_Class_1__c'+
            ' FROM Account WHERE ZTS_EU_Account_Status__c!=\'Inactive\'';
        
        if(territoryId.size()>0){
            query += ' AND Id IN (SELECT ObjectId FROM ObjectTerritory2Association WHERE Territory2Id IN :territoryId)';
        }
        
        if(listAccID.size()>0){
            query += ' AND Id NOT IN :listAccID';
        }
        
        if(!String.isBlank(searchKey)){
            String str = '%'+searchKey+'%';
            query += ' AND Name LIKE :str';
        }
        
        query += ' ORDER BY Name LIMIT :QueryLimit OFFSET :offSetSize';
        
        
        system.debug('Sayan Query in getter = '+query);
        for(Account var:database.query(query)){
            if(!accountList.contains(new AccountWrapper(var,masterChechBoxVal))){
                accountList.add(new AccountWrapper(var,masterChechBoxVal));
            }
            
            if(!selected.containsKey(var.Id)){
                selected.put(var.Id,masterChechBoxVal);
            }
        }
        
        
        if(OldValMasterChechBoxVal != masterChechBoxVal){ //Master Checkbox is clicked
            
            //update Map Values
            for(Id var:selected.keySet()){
                selected.remove(var);
                selected.put(var,masterChechBoxVal);
            }

            buttontf = !masterChechBoxVal;
        }else{ //Master Checkbox is not clicked
            masterChechBoxVal = false;
            buttontf = true;
            for (Id var : selected.keySet()) {
                if (selected.get(var)) {
                    masterChechBoxVal = true;
                    buttontf = false;
                    break;
                }
            }
        }
        
        
        
        OldValMasterChechBoxVal = masterChechBoxVal;
        return accountList;
        
    }
    
    public Integer getAccountCounts(){
        String query = 'SELECT Count() FROM Account WHERE ZTS_EU_Account_Status__c!=\'Inactive\'';
        if(territoryId.size()>0){
            query += ' AND Id IN (SELECT ObjectId FROM ObjectTerritory2Association WHERE Territory2Id IN :territoryId)';
        }
        if(listAccID.size()>0){
            query += ' AND Id NOT IN :listAccID';
        }
        if(!String.isBlank(searchKey)){
            String str = '%'+searchKey+'%';
            query += ' AND Name LIKE :str';
        }
        countTotalRecords = Database.countQuery(query);
        return countTotalRecords;
    }
    
    
    
    
    public PageReference saveAccounts(){
        List<ZTS_US_Event_Account__c> listEventAccount = new List<ZTS_US_Event_Account__c>();
        for(Id acid:selected.keySet()){
            if(selected.get(acid)){
                if(listAccID.contains(acid)){
                    MessageOnAddAcc = 'Error: The selected Account(s) has already been added to the Event';
                    SeverityOnResult = 'ERROR';
                    listEventAccount = new List<ZTS_US_Event_Account__c>();
                    break;
                }else{
                    ZTS_US_Event_Account__c eventAcc = new ZTS_US_Event_Account__c(ZTS_US_Event_Account__c = (ID)acid, ZTS_US_Events__c=eventId);
                    if(!listEventAccount.contains(eventAcc)){
                        listEventAccount.add(eventAcc);
                    }
                }
            }
        }
            if(listEventAccount.size() > 0){
                List<Id> insertedEventAccountIdList = new List<Id>();
                List<Database.SaveResult> sv = database.insert(listEventAccount);
                for(Database.SaveResult v:sv){
                    if(v.isSuccess()){
                        insertedEventAccountIdList.add(v.getId());
                    }else{
                        MessageOnAddAcc = 'Account Save Failed with error = '+v.errors+'\nPlease contact the System Administrators for help';
                        SeverityOnResult = 'ERROR';
                    }
                }
                if(insertedEventAccountIdList.size()>0)
                    for(ZTS_US_Event_Account__c acId: listEventAccount){
                        if(!listAccID.contains(acId.ZTS_US_Event_Account__c)){
                            listAccID.add(acId.ZTS_US_Event_Account__c);
                        }
                    }
                MessageOnAddAcc = insertedEventAccountIdList.size() + ' account(s) added successfully.';
                SeverityOnResult = 'CONFIRM';
            }
        
        masterChechBoxVal = false;
        buttontf = true;
        return null;
    }
    
    public PageReference cancel(){
        String eventId = ApexPages.currentPage().getParameters().get('Id');
        PageReference page = new PageReference('/'+eventId);
        page.setRedirect(true);
        return page;
    }
    
    public boolean getprv(){
        if(offSetSize > 0)
            return false;
        else
            return true;
    }
    
    public boolean getnxt(){
        if(offSetSize + queryLimit < CountTotalRecords)
            return false;
        else
            return true;
    }
    
    
    public class AccountWrapper {
        public Account acc      { get; set;}
        public Boolean checked  { get; set; }
        public AccountWrapper(Account a,Boolean t){
            this.acc=a;
            this.checked=t;
        }
    }
}