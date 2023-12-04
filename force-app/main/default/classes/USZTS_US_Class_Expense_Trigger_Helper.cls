/****************************************************************************************************************************************** 
 * Class Name       : USZTS_US_Class_Expense_Trigger_Helper
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
public class USZTS_US_Class_Expense_Trigger_Helper 
{
    /*************************
    * Method Name   : processExpenseRecord
    * Description   : This method checks for the custom setting values to update Expense record accordingly
    * Return Type   : void
    * Parameters    : List <ZTS_US_Expenses__c>, Map<ID, ZTS_US_Expenses__c>
    *************************/
    public static void processExpenseRecord(List <ZTS_US_Expenses__c> recExpense, Map<ID, ZTS_US_Expenses__c> mapExpenseID)
    {
        List <ZTS_US_Expenses__c> updateExpense = new List<ZTS_US_Expenses__c>();
        List <User> user = new List<User>();
        Set<Id> userIdSet = new Set<Id>();
        Map<id, User> userIdRecordMap = new Map<id, User>();
        Map <Id, Id> userMap = new Map<Id, Id>();
        ZTS_US_Expenses__c objExpense = new ZTS_US_Expenses__c();
        User objUser = new User();
        Map<String, ZTS_US_TypeChargeCodeCS__c> mapChargeCode = ZTS_US_TypeChargeCodeCS__c.getAll();
        Boolean flag;
        
        Map<ID, ZTS_US_Expenses__c> mapNewExpense = new Map<ID, ZTS_US_Expenses__c>();
        for(ZTS_US_Expenses__c expense: [select Id, ZTS_US_Events__r.ZTS_US_Event_Category__c,ZTS_US_Events__r.OwnerId, ZTS_US_Events__r.ZTS_US_Type__c, ZTS_US_Event_Category__c,ZTS_US_Type__c,
                                                 ZTS_US_Total__c, ZTS_US_Expenses_Cost_Center__c, ZTS_US_Expenses_Project_Code__c, ZTS_US_Expenses_Sub_Account__c, ZTS_US_Unit__c,ZTS_US_Cost__c from ZTS_US_Expenses__c 
                                                    where ID IN: mapExpenseID.keySet() AND ZTS_EU_Market__c = 'United States']){
            userIdSet.add(expense.ZTS_US_Events__r.OwnerId);
            mapNewExpense.put(expense.Id, expense);                                     
        }
        System.debug('********userIdSet********'+userIdSet);
        userIdRecordMap = new Map<id, User>([Select id, ZTS_US_Cost_Center__c, ZTS_US_Project_Code__c, ZTS_US_Sub_Account__c FROM USER Where Id IN:userIdSet AND ZTS_EU_Market__c = 'United States']);
                    System.debug('********userIdRecordMap ********'+userIdRecordMap );
        for(ZTS_US_Expenses__c expense : mapNewExpense.values())
        {
            flag = false;
            objExpense.Id = expense.Id;
            objExpense.ZTS_US_Expenses_Cost_Center__c =  userIdRecordMap.get(expense.ZTS_US_Events__r.OwnerId).ZTS_US_Cost_Center__c;
            objExpense.ZTS_US_Expenses_Project_Code__c = userIdRecordMap.get(expense.ZTS_US_Events__r.OwnerId).ZTS_US_Project_Code__c;
            objExpense.ZTS_US_Expenses_Sub_Account__c = userIdRecordMap.get(expense.ZTS_US_Events__r.OwnerId).ZTS_US_Sub_Account__c;
            for(ZTS_US_TypeChargeCodeCS__c chrgCode : mapChargeCode.values()){
                if(mapNewExpense.get(expense.Id).ZTS_US_Events__r.ZTS_US_Event_Category__c.equalsIgnoreCase(chrgCode.ZTS_US_Category__c) && 
                mapNewExpense.get(expense.Id).ZTS_US_Events__r.ZTS_US_Type__c.equalsIgnoreCase(chrgCode.ZTS_US_Type__c)){
                    if(chrgCode.ZTS_US_Cost_Center__c != null && chrgCode.ZTS_US_Cost_Center__c != '')
                        objExpense.ZTS_US_Expenses_Cost_Center__c = chrgCode.ZTS_US_Cost_Center__c;
                    if(chrgCode.ZTS_US_Project_Code__c != null && chrgCode.ZTS_US_Project_Code__c != '')
                        objExpense.ZTS_US_Expenses_Project_Code__c = chrgCode.ZTS_US_Project_Code__c;
                    if(chrgCode.ZTS_US_Sub_Account__c != null && chrgCode.ZTS_US_Sub_Account__c != '')
                        objExpense.ZTS_US_Expenses_Sub_Account__c = chrgCode.ZTS_US_Sub_Account__c;
                    flag = true;
                }
            }
           if(!flag){
               // objExpense.ZTS_US_User_Lookup_For_Workday_Details__c = expense.CreatedById;
              
            }
            updateExpense.add(objExpense);
        }
        
        updateExpense(updateExpense);
    }
    
    /*************************
    * Method Name   : createExpenseRecord
    * Description   : This method creates expense record for each Speaker created
    * Return Type   : void
    * Parameters    : List <ZTS_US_Speaker__c>
    *************************/
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
                objExpense.ZTS_US_Event_Category__c = objSpeaker.ZTS_US_Event_Category__c;
                objExpense.ZTS_US_Type__c = 'Speaker Fee';
                objExpense.ZTS_US_Apex_context__c = true;
                //objExpense.ZTS_US_Expense_Date__c = system.today();
                objExpense.ZTS_US_Expense_Date__c = objSpeaker.ZTS_US_Speaking_Date__c;
                objExpense.ZTS_US_Payment_Method__c = 'Check';
                createExpense.add(objExpense);  
            }
        }
        createExpense(createExpense);
    }
    
    /*************************
    * Method Name   : updateExpenseRecord
    * Description   : This method updates the expense record associated to the speaker being updated
    * Return Type   : void
    * Parameters    : List <ZTS_US_Speaker__c>
    *************************/
    public static void updateExpenseRecord(List<ZTS_US_Speaker__c> newSpeakerList)
    {
        List<ID> listSpeakerID = new List<ID>();
        for(ZTS_US_Speaker__c speaker: newSpeakerList){
            listSpeakerID.add(speaker.Id);
        }
        Map<ID, ZTS_US_Speaker__c> mapSpeakerExpense = new Map<ID, ZTS_US_Speaker__c>([select Id, ZTS_US_Speaker_Fee__c, (select Id, ZTS_US_Cost__c from Expenses__r) 
                                                                            from ZTS_US_Speaker__c where ID IN: listSpeakerID AND ZTS_EU_Market_from_Parent__c = 'United States']);
        List<ZTS_US_Expenses__c> listUpdExpense = new List<ZTS_US_Expenses__c>();
        
        for(ID speakerID : mapSpeakerExpense.keySet()){
            if(mapSpeakerExpense.get(speakerID) != null && mapSpeakerExpense.get(speakerID).Expenses__r != null){
                for(ZTS_US_Expenses__c expense: mapSpeakerExpense.get(speakerID).Expenses__r){
                    expense.ZTS_US_Cost__c = mapSpeakerExpense.get(speakerID).ZTS_US_Speaker_Fee__c;
                    expense.ZTS_US_Apex_context__c = true;
                    listUpdExpense.add(expense);
                }
            }
        } 
        updateExpense(listUpdExpense);
    }
    
    /*************************
    * Method Name   : updateExpense
    * Description   : This method updates the expense record 
    * Return Type   : void
    * Parameters    : List <ZTS_US_Speaker__c>
    *************************/
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
    
    /*************************
    * Method Name   : createExpense
    * Description   : This method creates the expense record 
    * Return Type   : void
    * Parameters    : List <ZTS_US_Speaker__c>
    *************************/
    public static void createExpense(List<ZTS_US_Expenses__c> expense)
    {
        try
        {
            insert expense;
            System.debug('*******Apex context***'+expense);
        }
        catch (Exception ex)
        {
            System.debug('Error occured while creating expense record : '+ex);
        }
    }
    
    /*************************
    * Method Name   : deleteExpenseRecord
    * Description   : Method to check if the selected expense record can be deleted or not. The expense records can be deleted only if the Event status is 'New' 
    * Return Type   : void
    * Parameters    : List <ZTS_US_Expenses__c>
    *************************/
    public static void deleteExpenseRecord(List<ZTS_US_Expenses__c> listExpense){
        List<ID> listEventId = new List<Id>();
        for(ZTS_US_Expenses__c expense: listExpense){
            listEventId.add(expense.ZTS_US_Events__c);
        }
        Map<ID, ZTS_Events__c> mapEvents = new Map<ID, ZTS_Events__c>([select id,ZTS_US_Start_Date__c, ZTS_US_Status__c from ZTS_Events__c where ID IN: listEventId AND ZTS_EU_Market__c = 'United States']);
        for(ZTS_US_Expenses__c expense: listExpense){
            if(mapEvents.get(expense.ZTS_US_Events__c).ZTS_US_Start_Date__c < System.today()){
                expense.addError('You cannot delete an Expense if the Event start date is before today');
            }
        }
    }
    
    /*************************
    * Method Name   : deleteSpeakerExpense
    * Description   : Method to delete expense records associated with deleted Speaker records if status of Event is 'New' 
    * Return Type   : void
    * Parameters    : List <ID>
    *************************/
    public static void deleteSpeakerExpense(List<ID> listSpeakerId){
        List<ZTS_US_Expenses__c> listDeletedExpenses = new List<ZTS_US_Expenses__c>();
        for(ZTS_US_Expenses__c expense :[select Id,ZTS_US_Events__c, ZTS_US_Events__r.ZTS_US_Status__c, ZTS_US_Type__c, ZTS_US_Unit__c,ZTS_US_Cost__c
                                                from ZTS_US_Expenses__c where ZTS_US_Speaker__c IN: listSpeakerId AND ZTS_EU_Market__c = 'United States']){
            if(expense.ZTS_US_Events__r.ZTS_US_Status__c.equalsIgnoreCase('New')){
                listDeletedExpenses.add(expense);
            }
        }
        if(listDeletedExpenses != null && listDeletedExpenses.size() > 0){
            delete listDeletedExpenses;
        }
    }
    
    /*************************
    * Method Name   : createFeedItem
    * Description   : Method to create a feed item for expense records 
    * Return Type   : void
    * Parameters    : List<ID>, Map<ID, ZTS_US_Expenses__c>
    *************************/
    public static void createFeedItem(List <ZTS_US_Expenses__c> newExpenseRecord, Map<ID, ZTS_US_Expenses__c> mapExpenseID_Records)
    {
        List<Id> eventId = new List<Id>();
        Map<Id, ZTS_Events__c> eventsMap = new Map<Id, ZTS_Events__c>();
        for(ZTS_US_Expenses__c objTempExpense : newExpenseRecord)
        {
            eventId.add(objTempExpense.ZTS_US_Events__c);
        }
        
        for (ZTS_Events__c objEvents : [Select Id, ZTS_US_Name__c, ZTS_US_End_Date__c, ZTS_US_Start_Date__c,ZTS_US_Event_Category__c,ZTS_US_Location__c 
                                        from ZTS_Events__c where Id IN: eventId AND ZTS_EU_Market__c = 'United States'])
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
                textSegment.text = 'Payment status of expense ' + objExpense.Name + ' changed from \"'+ objPreviousExpense.ZTS_US_Payment_Status__c + '\" ' + 'to \"' + 
                                    objExpense.ZTS_US_Payment_Status__c + '\". Details are as follows \n- Expense Type: ' + objExpense.ZTS_US_Type__c +
                                    '\n- Units: ' + objExpense.ZTS_US_Unit__c + '\n- Cost: ' + objExpense.ZTS_US_Cost__c +
                                    '\n- Total Expense: ' + objExpense.ZTS_US_Total__c + 
                                    '\n- Event Name: ' + tempEvent.ZTS_US_Name__c + '\n- Event Category: ' + tempEvent.ZTS_US_Event_Category__c+
                                    '\n- Start Date: ' + Date.valueOf(tempEvent.ZTS_US_Start_Date__c) + '\n- End Date: ' + Date.valueOf(tempEvent.ZTS_US_End_Date__c) +
                                    '\n- Event Location: ' + tempEvent.ZTS_US_Location__c;
                segmentList.add((ConnectApi.MessageSegmentInput)textSegment);
                body.messageSegments = segmentList;
                input.body = body;
                ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, objExpense.Id, input, null);
            }
        }
        
    }
}