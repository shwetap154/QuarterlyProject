/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_Class_Expense_Trigger_Helper
 * Description      : The class is used by the trigger to perform the following actions 
                            1. Query the expense record to fetch the user who created the record 
                            2. Query the user record to get associateed values for Cost Center, Project Code, Sub Account
                            3. Updates the expense record with Cost Center, Project Code, Sub Account if they are not null
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 1st, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/01/2014          Created 
 * Deloitte                 05/16/2014          Modified code to update Project Code, Cost Center and Sub Account
*****************************************************************************************************************************************/
public class ZTS_US_Class_Expense_Trigger_Helper 
{
    public static void processExpenseRecord(List <ZTS_US_Expenses__c> recExpense, Map<ID, ZTS_US_Expenses__c> mapExpenseID)
    {
        System.debug('Records to be updated :'+recExpense.size());
        List <ZTS_US_Expenses__c> updateExpense = new List<ZTS_US_Expenses__c>();
        List <User> user = new List<User>();
        Map <Id, Id> userMap = new Map<Id, Id>();
        ZTS_US_Expenses__c objExpense = new ZTS_US_Expenses__c();
        User objUser = new User();
        Map<String, ZTS_US_TypeChargeCodeCS__c> mapChargeCode = ZTS_US_TypeChargeCodeCS__c.getAll();
        Boolean flag;
        
        Map<ID, ZTS_US_Expenses__c> mapNewExpense = new Map<ID, ZTS_US_Expenses__c>();
        for(ZTS_US_Expenses__c expense: [select Id, ZTS_US_Events__r.ZTS_US_Event_Category__c, ZTS_US_Events__r.ZTS_US_Type__c from ZTS_US_Expenses__c 
                                                    where ID IN: mapExpenseID.keySet() AND ZTS_EU_Market__c != 'United States']){
            mapNewExpense.put(expense.Id, expense);                                     
        }
        for(ZTS_US_Expenses__c expense : mapExpenseID.values())
        {
            flag = false;
            objExpense.Id = expense.Id;
            for(ZTS_US_TypeChargeCodeCS__c chrgCode : mapChargeCode.values()){
                if(mapNewExpense.get(expense.Id) != null){
                    if(mapNewExpense.get(expense.Id).ZTS_US_Events__r.ZTS_US_Event_Category__c.equalsIgnoreCase(chrgCode.ZTS_US_Category__c) && 
                    mapNewExpense.get(expense.Id).ZTS_US_Events__r.ZTS_US_Type__c.equalsIgnoreCase(chrgCode.ZTS_US_Type__c)){
                    //if(expense.ZTS_US_Event_Category__c.equalsIgnoreCase(chrgCode.ZTS_US_Category__c) && expense.ZTS_US_Type__c.equalsIgnoreCase(chrgCode.ZTS_US_Type__c)){
                        if(chrgCode.ZTS_US_Cost_Center__c != null && chrgCode.ZTS_US_Cost_Center__c != '')
                            objExpense.ZTS_US_Expenses_Cost_Center__c = chrgCode.ZTS_US_Cost_Center__c;
                        if(chrgCode.ZTS_US_Project_Code__c != null && chrgCode.ZTS_US_Project_Code__c != '')
                            objExpense.ZTS_US_Expenses_Project_Code__c = chrgCode.ZTS_US_Project_Code__c;
                        if(chrgCode.ZTS_US_Sub_Account__c != null && chrgCode.ZTS_US_Sub_Account__c != '')
                            objExpense.ZTS_US_Expenses_Sub_Account__c = chrgCode.ZTS_US_Sub_Account__c;
                        flag = true;
                    }
            	}
        	}
            if(!flag){
                objExpense.ZTS_US_User_Lookup_For_Workday_Details__c = expense.CreatedById;
            }
            updateExpense.add(objExpense);
        }
        
        updateExpense(updateExpense);
    }
    
    public static void createExpenseRecord(List<ZTS_US_Speaker__c> recSpeaker)
    {
        List <ZTS_US_Expenses__c> createExpense = new List<ZTS_US_Expenses__c>();
        for(ZTS_US_Speaker__c objSpeaker : recSpeaker)
        {
            if(objSpeaker.ZTS_US_Speaker_Fee__c != null)
            {
                ZTS_US_Expenses__c objExpense  = new ZTS_US_Expenses__c();
                objExpense.ZTS_US_Events__c = objSpeaker.ZTS_US_Event__c;
                objExpense.ZTS_US_Cost__c = objSpeaker.ZTS_US_Speaker_Fee__c;
                objExpense.ZTS_US_Speaker__c = objSpeaker.Id;
                objExpense.ZTS_US_Unit__c = 1;
                objExpense.ZTS_US_Event_Category__c = 'Educational Meeting';
                objExpense.ZTS_US_Type__c = 'Speaker Fee';
                objExpense.ZTS_US_Expense_Date__c = system.today();
                objExpense.ZTS_US_Payment_Method__c = 'Check';
                createExpense.add(objExpense);  
            }
        }
        createExpense(createExpense);
    }
    
    public static void updateExpenseRecord(List<ZTS_US_Speaker__c> newSpeakerList)
    {
        List <ZTS_US_Expenses__c> updExpense = new List<ZTS_US_Expenses__c>();
        Map<Id, ZTS_US_Speaker__c> speakerMap = new Map<Id, ZTS_US_Speaker__c>();
        Map<Id, ZTS_US_Expenses__c> expenseMap = new Map<Id, ZTS_US_Expenses__c>();
        for(ZTS_US_Speaker__c objSpeaker : newSpeakerList)
        {
            if(objSpeaker.ZTS_US_Speaker_Fee__c != null)
            {
                speakerMap.put(objSpeaker.Id, objSpeaker);/*
                ZTS_US_Expenses__c objExpense  = new ZTS_US_Expenses__c();
                if(!expenseId.isEmpty())
                {
                    ZTS_US_Expenses__c tempExpense = new ZTS_US_Expenses__c();
                    tempExpense = expenseId[0];
                    objExpense.Id = tempExpense.Id;
                }
                objExpense.ZTS_US_Cost__c = objSpeaker.ZTS_US_Speaker_Fee__c;
                updExpense.add(objExpense);*/
            }   
        }
        if( !speakerMap.isEmpty() ) {
            for(ZTS_US_Expenses__c expense : [Select Id, ZTS_US_Cost__c, ZTS_US_Speaker__c from ZTS_US_Expenses__c where ZTS_US_Speaker__c IN :speakerMap.keySet() AND ZTS_EU_Market__c != 'United States']) {
                if( !expenseMap.keySet().contains(expense.Id) ) {
                    expense.ZTS_US_Cost__c = speakerMap.get(expense.ZTS_US_Speaker__c).ZTS_US_Speaker_Fee__c;
                    expenseMap.put(expense.Id, expense);
                }
            }
            SYstem.debug('$$$ expenseMap: '+expenseMap);
            updExpense = expenseMap.values();
            updateExpense(updExpense);
        }
    }
    
    public static void updateExpense(List<ZTS_US_Expenses__c> expense)
    {
        try
        {
            update expense;
        }
        catch (Exception ex)
        {
            System.debug('Error occured while updating expense record : '+ex);
        }
    }
    
    public static void createExpense(List<ZTS_US_Expenses__c> expense)
    {
        try
        {
            insert expense;
        }
        catch (Exception ex)
        {
            System.debug('Error occured while creating expense record : '+ex);
        }
    }
    
    /* Name: deleteExpenseRecord
    *  Parameter: List<ZTS_US_Expenses__c>
    *  Description: Method to check if the selected expense record can be deleted or not. The expense records can be deleted only if the Event status is 'New'
    */
    public static void deleteExpenseRecord(List<ZTS_US_Expenses__c> listExpense){
        List<ID> listEventId = new List<Id>();
        for(ZTS_US_Expenses__c expense: listExpense){
            listEventId.add(expense.ZTS_US_Events__c);
        }
        Map<ID, ZTS_Events__c> mapEvents = new Map<ID, ZTS_Events__c>([select id, ZTS_US_Status__c from ZTS_Events__c where ID IN: listEventId AND ZTS_EU_Market__c != 'United States']);
        if (!mapEvents.isEmpty()){   
            for(ZTS_US_Expenses__c expense: listExpense){
                if(mapEvents.get(expense.ZTS_US_Events__c).ZTS_US_Status__c != 'New'){
                    expense.addError('You cannot delete an Expense if the Event status is not New');
                }
            }
        }
    }
    
    /* Name         : deleteSpeakerExpense
    *  Parameter    : List<ID>
    *  Description  : Method to delete expense records associated with deleted Speaker records if status of Event is 'New'
    */
    public static void deleteSpeakerExpense(List<ID> listSpeakerId){
        List<ZTS_US_Expenses__c> listDeletedExpenses = new List<ZTS_US_Expenses__c>();
        System.debug('expense record :'+[select Id,ZTS_US_Events__c, ZTS_US_Events__r.ZTS_US_Status__c,ZTS_EU_Market__c from ZTS_US_Expenses__c]);
        for(ZTS_US_Expenses__c expense :[select Id,ZTS_US_Events__c, ZTS_US_Events__r.ZTS_US_Status__c from ZTS_US_Expenses__c where ZTS_US_Speaker__c IN: listSpeakerId AND ZTS_EU_Market__c != 'United States']){
            if(expense.ZTS_US_Events__r.ZTS_US_Status__c.equalsIgnoreCase('New')){
                listDeletedExpenses.add(expense);
            }
        }
        if(listDeletedExpenses != null && listDeletedExpenses.size() > 0){
            delete listDeletedExpenses;
        }
    }
    
    /* Name         : createFeedItem
    *  Parameter    : List<ID>, Map<ID, ZTS_US_Expenses__c>
    *  Description  : Method to create a feed item for expense records
    */
    public static void createFeedItem(List <ZTS_US_Expenses__c> newExpenseRecord, Map<ID, ZTS_US_Expenses__c> mapExpenseID_Records)
    {
        List<Id> eventId = new List<Id>();
        Map<Id, ZTS_Events__c> eventsMap = new Map<Id, ZTS_Events__c>();
        for(ZTS_US_Expenses__c objTempExpense : newExpenseRecord)
        {
            eventId.add(objTempExpense.ZTS_US_Events__c);
        }
        
        for (ZTS_Events__c objEvents : [Select Id, ZTS_US_Name__c from ZTS_Events__c where Id IN: eventId AND ZTS_EU_Market__c != 'United States'])
        {
            eventsMap.put(objEvents.Id, objEvents);
        }
        
        for(ZTS_US_Expenses__c objExpense : newExpenseRecord)
        {
            ZTS_Events__c tempEvent = new ZTS_Events__c();
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            ZTS_US_Expenses__c objPreviousExpense = mapExpenseID_Records.get(objExpense.Id);
            ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
            List<ConnectApi.MessageSegmentInput> segmentList = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            if(objExpense.ZTS_US_Payment_Status__c!=objPreviousExpense.ZTS_US_Payment_Status__c)
            {
                tempEvent = eventsMap.get(objExpense.ZTS_US_Events__c);
                if(tempEvent != null)
                {
                    textSegment.text = 'Payment status of expense ' + objExpense.Name + ' changed from '+ objPreviousExpense.ZTS_US_Payment_Status__c + ' ' + 'to ' + 
                    objExpense.ZTS_US_Payment_Status__c + ' ' + 'for Event ' + tempEvent.ZTS_US_Name__c;
                }
                
                else{
                    textSegment.text = 'Payment status of expense ' + objExpense.Name + ' changed from '+ objPreviousExpense.ZTS_US_Payment_Status__c + ' ' + 'to ' + 
                    objExpense.ZTS_US_Payment_Status__c;
                }
                
                segmentList.add((ConnectApi.MessageSegmentInput)textSegment);
                body.messageSegments = segmentList;
                input.body = body;
                ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, objExpense.Id, input, null);
            }
        }
        
    }
}