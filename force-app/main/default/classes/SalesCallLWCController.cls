/******************************************************************************************************************************************
* Class Name   : SalesCallLWCController
* Description  : Controller for salesCall LWC
* Created By   : Slalom/Alex Carstairs
* Created Date : 24 March 2020
*
* Modification Log:
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Alex Carstairs(Slalom)     03/24/2020          Created.
* Elton Barbosa(Slalom)      09/04/2020          Updated removeItem method argument type for callId to String
* Aritra(Cognizant)       10/15/2020          Updated attendee search object from contact to account contact affiliation(SC-008075)
* Aritra(Cognizant)          04/09/2021          Removed MARKET_CHECK from the queries and added separate section for INTL sample drops to enable SalesCallLWC page for INTL users(SC-004726)
* James George(Cognizant)     03/25/2021          Updated call follow up task creation to include Follow Up Item field (SC-008407)
* Aritra (Cognizant)          06/11/2021          Added related "Opportunity Call" record fetch and "Opportunity Call" record saving logic for (SC-008128)
* Aritra (Cognizant)         08/05/2021       Added more logics to get task picklist options in translated languages (SC-004726)
* Aritra (Cognizant)          11/17/2021          Changed the getSubTypes method to show new set of sub types for Poultry Users (SC-009094)
* Aritra (Cognizant)         12/13/2021          Changed the method "CreateDiscussion" to create additional Discussion records from products 
*                                                 associated to Discussion Item or Campaign record selected in the call for US market (SC-008975)
* Aritra (Cognizant)         12/13/2021          Added new methods to look for matching calls before call save/submit for US (SC-008846)
* Aritra (Cognizant)         01/18/2022          Added null checking in "createTask" and "getFollowUpActivities" methods(SC-008868)
* Padma  (Zoetis)            06/06/2022          US-0001289: SOSL Search on SalesCallLWCController sometimes fails to find results to valid search terms.
*                                                logic remains same.
* Morgan (Zoetis)            06/09/2022          US-001289: Fixed additional bugs caused by poorly designed bind variable logic from OBJECT_WHERE_CLAUSE_MAPPING.
*                                                This is a temporary workaround until this code has the opportunity to be refactored.
* Sreekanth (Cognizant)      06/12/2022          US-009853: Modified OBJECT_WHERE_CLAUSE_MAPPING to hide deactivated products.
* Sayan Majumder (Cognizant) 31//01/2023         SC-009780: Added fixes for the call duplicity, 100 SOQL error, Uniqueness error and removed all unnecessary debug logs, 
                                                            Modified the saveLookupResults function, replaces the older CreateDiscussion function with new CreateDiscussionNew function
* Prasun Dubey (Cognizant)   04/06/2023          TPDEV-320 Modified the code to handle duplicate contact selection according to new duplicate rule (FirstName+LastName+Colleague Entered Email)
* Rahul R(Cognizant)          13/10/2023          TPDEV-2057 In getSubTypes() method in SalesCallLWCController class, instead of using emp name using emp Id(quey using for fetch userTerritoryLst)
* Pooja R(Cognizant)          13/10/2023          TPDEV-1215 In getsubtype() method in SalesCallLWCController class Check if user don't have account position, then check for user record and show values based on field force id in Call>>Subtype.
*****************************************************************************************************************************************/
public with sharing class SalesCallLWCController {
    
    static final String MARKET_CHECK = 'United States';
    static final String CONTACT_CREATION_RESTRICTED_MKT_CHECK = 'Russia';//Added by Aritra for SC-004726
    static final String ACTIVE_STATUS = 'Active';//added by Aritra (SC-008075)
    static final String OBJECT_API = 'Call__c';
    static final String NEW_STATUS = 'Planned';
    static final String DEFAULT_SAMPLE_DROP_TYPE = 'Sample Drop';
    static final String REMOVE_TASK_ERROR = 'Unable to remove Task that is not assigned to you.';
    static final String INSUFF_CHECK = 'insufficient access rights';
    
    // Max number of results to return to user from search
    // And individual object limits to return
    private final static Integer MAX_TOTAL_RESULTS = 500;
    private final static Integer MAX_RESULTS = 50;


    @TestVisible
    private final static Map<String,List<String>> OBJECT_FIELD_MAPPING = new Map<String,List<String>>{
        //Added mapping for ZTS_EU_Affiliations__c by Aritra (SC-008075)
        'User' => new List<String>{'Id', 'Name'},
            'Contact' => new List<String>{'Id', 'Name', 'ZTS_US_Profession__c', 'Title', 'MailingCity', 'MailingState', 'Account.Name', 'AccountId', 'OwnerId', 'Account_Name__c'},
                'ZTS_EU_Affiliations__c' => new List<String>{'Id', 'ZTS_EU_Contact__c', 'ZTS_EU_Contact_Name_Text__c', 'ZTS_EU_Contact__r.Title', 'ZTS_EU_Contact__r.MailingCity', 'ZTS_EU_Contact__r.MailingState', 'ZTS_EU_Account_Name_text__c', 'ZTS_EU_Account__c', 'ZTS_EU_Contact__r.OwnerId'},
                    'ZTS_EU_Discussion_Item__c' => new List<String>{'Name', 'ZTS_EU_Discussion_Item_Title__c', 'ZTS_EU_Active_DI__c'},
                        'Campaign' => new List<String>{'Id', 'Name', 'IsActive', 'ZTS_EU_Field_Targeting__c', 'StartDate', 'EndDate'},
                            'ZTS_EU_Species_Product__c' => new List<String>{'Id', 'Name', 'ZTS_Hierarchy_Level__c'},
                                'Attendee__c' => new List<String>{'Id', 'Name'},
                                    'ZTS_EU_Colleague__c' => new List<String>{'Id', 'Name'},
                                        'ZTS_US_Sample__c' => new List<String>{'Id', 'Product_Name_Title__c', 'Name','ZTS_US_Product__c','ZTS_US_Product__r.Name','ZTS_US_Product__r.ZTS_Description__c','ZTS_US_Item_Code__c','ZTS_US_Start_Quantity__c ','ZTS_US_On_Hand_Balance__c','OwnerId','ZTS_US_Lot__c'},
                                            'ZTS_US_Sample_Drop__c' => new List<String>{'Id', 'Name'},
                                                'Sample_Drop__c' => new List<String>{'Id', 'Name','ZTS_EU_Product__r.Name','ZTS_EU_Sample__r.ZTS_EU_On_Hand_Balance__c','ZTS_EU_Contact__c','ZTS_EU_Contact__r.Name','ZTS_EU_Quantity__c'}, //Added by Aritra for SC-004726
                                                    'ZTS_EU_Sample__c' => new List<String>{'Id','ZTS_EU_Year__c', 'Name','ZTS_EU_Product__c','PIT_Name__c','ZTS_EU_Product__r.Name','ZTS_EU_On_Hand_Balance__c','ZTS_EU_Contact__c','ZTS_EU_Contact__r.Name','ZTS_EU_Contact__r.Account.ZTS_EU_Market__c'},//Added by Aritra for SC-004726
                                                        'ZTS_EU_Discussion__c' => new List<String>{'Id', 'Name'},
                                                            'Opportunity' => new List<String>{'Id', 'Name'},//added by Aritra for SC-008128
                                                                'Opportunity_Call__c' => new List<String>{'Id', 'Opportunity__r.Name','Name'}//added by Aritra for SC-008128
    };
        
        /* NOTE 2022-06-09 (yyyy-mm-dd): This method of mapping WHERE Clauses does not work correctly
*  due to issues with SOSL String Bindings and inaccurate search results.
*  To avoid a complete refactor of this code, we are fixing this issue by using
*  string.replace in the search() method to replace these invalid binds with 
*  the correct string join variables. This will result in more consistent 
*  and accurate search results until this functionality can be completely refactored.
*
*  The downside to this approach is that if you add new bind variables here, you need to also 
*  add a related String.replace function to search() otherwise it may not work as expected.
*/
        @TestVisible
        private final static Map<String,List<String>> OBJECT_WHERE_CLAUSE_MAPPING = new Map<String,List<String>>{
            'User' => new List<String>{'IsActive = true'}, // Added by - Anuj Sharma| SC-008833 |15-Nov-21| To show active user record in look up search.
                'Contact' => new List<String>{ 'AccountId = :accountId'},
                    'ZTS_EU_Affiliations__c' => new List<String>{'ZTS_EU_Account__c = :accountId', 'ZTS_EU_Affiliation_Status__c = :ACTIVE_STATUS'}, //Added mapping for ZTS_EU_Affiliations__c by Aritra (SC-008075)
                        'ZTS_EU_Discussion_Item__c' => new List<String>{'ZTS_EU_Active_DI__c=true'},
                            'Campaign' => new List<String>{'IsActive=true', 'Is_Active_Campaign__c=true'},
                                'ZTS_EU_Species_Product__c' => new List<String>{'ZTS_EU_Market__c = :userMarket', 'ZTS_EU_Is_Active__c = true','ZTS_EU_Is_Detailable__c = true','ZTS_Hierarchy_Level__c = \'Brand\'','ZTS_EU_Is_Active__c = true','ZTS_EU_is_Gift__c = true'},//This is for INTL, done by Aritra for SC-004726
                                    'Attendee__c' => new List<String>{},
                                        'ZTS_EU_Colleague__c' => new List<String>{},
                                            'ZTS_US_Sample__c' => new List<String>{'OwnerId=:currentUserId','ZTS_US_On_Hand_Balance__c > 0'}, // if using UserInfo.getUserId() in search, need to use currentUserId as that is create in the search method
                                                'ZTS_EU_Sample__c' => new List<String>{'ZTS_EU_Account__c = :accountId','ZTS_EU_On_Hand_Balance__c > 0'},// 'ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c = \'Active\''},//Added by Aritra for SC-004726
                                                    'ZTS_US_Sample_Drop__c' => new List<String>{},
                                                        'Sample_Drop__c' => new List<String>{}, //Added by Aritra for SC-004726
                                                            'ZTS_EU_Discussion__c' => new List<String>{},
                                                                'Opportunity' => new List<String>{'AccountId = :accountId'} //Added by Aritra for SC-008128
        };
            
            // Mapping of fields that need to be returned from SOSL search query
            @TestVisible
            private final static Map<String,String> OBJECT_ICON_MAPPING = new Map<String,String>{
                //Added mapping for ZTS_EU_Affiliations__c by Aritra (SC-008075)
                'User' => 'standard:user',
                    'ZTS_EU_Affiliations__c' => 'standard:contact',
                    'Contact' => 'standard:contact',
                    'ZTS_EU_Discussion_Item__c' => 'custom:custom59',
                    'Campaign' => 'standard:campaign',
                    'ZTS_EU_Species_Product__c' => 'custom:custom58',
                    'Attendee__c' => 'standard:contact',
                    'ZTS_EU_Colleague__c' => 'standard:user',
                    'ZTS_US_Sample__c' => 'custom:custom66',
                    'ZTS_US_Sample_Drop__c' => 'custom:custom66',
                    'ZTS_EU_Sample__c' => 'custom:custom66', //Added by Aritra for SC-004726
                    'Sample_Drop__c' => 'custom:custom66', //Added by Aritra for SC-004726
                    'ZTS_EU_Discussion__c' => 'custom:custom89',
                    'Opportunity' => 'standard:opportunity', //Added by Aritra for SC-008128
                    'Opportunity_Call__c' => 'custom:custom90' //Added by Aritra for SC-008128
                    };
                        
                        @TestVisible
                        private final static Map<String,SObjectField> OBJECT_TITLE_MAPPING = new Map<String,SObjectField>{
                            //Added mapping for ZTS_EU_Affiliations__c by Aritra (SC-008075)
                            'User' => User.Name, 
                                'Contact' => Contact.Name,
                                'ZTS_EU_Affiliations__c' => ZTS_EU_Affiliations__c.ZTS_EU_Contact_Name_Text__c,
                                'ZTS_EU_Discussion_Item__c' => ZTS_EU_Discussion_Item__c.ZTS_EU_Discussion_Item_Title__c,
                                'Campaign' => Campaign.Name,
                                'ZTS_EU_Species_Product__c' => ZTS_EU_Species_Product__c.Name,
                                'Attendee__c' => Attendee__c.Name,
                                'ZTS_EU_Colleague__c' => ZTS_EU_Colleague__c.Name,
                                'ZTS_US_Sample__c' => ZTS_US_Sample__c.Product_Name_Title__c,
                                'ZTS_US_Sample_Drop__c' => ZTS_US_Sample_Drop__c.Name,
                                'ZTS_EU_Sample__c' => ZTS_EU_Sample__c.PIT_Name__c,//Added by Aritra for SC-004726
                                'Sample_Drop__c' => Sample_Drop__c.Name, //Added by Aritra for SC-004726
                                'ZTS_EU_Discussion__c' => ZTS_EU_Discussion__c.Name,
                                'Task' => Task.WhoId,
                                'Opportunity' => Opportunity.Name, //Added by Aritra for SC-008128
                                'Opportunity_Call__c' => Opportunity_Call__c.Opportunity__c.Name //Added by Aritra for SC-008128
                                };
                                    
                                    @TestVisible
                                    private final static Map<String,SObjectField> OBJECT_SUBTITLE_MAPPING = new Map<String,SObjectField>{
                                        //Added mapping for ZTS_EU_Affiliations__c by Aritra (SC-008075)
                                        'User' => null,
                                            'Contact' => null,
                                            'ZTS_EU_Affiliations__c' => ZTS_EU_Affiliations__c.ZTS_EU_Account_Name_text__c,
                                            'ZTS_EU_Discussion_Item__c' => ZTS_EU_Discussion_Item__c.Name,
                                            'Campaign' => null,
                                            'ZTS_EU_Species_Product__c' => ZTS_EU_Species_Product__c.Name,
                                            'Attendee__c' => null,
                                            'ZTS_EU_Colleague__c' => null,
                                            'ZTS_US_Sample_Drop__c' => null,
                                            'Sample_Drop__c' => null, //Added by Aritra for SC-004726
                                            'ZTS_EU_Sample__c' => ZTS_EU_Sample__c.ZTS_EU_Product__c.Name,//Added by Aritra for SC-004726
                                            'ZTS_EU_Discussion__c' => null,
                                            'Opportunity' => null,//Added by Aritra for SC-008128
                                            'Opportunity_Call__c' => null //Added by Aritra for SC-008128   
                                            };
                                                
                                                @AuraEnabled(cacheable=true)
                                                public static String search(String searchTerm, String selectedIdsJson, String searchObjectApisJson, String accountId, string source) {
                                                    Id currentUserId = UserInfo.getUserId();
                                                    String userMarket = [Select ZTS_EU_Market__c from User where Id = :currentUserId][0].ZTS_EU_Market__c;//Added by Aritra for SC-004726
                                                    List<String> searchObjectApis = (List<String>)JSON.deserialize(searchObjectApisJson,List<String>.class);
                                                    List<String> selectedIds = (List<String>)JSON.deserialize(selectedIdsJson,List<String>.class);
                                                    searchTerm += '*';
                                                    String searchQueryString = '';
                                                    searchQueryString += 'FIND \''+ searchTerm+ '\'';
                                                    searchQueryString += 'IN ALL FIELDS RETURNING ';
                                                    for(String objectApi : searchObjectApis) {
                                                        String marketField = 'ZTS_EU_Market__c';
                                                        
                                                        if ((objectAPI == 'ZTS_US_Sample_Drop__c')||(objectAPI == 'ZTS_EU_Affiliations__c'))//Added filter logic ZTS_EU_Affiliations__c by Aritra (SC-008075)
                                                        {
                                                            marketField = 'ZTS_EU_Market_from_Parent__c';
                                                        }
                                                        if (objectAPI == 'Sample_Drop__c')//Added filter logic Sample_Drop__c by Aritra (SC-008075)
                                                        {
                                                            marketField = 'ZTS_EU_Market_from_Parent__c';
                                                        }
                                                        searchQueryString += objectApi + '(' + String.join(OBJECT_FIELD_MAPPING.get(objectApi),',');
                                                        
                                                        String str = String.format( '(\'\'{0}\'\')',new List<String> { String.join( selectedIds , '\',\'') });
                                                        searchQueryString += ' WHERE Id NOT IN ' + str;
                                                        
                                                        if(objectApi !='ZTS_EU_Species_Product__c')
                                                        {
                                                            if(OBJECT_WHERE_CLAUSE_MAPPING.get(objectApi).size() > 0) {
                                                                searchQueryString += 'AND ' + String.join(OBJECT_WHERE_CLAUSE_MAPPING.get(objectApi),' AND ');
                                                            }
                                                        }
                                                        //Product lookup filter for discussion is different for US and INTL, so Aritra added below part for SC-004726
                                                        //Same Product lookup is used for gift product selection
                                                        else
                                                        {
                                                            Integer countWhereClause = OBJECT_WHERE_CLAUSE_MAPPING.get(objectApi).size();
                                                            // List<String> criList = OBJECT_WHERE_CLAUSE_MAPPING.get('ZTS_EU_Species_Product__c');
                                                            List<String> criList = OBJECT_WHERE_CLAUSE_MAPPING.get('ZTS_EU_Species_Product__c');
                                                            // Added by : Anuj Sharma : To fix product search based on source.|
                                                            if(source == 'DiscussionItem'){
                                                                //(Product: Is DetailableEQUALSTrue) AND (Product: ActiveEQUALSTrue) AND (Current User: MarketNOT EQUAL TO United States)
                                                                searchQueryString += 'AND (('+ criList[0] + ') AND ('+criList[3]+') AND ('+ criList[1] +'))';
                                                            }
                                                            else{
                                                                if(countWhereClause == 6 )
                                                                {
                                                                    searchQueryString += 'AND (('+ criList[0] + ') AND (('+ criList[1] +' AND '+ criList[2] + ') OR (' +criList[3]+' AND '+ criList[4] + ') OR (' + criList[4] +' AND '+ criList[5] + ')))';
                                                                    
                                                                }
                                                            }
                                                        }
                                                        
                                                        if (objectApi != 'ZTS_EU_Discussion_Item__c'){
                                                            searchQueryString += ' LIMIT '+MAX_RESULTS+'),';
                                                        }         
                                                        
                                                        else searchQueryString += '),';
                                                    }
                                                    searchQueryString = searchQueryString.removeEnd(',');
                                                    searchQueryString += ' LIMIT '+MAX_TOTAL_RESULTS;
                                                    
                                                    /* NOTE 2022-06-09 (yyyy-mm-dd): The String.replace logic below is needed
*  due to issues with SOSL String Bindings from OBJECT_WHERE_CLAUSE_MAPPING.
*  To avoid a complete refactor of this code, we are fixing this issue by using
*  string.replace here to replace these invalid binds with the correct string join 
*  variables. This will result in more consistent and accurate search results until 
*  this functionality can be completely refactored.
*
*  The downside to this approach is that if you add new bind variables to OBJECT_WHERE_CLAUSE_MAPPING, 
*  you need to also add a related String.replace function below otherwise it may not work as expected.
*/
                                                    searchQueryString = searchQueryString.replace(':accountId', '\'' + accountId + '\'');
                                                    searchQueryString = searchQueryString.replace(':ACTIVE_STATUS', '\'' + ACTIVE_STATUS + '\'');
                                                    searchQueryString = searchQueryString.replace(':userMarket', '\'' + userMarket + '\'');
                                                    searchQueryString = searchQueryString.replace(':currentUserId', '\'' + currentUserId + '\'');
                                                    
                                                    
                                                    List<List<SObject>> searchResults = Search.query(searchQueryString);
                                                    List<LookupSearchResultWrapper> results = new List<LookupSearchResultWrapper>();
                                                    for(Integer i=0; i < searchObjectApis.size(); i++) {
                                                        List<SObject> objectResults = searchResults[i];
                                                        for(SObject obj : objectResults) {
                                                            results.add(buildLookupResultFromSObject(obj));
                                                        }
                                                    }
                                                    return JSON.serialize(results);
                                                }  
     
    @AuraEnabled
    public static Boolean saveLookupResults(String salesCallJson) {
        
        SalesCallWrapper returnedLookupResults = (SalesCallWrapper)JSON.deserialize(salesCallJson, SalesCallWrapper.class);
        Id callId = returnedLookupResults.callId;
        
        Call__c callRecord = [SELECT Id, ZTS_EU_Account__c FROM Call__c WHERE Id = :callId LIMIT 1];
        List<SObject> recordsToUpsert = new List<SObject>(); // includes new sample drops from samples, updating sample drops
        if(returnedLookupResults.samples != null){
            for(LookupSearchResultWrapper sampleLookupResult : returnedLookupResults.samples) {
                recordsToUpsert.add(createSampleDropFromSample(sampleLookupResult, callId, callRecord.ZTS_EU_Account__c));
            }
        }
        // Added for inserting Opportunity Call records from the Oppty selection (SC-008128)
        if(returnedLookupResults.opportunities != null){
            for(LookupSearchResultWrapper opptyLookupResult : returnedLookupResults.opportunities) {
                recordsToUpsert.add(createOpptyCallFromCall(opptyLookupResult, callId));
            }
        }
        try {
            if(recordsToUpsert.size()>0){upsert recordsToUpsert; }
        }
        catch (DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        
        
        // Create colleagues from users that were added to list in modal
        List<SObject> colleaguesToInsert = new List<SObject>();
        for(LookupSearchResultWrapper userLookupResult : returnedLookupResults.users) {
            colleaguesToInsert.add(createColleagues(userLookupResult, callId));
        }
        
        // Create attendees from contacts that were added to list in modal
        List<SObject> attendeesToInsert = new List<SObject>();
        Set<Id> contactIds = pluckIdsFromWrapper(returnedLookupResults.contacts);
        Map<Id,Id> contactIdToAccountId = new Map<Id,Id>();
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds]) {
            contactIdToAccountId.put(con.Id, con.AccountId);
        }
        
        for(LookupSearchResultWrapper contactLookupResult : returnedLookupResults.contacts) {
            attendeesToInsert.add(createAttendees(contactLookupResult, callId, contactIdToAccountId));
        }
        //Aritra commented the below part and added the below code (SC-008075)
        Set<Id> affids = pluckIdsFromWrapper(returnedLookupResults.affiliations);
        Map<Id,String> affIdToAccountContact = new Map<Id,String>();
        for(ZTS_EU_Affiliations__c aff : [SELECT Id, ZTS_EU_Contact__c,ZTS_EU_Contact__r.AccountId FROM ZTS_EU_Affiliations__c WHERE Id IN :affids]) {
            affIdToAccountContact.put(aff.Id, aff.ZTS_EU_Contact__r.AccountId+ '-' +aff.ZTS_EU_Contact__c);
        }
        
        for(LookupSearchResultWrapper affiliationLookupResult : returnedLookupResults.affiliations) {
            attendeesToInsert.add(createAttendees(affiliationLookupResult, callId, affIdToAccountContact));
        }
        
        
        List<SObject> colleaguesAndAttendees = new List<SObject>();
        colleaguesAndAttendees.addAll(colleaguesToInsert);
        colleaguesAndAttendees.addAll(attendeesToInsert);
        try {
            insert colleaguesAndAttendees;
        } 
        catch (DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        
        Set<Id> newAttendeeIds = new Set<Id>(); // Ids for the new Attendees, not blank in an new Call
        if(!attendeesToInsert.isEmpty()) {
            for(SObject attendee : attendeesToInsert)
                newAttendeeIds.add(attendee.id);
        }
        Set<Id> attendeeIds = new Set<Id>(); // Ids for the existing Attendees, not blank in an edit Call
        attendeeIds.addAll(pluckIdsFromWrapper(returnedLookupResults.attendees)); 
        List<SObject> discussionsToInsert = new List<SObject>();
        
        Map<Id,String> ProductsPresentIN_DIandCampaigns = new Map<Id,String>();
        Map<Id,String> InitialProductIdAndNameMap = new Map<Id,String>();
        
        //this is to gather all di products
        if(returnedLookupResults.discussionItems.size()>0){
            Set<Id> DiscussionIds = new Set<Id>();
            for(LookupSearchResultWrapper DI_Id : returnedLookupResults.discussionItems)
                DiscussionIds.add(DI_Id.Id);
            if(DiscussionIds.size()>0){
                for(Discussion_Item_Product__c var:[Select Product_Hierarchy__c,Product_Hierarchy__r.Name from Discussion_Item_Product__c where Discussion_Item__c =:DiscussionIds]){
                    if(!returnedLookupResults.initialDiscussionIds.contains(var.Product_Hierarchy__c) || newAttendeeIds.size()>0)//check if this Di Product has been a part of the call or if there is a new Attendee added
                        ProductsPresentIN_DIandCampaigns.put(var.Product_Hierarchy__c,var.Product_Hierarchy__r.Name);
                }
            }
        }
        
        //this is to gather all campaign products
        if(returnedLookupResults.campaigns.size()>0){
            Set<Id> CampaignIds = new Set<Id>();
            for(LookupSearchResultWrapper Cam_Id : returnedLookupResults.campaigns)
                CampaignIds.add(Cam_Id.Id);
            if(CampaignIds.size()>0){
                for(ZTS_EU_Campaign_Brand__c var:[Select ZTS_EU_Product__c,ZTS_EU_Product__r.Name from ZTS_EU_Campaign_Brand__c where ZTS_EU_Campaign__c =:CampaignIds]){
                    if(!returnedLookupResults.initialDiscussionIds.contains(var.ZTS_EU_Product__c) || newAttendeeIds.size()>0)//check if this Campaign Product has been a part of the call or if there is a new Attendee added
                        ProductsPresentIN_DIandCampaigns.put(var.ZTS_EU_Product__c,var.ZTS_EU_Product__r.Name);
                }
            }
        }
        
        
        //this is to gather all Products from returnedLookupResults variable which are added by user as a Discussion item at Call 
        if(returnedLookupResults.products.size()>0){
            for(LookupSearchResultWrapper var:returnedLookupResults.products){
                if(!ProductsPresentIN_DIandCampaigns.keySet().contains(var.Id) && !returnedLookupResults.initialDiscussionIds.contains(var.Id)/*check if this Product has ever been a part of the call earlier*/)
                    ProductsPresentIN_DIandCampaigns.put(var.Id,var.title);
                if(returnedLookupResults.initialDiscussionIds.contains(var.Id))
                    InitialProductIdAndNameMap.put(var.Id,var.title);
            }
        }
        Set<LookupSearchResultWrapper> DI = new Set<LookupSearchResultWrapper>();
        Set<LookupSearchResultWrapper> DI_to_be_inserted = new Set<LookupSearchResultWrapper>();
        Map<String,LookupSearchResultWrapper> mapOfAttendeeAndDiscussionItems = new Map<String,LookupSearchResultWrapper>();
        if(returnedLookupResults.discussionItems.size()>0){
            DI.addAll(returnedLookupResults.discussionItems);
        }if(returnedLookupResults.campaigns.size()>0){
            DI.addAll(returnedLookupResults.campaigns);
        }if(returnedLookupResults.products.size()>0){
            DI.addAll(returnedLookupResults.products);
        }
        
        
        
        //attendeeIds = existing Attendees in system
        //newAttendeeIds = New Attendees to be inserted
        //AllAttendeeIds = all attendees together so that we can loop through
        Set<Id> AllAttendeeIds = new Set<Id>();
        if(attendeeIds.size()>0)
            AllAttendeeIds.addAll(attendeeIds);
        if(newAttendeeIds.size()>0)
            AllAttendeeIds.addAll(newAttendeeIds);
        
        
        //Here we create a map of Initial Discussion Ids and Existing Discussion Ids
        Map<String,String> MapOfExistingDiscussionAndAttendees = new Map<String,String>();
        for(Id v1:attendeeIds){
            for(Id v2:returnedLookupResults.initialDiscussionIds){
                MapOfExistingDiscussionAndAttendees.put(v1+'-'+v2,v2);
            }
        }
        
        for(Id allAttendee:AllAttendeeIds){
            for(LookupSearchResultWrapper discussionItemLookupResult : DI){
                if(newAttendeeIds.contains(allAttendee)){//New attendee must have all the DI
                    if(!MapOfExistingDiscussionAndAttendees.containsKey(allAttendee+'-'+discussionItemLookupResult.id))
                        mapOfAttendeeAndDiscussionItems.put(allAttendee+'-'+discussionItemLookupResult.id,discussionItemLookupResult);
                }
                if(!returnedLookupResults.initialDiscussionIds.contains(discussionItemLookupResult.id)){ //checking of some new DI is added
                    if(!MapOfExistingDiscussionAndAttendees.containsKey(allAttendee+'-'+discussionItemLookupResult.id))
                        mapOfAttendeeAndDiscussionItems.put(allAttendee+'-'+discussionItemLookupResult.id,discussionItemLookupResult);// Newly Added DI will be remapped to the old Attendees
                }
            }
        }//Done some changes here too
        
        if(ProductsPresentIN_DIandCampaigns.size()>0 && AllAttendeeIds.size()>0){
            for(Id vg:ProductsPresentIN_DIandCampaigns.keySet()){
                for(Id vf:AllAttendeeIds){
                    if(!MapOfExistingDiscussionAndAttendees.containsKey(vf+'-'+vg) && !mapOfAttendeeAndDiscussionItems.containsKey(vf+'-'+vg)){
                        String sObjectName = 'ZTS_EU_Species_Product__c';
                        Schema.SObjectType t  = Schema.getGlobalDescribe().get(sObjectName);
                        SObject s = t.newSObject();
                        s.Id = Id.valueOf(vg);
                        mapOfAttendeeAndDiscussionItems.put(vf+'-'+vg,buildLookupResultFromSObject(s));
                    }
                }
            }
        }
        
        
        if(mapOfAttendeeAndDiscussionItems.size()>0){
            createDiscussionNew(mapOfAttendeeAndDiscussionItems,ProductsPresentIN_DIandCampaigns,InitialProductIdAndNameMap,callId);
        }
        
        List<Task> tasksToUpsert = new List<Task>();
        for(FollowUpActivityWrapper faw : returnedLookupResults.followUpActivities) {
            if(String.isBlank(faw.taskId) || faw.owner[0].id == UserInfo.getUserId()) {
                tasksToUpsert.add(createTask(faw, callId));
            }
        }
        try {
            upsert tasksToUpsert;
        }
        catch(DMLException dex) {
            for(Integer i=0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        //Create Gifts for INTL (SC-004726)
        List<ZTS_EU_Gift__c> giftsToUpsert = new List<ZTS_EU_Gift__c>();
        if(returnedLookupResults.gifts != null){
            for(GiftWrapper gw : returnedLookupResults.gifts) {
                giftsToUpsert.add(createGift(gw, callId));
            }
        }
        try {
            upsert giftsToUpsert;
        }
        catch(DMLException dex) {
            for(Integer i=0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        //create competitor record and Call-competitor record(SC-009358)
        List<Competitor_Call__c> compCallRecordToInsert = new List<Competitor_Call__c>();
        if(returnedLookupResults.competitors != null){
            for(sObject comp : returnedLookupResults.competitors) {
                if(comp.getSObjectType().getDescribe().getName() == 'ZTS_Competitor__c')
                {
                    ZTS_Competitor__c c= (ZTS_Competitor__c)comp;
                    
                    compCallRecordToInsert.add(new Competitor_Call__c(Call__c=callId, Competitor__c=c.Id));
                }
            }
        }
        try {
            upsert compCallRecordToInsert;
        }
        catch(DMLException dex) {
            for(Integer i=0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        //EOC - Create Gifts for INTL (SC-004726)
        // Create nextCall 
        if(returnedLookupResults.nextCallFieldsJson != null) {
            Map<String,String> nextCallFieldsToValues = ( Map<String,String>)JSON.deserialize(returnedLookupResults.nextCallFieldsJson, Map<String,String>.class);
            Call__c nextCall = new Call__c();
            Datetime dt = (Datetime)JSON.deserialize('"'+  nextCallFieldsToValues.get('ZTS_EU_Next_Call_Date__c') +'"',Datetime.class);
            nextCall.ZTS_EU_Sub_Type__c = nextCallFieldsToValues.get('ZTS_EU_Sub_Type__c');
            nextCall.ZTS_EU_Start_Date_Time__c = dt;
            nextCall.ZTS_EU_Call_Objectives__c = nextCallFieldsToValues.get('ZTS_EU_Next_Step__c');
            nextCall.ZTS_EU_Status__c = NEW_STATUS;
            nextcall.ZTS_EU_Duration__c = nextCallFieldsToValues.get('ZTS_EU_Duration__c');
            nextCall.ZTS_EU_Account__c = nextCallFieldsToValues.get('ZTS_EU_Account__c'); 
            if(nextcall.ZTS_EU_Duration__c != null) {
                nextCall.ZTS_EU_End_Date_Time__c = calculateEndDateTime(nextcall.ZTS_EU_Duration__c, nextCall.ZTS_EU_Start_Date_Time__c);
            }
            
            try {
                insert nextCall;
            }
            catch(DMLException dex) {
                for (Integer i = 0; i < dex.getNumDml(); i++) {
                    throw new AuraHandledException(dex.getDmlMessage(i));
                }
            }
        }
        
        return true;
    }
    
   

    static Datetime calculateEndDateTime(String duration, Datetime startDateTime) {
        
        String durationHours = duration.split(' ')[0].trim();
        Integer durationMinutes = Integer.valueOf(Decimal.valueOf(durationHours) * 60); 
        
        return Datetime.valueOf(startDateTime.addMinutes(durationMinutes));
    }
    
    @AuraEnabled(cacheable=true)  
    public static String getCallRecordAndRelatedRecords(String callIdString){
        
            SalesCallWrapper salesCallWrap = new SalesCallWrapper();
            if(String.isNotBlank(callIdString)) {
                
                Id callId = Id.valueOf(callIdString);
                salesCallWrap.callId = callId;
                salesCallWrap.attendees = getAttendees(callId);
                salesCallWrap.colleagues = getColleagues(callId);
                salesCallWrap.sampleDrops = getSampleDrops(callId);
                salesCallWrap.sampleDropsINTL = getINTLSampleDrops(callId);//Added by Aritra for SC-004726
                salesCallWrap.opportunities = getOpportunities(callId);//Added by Aritra for SC-008128
                Set<Id> attendeeIds = pluckIdsFromWrapper(salesCallWrap.attendees);
                
                List<ZTS_EU_Discussion__c> discussions = [SELECT Id, Name,
                                                          ZTS_EU_Discussion_Items__c,
                                                          ZTS_EU_Campaign__c, 
                                                          ZTS_EU_Product__c 
                                                          FROM ZTS_EU_Discussion__c 
                                                          WHERE ZTS_EU_Call_Attendee__c IN :attendeeIds];
                Map<String,List<LookupSearchResultWrapper>> sObjectToListResultWrappers = getRelatedObjectFromDiscussion(discussions);
                salesCallWrap.discussionItems = sObjectToListResultWrappers.get('ZTS_EU_Discussion_Item__c');
                salesCallWrap.campaigns = sObjectToListResultWrappers.get('Campaign');
                salesCallWrap.products = sObjectToListResultWrappers.get('ZTS_EU_Species_Product__c');
                
                salesCallWrap.followUpActivities = getFollowUpActivities(callId);
                salesCallWrap.gifts = getGifts(callId);//Added by Aritra for SC-004726
                salesCallwrap.competitors = getCompetitors(callId);//Added by Aritra for SC-009358
                }
        
            return JSON.serialize(salesCallWrap);
    }
    
    // Updated method argument type for callId to String from Id.
    @AuraEnabled
    public static void removeItem(String callId, Id recordId, String sObjectTypeLabel){
        switch on sObjectTypeLabel {
            when 'Attendee' {
                removeAttendee(recordId, callId);
            }
            when 'Colleague' {
                removeColleague(recordId);
            }
            when 'Task' {
                removeTask(recordId);
            }
            when 'Discussion Item' {
                removeDiscussion(recordId, ZTS_EU_Discussion__c.ZTS_EU_Discussion_Items__c, callId);
            }
            when 'Product Hierarchy' {
                removeDiscussion(recordId, ZTS_EU_Discussion__c.ZTS_EU_Product__c, callId);
            }
            when 'Campaign' {
                removeDiscussion(recordId, ZTS_EU_Discussion__c.ZTS_EU_Campaign__c, callId);
            }
            when 'Sample Drop' {
                removeSampleDrop(recordId);
            }
            when 'Gift' {
                removeGift(recordId); //Added this part to delete the gift record (SC-004726)
            }
            when 'Opportunity Call' {
                removeOpportunity(recordId); //Added this part for deleting the Opportunity_call record (SC-008128)
            }
        }
    }
    //4-May-2022 - Below method has been added by Aritra (SC-009358)
    @AuraEnabled
    public static void deleteCompetitor(Id recordId, String sObjectTypeLabel){
        if(sObjectTypeLabel == 'ZTS_Competitor__c')
        {
            SObject comptoDelete = recordId.getSObjectType().newSObject(recordId);
            try{
                delete comptoDelete;
            }
            catch(DMLException dex){
                for(Integer i=0; i < dex.getNumDml(); i++) {
                    throw new AuraHandledException(dex.getDmlMessage(i));
                }
            }
        }
    }
    
    // Added accountId parameter to pass accounId of the account selected in call page TPDEV-320
    @AuraEnabled
    public static String createContactLookup(Id contactId,Id accountId){
        
        List<SObject> createdContact = [SELECT Id, 
                                        Name,
                                        ZTS_US_Profession__c,
                                        ZTS_US_Job_Function__c,
                                        ZTS_US_Account_influence__c,
                                        Title,
                                        MailingCity,
                                        MailingState,
                                        Account.Name,
                                        AccountId,
                                        OwnerId,
                                        Account_Name__c
                                        FROM Contact 
                                        WHERE Id = :contactId];
        if(createdContact.size() > 0) {
            createAffiliation((Contact)createdContact[0],accountId); //passing accountId in parameter TPDEV-320
            return JSON.serialize(buildLookupResultFromSObject(createdContact[0]));
        }
        
        throw new AuraHandledException('No contact exists with that Id: ' + contactId);
    }
    //4-May-2022 - Below method has been added by Aritra (SC-009358)
    @AuraEnabled
    public static String createCompetitorLookup(Id compId){
        
        List<SObject> createCompetitor = [SELECT Id, Account__c,Manufacturer__c,Other_Manufacturer__c,
                                          Distributor_choice__c,Species__c,Rx_Competitor_Product__c,US_Category__c,Date_Contract_Expires__c,Lost_Category_To_Competitor__c
                                          FROM ZTS_Competitor__c 
                                          WHERE Id = :compId];
        if(createCompetitor.size() > 0) {
            return JSON.serialize(createCompetitor[0]);
        }
        
        throw new AuraHandledException('No competitor exists with that Id: ' + compId);
    }
    
    // Changes done for SC-009936
    @AuraEnabled
    public static String getCompetitorOnAccount(Id accountId){
        
        List<SObject> createCompetitor = [SELECT Id, Account__c,Manufacturer__c,Other_Manufacturer__c,
                                          Distributor_choice__c,Species__c,Rx_Competitor_Product__c,US_Category__c,Date_Contract_Expires__c,Lost_Category_To_Competitor__c
                                          FROM ZTS_Competitor__c 
                                          WHERE Account__c =: accountId];
        if(createCompetitor.size() > 0) {
            return JSON.serialize(createCompetitor);
        }
        
        return null;
    }
    
    
    @AuraEnabled
    public static void updateContact(Id contactId, String fieldToUpdate, String newValue){
        
        Contact contactToUpdate = new Contact(Id=contactId);
        if(fieldToUpdate == 'Email') {
            if(isInternationalUser())
            {
                contactToUpdate.Email = newValue;
            }
            else{
                contactToUpdate.Interface_Email__c = newValue;
            }
        }
        if((fieldToUpdate == 'ZTS_EU_Opt_Out_Email__c') || (fieldToUpdate == 'ZTS_EU_Opt_Out_Phone__c'))
        {
            contactToUpdate.put(fieldToUpdate, Boolean.valueOf(newValue));
        }
        else {
            contactToUpdate.put(fieldToUpdate, newValue);
        }
        
        try {
            update contactToUpdate;
        }
        catch(DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    //4-May-2022 - Below method has been added by Aritra (SC-009358)
    @AuraEnabled
    public static void updateCompetitor(Id compId, String fieldToUpdate, String newValue){
        
        ZTS_Competitor__c compToUpdate = new ZTS_Competitor__c(Id=compId);
        if(fieldToUpdate == 'Lost_Category_to_competitor__c')
        {
            Boolean newval = Boolean.valueOf(newValue);
            compToUpdate.put(fieldToUpdate, newval);
        }else if (fieldToUpdate == 'Date_Contract_Expires__c'){
            Date newDate = Date.valueOf(newValue);
           // Date sampleDate = Date.parse(newValue);
           date tempdate = date.newinstance(
            newDate.year(),
            newDate.month(),
            newDate.day()
          ); 
            comptoUpdate.put(fieldToUpdate, tempdate);
        }
        else{
            compToUpdate.put(fieldToUpdate, newValue);
        } 
        try {
            update compToUpdate;
        }
        catch(DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    

    
    // Added accountId parameter to pass accounId of the account selected in call page TPDEV-320
    @TestVisible 
    static void createAffiliation(Contact createdContact, Id accountId) {
        ZTS_EU_Affiliations__c affiliation = new ZTS_EU_Affiliations__c();
        List<ZTS_EU_Affiliations__c> existingAffiliation = [SELECT Id
                                                            FROM ZTS_EU_Affiliations__c 
                                                            WHERE ZTS_EU_Account__c = : accountId
                                                            AND ZTS_EU_Contact__c = :createdContact.Id];
        if(existingAffiliation.size() > 0) {
            affiliation = existingAffiliation[0];
            affiliation.ZTS_US_Profession__c = createdContact.ZTS_US_Profession__c; 
            affiliation.ZTS_EU_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
            affiliation.ZTS_US_Job_Function__c = createdContact.ZTS_US_Job_Function__c; // added to populate US Job function field as it was not populating before TPDEV-320
            affiliation.ZTS_EU_Account_influence__c = createdContact.ZTS_US_Account_influence__c; 
        }
        else {
            affiliation.ZTS_EU_Account__c = accountId;
            affiliation.ZTS_EU_Contact__c = createdContact.Id;
            affiliation.ZTS_US_Profession__c = createdContact.ZTS_US_Profession__c; 
            affiliation.ZTS_EU_Job_Function__c = createdContact.ZTS_US_Job_Function__c; 
            affiliation.ZTS_US_Job_Function__c = createdContact.ZTS_US_Job_Function__c;  // added to populate US Job function field as it was not populating before TPDEV-320
            affiliation.ZTS_EU_Account_influence__c = createdContact.ZTS_US_Account_influence__c; 
        }
        
        try {
            upsert affiliation;
        }
        catch(DmlException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        
    }
    
    @TestVisible
    static Task createTask(FollowUpActivityWrapper taskWrapper, Id callId) {
        try{
            Task tsk = new Task();
            if(taskWrapper.Owner.size()>0){//Added by Aritra to avoid List index out of bounds exception - SC-008868
                tsk.OwnerId= taskWrapper.Owner[0].Id;
            }
            tsk.Subject = taskWrapper.Subject;
            tsk.Priority = taskWrapper.Priority;
            tsk.ActivityDate = taskWrapper.ActivityDate;
            tsk.Status = taskWrapper.Status;
            tsk.WhatId = callId;
            if(taskWrapper.followup.size()>0){//Added by Aritra to avoid List index out of bounds exception - SC-008868
                tsk.Follow_up_Item__c = taskWrapper.followup[0].Id;
            }
            
            if(String.isNotBlank(taskWrapper.taskId)) {
                tsk.Id = taskWrapper.taskId;
            }
            return tsk;
        }
        catch(DmlException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
            return null;
        }
        
        
    }
    //Aritra added this part to insert Gift (SC-004726) 
    @TestVisible
    static ZTS_EU_Gift__c createGift(GiftWrapper giftWrapper, Id callId) {
        try{
            ZTS_EU_Gift__c gft = new ZTS_EU_Gift__c(
                ZTS_EU_Contact__c = GiftWrapper.contact[0].Id,
                ZTS_EU_Product_Hierarchy__c = GiftWrapper.product[0].Id,
                ZTS_EU_Quantity__c = GiftWrapper.quantity,
                ZTS_EU_Description__c = GiftWrapper.description,
                ZTS_EU_Call__c = callId
            );
            if(String.isNotBlank(GiftWrapper.giftId)) {
                gft.Id = GiftWrapper.giftId;
            }
            return gft;
        }
        catch(DmlException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
            return null;
        }
        
        
    }
    //EOC - Aritra added this part to insert Gift (SC-004726)
    
    //New Funnction added by Sayan to UPSERT the Discussion items with uniqueness key
    @TestVisible
    static void createDiscussionNew(Map<String,LookupSearchResultWrapper> mapOfAttendeeAndDiscussionItems,Map<Id,String> ProductsPresentIN_DIandCampaigns,Map<Id,String> InitialProductIdAndNameMap,Id CallId){
        try{
            if(mapOfAttendeeAndDiscussionItems.size()>0){
                Map<String,ZTS_EU_Discussion__c> DiscussionsToInsert = new Map<String,ZTS_EU_Discussion__c>();
                for(String attendeeiId:mapOfAttendeeAndDiscussionItems.keySet()){
                    if(Id.valueOf(attendeeiId.substringAfter('-')).getSObjectType().getDescribe().getName()=='ZTS_EU_Discussion_Item__c')
                        DiscussionsToInsert.put(attendeeiId,new ZTS_EU_Discussion__c(Name = mapOfAttendeeAndDiscussionItems.get(attendeeiId).title,ZTS_EU_Call_Attendee__c = Id.valueOf(attendeeiId.substringBefore('-')),ZTS_EU_Discussion_Items__c=mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id,ZTS_EU_Uniqueness_Key__c='Attendee:'+attendeeiId.substringBefore('-')+'_'+'Discussion:'+mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id));
                    else if(Id.valueOf(attendeeiId.substringAfter('-')).getSObjectType().getDescribe().getName()=='Campaign')
                        DiscussionsToInsert.put(attendeeiId,new ZTS_EU_Discussion__c(Name = mapOfAttendeeAndDiscussionItems.get(attendeeiId).title,ZTS_EU_Call_Attendee__c = Id.valueOf(attendeeiId.substringBefore('-')),ZTS_EU_Campaign__c=mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id,ZTS_EU_Uniqueness_Key__c='Attendee:'+attendeeiId.substringBefore('-')+'_'+'Campaign:'+mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id));
                    else if(Id.valueOf(attendeeiId.substringAfter('-')).getSObjectType().getDescribe().getName()=='ZTS_EU_Species_Product__c'){
                        String Product_Name = ProductsPresentIN_DIandCampaigns.containsKey(Id.valueOf(attendeeiId.substringAfter('-'))) ? ProductsPresentIN_DIandCampaigns.get(Id.valueOf(attendeeiId.substringAfter('-'))) : ( InitialProductIdAndNameMap.containsKey(Id.valueOf(attendeeiId.substringAfter('-'))) ? InitialProductIdAndNameMap.get(Id.valueOf(attendeeiId.substringAfter('-'))) :  Id.valueOf(attendeeiId.substringAfter('-'))  );
                            DiscussionsToInsert.put(attendeeiId,new ZTS_EU_Discussion__c(Name=Product_Name,ZTS_EU_Call_Attendee__c = Id.valueOf(attendeeiId.substringBefore('-')),ZTS_EU_Product__c=mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id,ZTS_EU_Uniqueness_Key__c='Attendee:'+attendeeiId.substringBefore('-')+'_'+'Product:'+mapOfAttendeeAndDiscussionItems.get(attendeeiId).Id));
                    }
                }
                
                INSERT DiscussionsToInsert.values();
            }
        }catch (DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    
    @TestVisible
    static SObject createColleagues(LookupSearchResultWrapper userLookupResult, Id callId) {
        return new ZTS_EU_Colleague__c(
            Name = userLookupResult.title,
            ZTS_EU_Call__c = callId,
            ZTS_EU_User__c = userLookupResult.id);
    }
    @TestVisible
    static SObject createAttendees(LookupSearchResultWrapper contactLookupResult, Id callId, Map<Id,Id> contactIdToAccountId) {
        return new Attendee__c(
            Name = contactLookupResult.title,
            ZTS_EU_Call__c = callId,
            ZTS_EU_Represents_Account__c = contactIdToAccountId.get(contactLookupResult.Id),
            ZTS_EU_Contact__c = contactLookupResult.id);
    }
    //'createAttendees' method Changed by Aritra (SC-008075)
    @TestVisible
    static SObject createAttendees(LookupSearchResultWrapper affiliationLookupResult, Id callId, Map<Id,String> contactIdToAccountId) {
        //Aritra added this line call the contact upsert to writeback contact updates in attendee selection screen to contact(SC-004726)
        //upsertContact(affiliationLookupResult);
        
        return new Attendee__c(
            Name = affiliationLookupResult.title,
            ZTS_EU_Call__c = callId,
            ZTS_EU_Represents_Account__c = Id.valueOf(contactIdToAccountId.get(affiliationLookupResult.Id).split('-')[0]),
            ZTS_EU_Contact__c = Id.valueOf(contactIdToAccountId.get(affiliationLookupResult.Id).split('-')[1]));
    }
    
    //Aritra added this method to writeback contact updates in attendee selection screen to contact(SC-004726)
    /*@TestVisible
static void upsertContact (LookupSearchResultWrapper affiliationLookupResult){
ZTS_EU_Affiliations__c aff = (ZTS_EU_Affiliations__c)affiliationLookupResult.record; 
Contact con = new Contact(Id = aff.ZTS_EU_Contact__c,Email = aff.Contact_Email__c, ZTS_EU_Opt_Out_Email__c= aff.Contact_Opt_out_Email__c,
ZTS_EU_Opt_Out_Phone__c = aff.Contact_Opt_Out_Phone__c,ZTS_EU_Profession__c = aff.Contact_profession__c,ZTS_EU_Contact_type__c = aff.Contact_Type__c);
upsert con;
}*/
    
    @TestVisible
    static SObject createSampleDropFromSample(LookupSearchResultWrapper sampleLookupResult, Id callId, Id accountId) {
        
        Schema.DescribeSObjectResult dr = sampleLookupResult.record.Id.getSObjectType().getDescribe();
        if(dr.getName() == 'ZTS_US_Sample__c')
        {
            ZTS_US_Sample__c sampleRecord = (ZTS_US_Sample__c)sampleLookupResult.record; 
            return new ZTS_US_Sample_Drop__c(
                ZTS_US_Call__c = callId,
                ZTS_US_Sample__c = sampleLookupResult.record.id,
                ZTS_US_Quantity__c = sampleRecord.ZTS_US_On_Hand_Balance__c,
                ZTS_US_Account__c = accountId,
                ZTS_US_Sample_Drop_Type__c = DEFAULT_SAMPLE_DROP_TYPE
            );
        }
        //Added by Aritra for SC-004726
        else if(dr.getName() == 'ZTS_EU_Sample__c')
        {
            ZTS_EU_Sample__c sampleRecord = (ZTS_EU_Sample__c)sampleLookupResult.record; 
            return new Sample_Drop__c(
                ZTS_EU_Call__c = callId,
                ZTS_EU_Sample__c = sampleLookupResult.record.id,
                ZTS_EU_Quantity__c = sampleRecord.ZTS_EU_On_Hand_Balance__c,
                ZTS_EU_Contact__c = sampleRecord.ZTS_EU_Contact__c,
                ZTS_EU_Sample_Drop_Type__c = DEFAULT_SAMPLE_DROP_TYPE
            );
        }
        else return null;
    }
    //End of Code - Added by Aritra for SC-004726
    //Added for SC-008128
    @TestVisible
    static SObject createOpptyCallFromCall(LookupSearchResultWrapper opptyLookupResult, Id callId) {
        Opportunity opp = (Opportunity)opptyLookupResult.record;
        return new Opportunity_Call__c(
            Name = opp.Name,
            Call__c = callId,
            Opportunity__c = opp.id
            );
        
    }
    //EOC - Added for SC-008128
    
    @TestVisible
    static void removeTask(Id taskId) {
        SObject taskToDelete = taskId.getSObjectType().newSObject(taskId);
        try{
            delete taskToDelete;
        }catch(DMLException dex){
            for(Integer i=0; i < dex.getNumDml(); i++) {
                String errorMsg = dex.getDmlMessage(i);
                if(errorMsg.contains(INSUFF_CHECK)) {
                    throw new AuraHandledException(REMOVE_TASK_ERROR);
                }
                else {
                    throw new AuraHandledException(dex.getDmlMessage(i));      
                }
            }
        }
    }
    
    @TestVisible
    static void removeColleague(Id colleagueId) {
        SObject colleagueToDelete = colleagueId.getSObjectType().newSObject(colleagueId);
        try{
            delete colleagueToDelete;
        }catch(DMLException dex){
            for(Integer i=0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    
    @TestVisible
    static void removeAttendee(Id attendeeId, String callId) {
        SObject attendeeToDelete = attendeeId.getSObjectType().newSObject(attendeeId);
        List<Call__c> callRecord = [SELECT Id, 
                                    (SELECT Id FROM Attendees__r) 
                                    FROM Call__c 
                                    WHERE Id = :callId 
                                    AND ZTS_EU_Status__c in ('Submitted','Completed')];
        
        if(callRecord.size() > 0) {
            if(callRecord[0].Attendees__r.size() == 1) {
                throw new AuraHandledException('Cannot delete an Attendee as each call needs to have at least one attendee for it to be submitted.');
            }
        }
        try{
            delete attendeeToDelete;
        }catch(DMLException dex){
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    
    @TestVisible
    static void removeDiscussion(Id discussionFieldId, SObjectField discussionField, String callId) {
        
        String discussionFieldString = discussionField.getDescribe().getName();
        String discussionQuery = 'SELECT Id ';
        discussionQuery += 'FROM ZTS_EU_Discussion__c ';
        // discussionQuery += 'WHERE ZTS_EU_Market__c = :MARKET_CHECK AND ZTS_EU_Call_Attendee__r.ZTS_EU_Call__c = :callId AND ';--Aritra removed the 'MARKET_CHECK' for to enable the Sales Call LWC page for International market (SC-004726)
        discussionQuery += 'WHERE ZTS_EU_Call_Attendee__r.ZTS_EU_Call__c = :callId AND ';
        discussionQuery += discussionFieldString + ' = :discussionFieldId';
        List<ZTS_EU_Discussion__c> discussionsToDelete = Database.query(discussionQuery);
		
        // SELECT Id,Name,ZTS_EU_Call_Attendee__r.name, zts_eu_call_Attendee__r.zts_eu_call__c from ZTS_EU_Discussion__c where ZTS_EU_Market__c = 'United States'
        // SELECT Id,Name,ZTS_EU_Call_Attendee__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c=:attendeeRemoveId and Name=:discuname AND ZTS_EU_Market__c = 'United States'
        try{
            delete discussionsToDelete;
        }catch(DMLException dex){
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    
    @TestVisible
    static void removeSampleDrop(Id sampleDropId) {
        SObject sampleDropToDelete = sampleDropId.getSObjectType().newSObject(sampleDropId);
        try{
            delete sampleDropToDelete;
        }catch(DMLException dex){
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    //Aritra added this method to delete gift records (SC-004726)
    @TestVisible
    static void removeGift(Id giftId) {
        SObject giftToDelete = giftId.getSObjectType().newSObject(giftId);
        try{
            delete giftToDelete;
        }catch(DMLException dex){
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    //EOC - Aritra added this method to delete gift records (SC-004726)
    //Aritra added this method to delete opportunity call record (SC-008128)
    @TestVisible
    static void removeOpportunity(Id oppCallId) {
        SObject oppCallToDelete = oppCallId.getSObjectType().newSObject(oppCallId);
        try{
            delete oppCallToDelete;
        }catch(DMLException dex){
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
    }
    //EOC - Aritra added this method to delete opportunity call record (SC-008128)
    @TestVisible
    static Map<String,List<LookupSearchResultWrapper>> getRelatedObjectFromDiscussion(List<ZTS_EU_Discussion__c> disccusions){
        
        Map<String,List<LookupSearchResultWrapper>> sObjectToWrapperList = new Map<String,List<LookupSearchResultWrapper>>();
        
        Set<Id> discussionItemIds = new Set<Id>();
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(ZTS_EU_Discussion__c discussion : disccusions) {
            if(discussion.ZTS_EU_Discussion_Items__c != null) {
                discussionItemIds.add(discussion.ZTS_EU_Discussion_Items__c);
            }
            if(discussion.ZTS_EU_Campaign__c != null) {
                campaignIds.add(discussion.ZTS_EU_Campaign__c);
            }
            if(discussion.ZTS_EU_Product__c != null) {
                productIds.add(discussion.ZTS_EU_Product__c);
            }
        }
        
        sObjectToWrapperList.put('ZTS_EU_Discussion_Item__c',getDiscussionItems(discussionItemIds));
        sObjectToWrapperList.put('Campaign',getCampaigns(campaignIds));
        sObjectToWrapperList.put('ZTS_EU_Species_Product__c',getProducts(productIds));
        
        return sObjectToWrapperList;
    }
    
    @TestVisible
    static Set<Id> pluckIdsFromWrapper(List<LookupSearchResultWrapper> wrappers) {
        Set<Id> idSet = new Set<Id>();
        for(LookupSearchResultWrapper wrapper : wrappers){
            idSet.add(wrapper.Id);
        }
        return idSet;
    }
    
    @TestVisible
    static Set<Id> pluckIdsFromSObject(List<SObject> objects, SObjectField idField) {
        Set<Id> idSet = new Set<Id>();
        for(SObject obj : objects) {
            idSet.add((Id)obj.get(idField));
        }
        return idSet;
    }
    @TestVisible
    static List<LookupSearchResultWrapper> getAttendees(Id callId) {
        
        List<LookupSearchResultWrapper> attendeeLookupResults = new List<LookupSearchResultWrapper>();
        /* for(Attendee__c att : [SELECT Id, 
Name, 
ZTS_EU_Call__c, 
ZTS_EU_Contact__r.Name, 
ZTS_EU_Contact__r.Email, 
ZTS_EU_Contact__r.Interface_Email_Opt_Out__c, 
ZTS_EU_Contact__r.ZTS_Invalid_Email__c, 
ZTS_EU_Contact__r.ZTS_US_Profession__c, 
ZTS_EU_Contact__r.ZTS_US_Job_Function__c, 
ZTS_EU_Contact__r.Account.Name, 
ZTS_EU_Contact__r.AccountId, 
ZTS_EU_Contact__c, 
ZTS_US_Account_On_Attendee__c, 
ZTS_US_Account_On_Attendee_Id__c, 
ZTS_US_Contact_Profession__c, 
ZTS_EU_Related_Campaign__c, 
ZTS_EU_Campaign_Response__c, 
ZTS_EU_Employee__c, 
ZTS_EU_Represents_Account__c, 
(Select Id from Discussions__r) 
FROM Attendee__c 
WHERE ZTS_EU_Call__c = :callId 
AND ZTS_EU_Call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = :MARKET_CHECK]) *///Aritra removed the 'MARKET_CHECK' for to enable the Sales Call LWC page for International market (SC-004726)
        for(Attendee__c att : [SELECT Id, 
                               Name, 
                               ZTS_EU_Call__c, 
                               ZTS_EU_Contact__r.Name, 
                               ZTS_EU_Contact__r.Email, 
                               ZTS_EU_Contact__r.Interface_Email_Opt_Out__c, 
                               ZTS_EU_Contact__r.ZTS_Invalid_Email__c, 
                               ZTS_EU_Contact__r.ZTS_US_Profession__c, 
                               ZTS_EU_Contact__r.ZTS_US_Job_Function__c, 
                               ZTS_EU_Contact__r.Account.Name, 
                               ZTS_EU_Contact__r.AccountId, 
                               ZTS_EU_Contact__c, 
                               ZTS_US_Account_On_Attendee__c, 
                               ZTS_US_Account_On_Attendee_Id__c, 
                               ZTS_US_Contact_Profession__c, 
                               ZTS_EU_Related_Campaign__c, 
                               ZTS_EU_Campaign_Response__c, 
                               ZTS_EU_Employee__c, 
                               ZTS_EU_Represents_Account__c, 
                               (Select Id from Discussions__r) 
                               FROM Attendee__c 
                               WHERE ZTS_EU_Call__c = :callId ]) 
        {
            attendeeLookupResults.add(buildLookupResultFromSObject(att)); 
        }
        return attendeeLookupResults;
    }
    
    @TestVisible
    static List<LookupSearchResultWrapper> getSampleDrops(Id callId) {
        List<LookupSearchResultWrapper> sampleDropLookupResults = new List<LookupSearchResultWrapper>();
        for(ZTS_US_Sample_Drop__c sampleDrop : [SELECT Id,
                                                Name,
                                                ZTS_US_Account__c,
                                                ZTS_US_Call__c,
                                                ZTS_US_Quantity__c,
                                                ZTS_US_Sample__c,
                                                ZTS_US_Sample_Drop_Type__c,
                                                ZTS_US_Sample__r.Name,
                                                ZTS_US_Sample__r.ZTS_US_Lot__c,
                                                ZTS_US_Sample__r.Product_Name_Title__c, 
                                                ZTS_US_Sample__r.ZTS_US_On_Hand_Balance__c
                                                FROM ZTS_US_Sample_Drop__c 
                                                WHERE ZTS_US_Call__c = :callId
                                                AND ZTS_US_Account__r.ZTS_EU_Market__c = :MARKET_CHECK]) 
        {
            sampleDropLookupResults.add(buildLookupResultFromSObject(sampleDrop)); 
        }
        return sampleDropLookupResults;
    }
    //Added this method for fetching the INTL sample drop (SC-004726)
    @TestVisible
    static List<LookupSearchResultWrapper> getINTLSampleDrops(Id callId) {
        List<LookupSearchResultWrapper> sampleDropINTLLookupResults = new List<LookupSearchResultWrapper>();
        for(Sample_Drop__c sampleDrop : [SELECT Id,
                                         Name,
                                         ZTS_EU_Sample__c,
                                         ZTS_EU_Contact__c,
                                         ZTS_EU_Quantity__c,
                                         ZTS_EU_Call__c,
                                         ZTS_EU_Sample__r.Name, 
                                         ZTS_EU_Sample__r.ZTS_EU_Product__r.Name, 
                                         ZTS_EU_Sample__r.ZTS_EU_Contact__r.Name,
                                         ZTS_EU_Sample__r.ZTS_EU_On_Hand_Balance__c
                                         FROM Sample_Drop__c 
                                         WHERE ZTS_EU_Call__c = :callId]) 
        {
            sampleDropINTLLookupResults.add(buildLookupResultFromSObject(sampleDrop)); 
        }
        return sampleDropINTLLookupResults;
    }
    //End of Code - Added this method for fetching the INTL sample drop (SC-004726)
    @TestVisible
    static List<LookupSearchResultWrapper> getColleagues(Id callId) {
        List<LookupSearchResultWrapper> colleagueLookupResults = new List<LookupSearchResultWrapper>();
        for(ZTS_EU_Colleague__c colleague : [SELECT Id,
                                             Name,
                                             ZTS_EU_Call__c,
                                             ZTS_EU_User__c,
                                             ZTS_US_User_PIT_BU__c,
                                             ZTS_EU_User_Email__c
                                             FROM ZTS_EU_Colleague__c 
                                             WHERE ZTS_EU_Call__c = :callId]) 
        {
            colleagueLookupResults.add(buildLookupResultFromSObject(colleague)); 
        }
        return colleagueLookupResults;
    }
    //Added this method for fetching the related Opportunities (SC-008128)
    @TestVisible
    static List<LookupSearchResultWrapper> getOpportunities(Id callId) {
        List<LookupSearchResultWrapper> opptyLookupResults = new List<LookupSearchResultWrapper>();
        for(Opportunity_Call__c opptyCall : [SELECT Id,
                                             Name,
                                             Call__c,
                                             Opportunity__c,
                                             Opportunity__r.Name
                                             FROM Opportunity_Call__c 
                                             WHERE Call__c = :callId]) 
        {
            opptyLookupResults.add(buildLookupResultFromSObject(opptyCall)); 
        }
        return opptyLookupResults;
    }
    //EOC - Added this method for fetching the related Opportunities (SC-008128)
    @TestVisible
    static List<LookupSearchResultWrapper> getDiscussionItems(Set<Id> discussionItemIds) {
        List<LookupSearchResultWrapper> discussionItemLookupResults = new List<LookupSearchResultWrapper>();
        
        for(ZTS_EU_Discussion_Item__c discussionItem : [SELECT Id,
                                                        Name, 
                                                        ZTS_EU_Discussion_Item_Title__c
                                                        FROM ZTS_EU_Discussion_Item__c 
                                                        WHERE Id IN :discussionItemIds]) 
        {
            discussionItemLookupResults.add(buildLookupResultFromSObject(discussionItem)); 
        }
        return discussionItemLookupResults;
    }
    
    @TestVisible
    static List<LookupSearchResultWrapper> getCampaigns(Set<Id> campaignIds) {
        List<LookupSearchResultWrapper> campaignLookupResults = new List<LookupSearchResultWrapper>();
        
        /*for(Campaign campaign : [SELECT Id,
Name
FROM Campaign 
WHERE Id IN :campaignIds
AND ZTS_EU_Market__c = :MARKET_CHECK]) *///--Aritra removed the 'MARKET_CHECK' for to enable the Sales Call LWC page for International market (SC-004726)
        for(Campaign campaign : [SELECT Id,
                                 Name
                                 FROM Campaign 
                                 WHERE Id IN :campaignIds])
        {
            campaignLookupResults.add(buildLookupResultFromSObject(campaign)); 
        }
        return campaignLookupResults;
    }
    
    @TestVisible
    static List<LookupSearchResultWrapper> getProducts(Set<Id> productIds) {
        List<LookupSearchResultWrapper> productLookupResults = new List<LookupSearchResultWrapper>();
        
        for(ZTS_EU_Species_Product__c product : [SELECT Id,
                                                 Name
                                                 FROM ZTS_EU_Species_Product__c 
                                                 WHERE Id IN :productIds]) 
        {
            productLookupResults.add(buildLookupResultFromSObject(product)); 
        }
        return productLookupResults;
    }
    
    @TestVisible
    static List<FollowUpActivityWrapper> getFollowUpActivities(Id callId) {
        List<FollowUpActivityWrapper> followUpActivities = new List<FollowUpActivityWrapper>();
        
        List<Task> relatedTasks = [SELECT Id,
                                   Subject, 
                                   Status, 
                                   Priority, 
                                   OwnerId,
                                   ActivityDate, 
                                   Follow_up_Item__c FROM Task 
                                   WHERE WhatId = :callId
                                   Order By ActivityDate ASC];
        
        Set<Id> ownerIds = pluckIdsFromSObject(relatedTasks, Task.OwnerId);
        Set<Id> followUpItemIds = pluckIdsFromSObject(relatedTasks, Task.Follow_up_Item__c);
        Map<Id, User> userIdtoUser = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :ownerIds]);
        Map<Id, ZTS_EU_Species_Product__c> followUpIdToFI = new Map<Id,ZTS_EU_Species_Product__c>([SELECT Id, Name FROM ZTS_EU_Species_Product__c WHERE Id IN :followUpItemIds]);
        for(Task t : relatedTasks) 
        {
            User owner = userIdtoUser.get(t.OwnerId);
            ZTS_EU_Species_Product__c followUp;
            //Added by Aritra - added null checks on (followUp, fiLookupResult) to avoid null pointer exception - SC-008868
            if(t.Follow_up_Item__c != null && followUpIdToFI.containsKey(t.Follow_up_Item__c))
                followUp = followUpIdToFI.get(t.Follow_up_Item__c);
            LookupSearchResultWrapper ownerLookupResult = buildLookupResultFromSObject(owner);
            LookupSearchResultWrapper fiLookupResult;
            if(followUp != null)
                fiLookupResult = buildLookupResultFromSObject(followUp);
            FollowUpActivityWrapper taskWrapper = new FollowUpActivityWrapper(t);
            taskWrapper.owner = new List<LookupSearchResultWrapper>{ownerLookupResult};
                if(fiLookupResult != null)
                taskWrapper.followup = new List<LookupSearchResultWrapper>{fiLookupResult};
                    followUpActivities.add(taskWrapper);
        }
        
        return followUpActivities;
    }
    //4-May-2022 - Below method has been added by Aritra (SC-009358)
    @TestVisible
    static List<Competitor_Call__c> getCompetitors(Id callId) {
        List<Competitor_Call__c> callCompetitorList = [Select Id,Competitor__c,Competitor__r.US_Category__c,Competitor__r.Lost_Category_to_competitor__c
                                                       ,Competitor__r.Date_Contract_Expires__c,
                                                       Competitor__r.Manufacturer__c,Competitor__r.Species__c , Competitor__r.Rx_Competitor_Product__c from Competitor_Call__c where Call__c =: callId];
        return callCompetitorList;
    }
    //Aritra added this part to pull gift details associated to the call for INTL (SC-004726)
    @TestVisible
    static List<GiftWrapper> getGifts(Id callId) {
        List<GiftWrapper> gifts = new List<GiftWrapper>();
        
        List<ZTS_EU_Gift__c> relatedGifts = [SELECT Id,
                                             ZTS_EU_Contact__c, 
                                             ZTS_EU_Contact__r.Account.Name,
                                             ZTS_EU_Description__c, 
                                             ZTS_EU_Quantity__c, 
                                             ZTS_EU_Product_Hierarchy__c
                                             FROM ZTS_EU_Gift__c 
                                             WHERE ZTS_EU_Call__c = :callId
                                            ];
        
        Set<Id> contactIds = pluckIdsFromSObject(relatedGifts, ZTS_EU_Gift__c.ZTS_EU_Contact__c);
        Set<Id> productIds = pluckIdsFromSObject(relatedGifts, ZTS_EU_Gift__c.ZTS_EU_Product_Hierarchy__c);
        Map<Id, Contact> contactIdToContact = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);
        Map<Id, ZTS_EU_Species_Product__c> productIdToProduct = new Map<Id,ZTS_EU_Species_Product__c>([SELECT Id, Name FROM ZTS_EU_Species_Product__c WHERE Id IN :productIds]);
        for(ZTS_EU_Gift__c g : relatedGifts) 
        {
            Contact contact = contactIdToContact.get(g.ZTS_EU_Contact__c);
            ZTS_EU_Species_Product__c product = productIdToProduct.get(g.ZTS_EU_Product_Hierarchy__c);
            LookupSearchResultWrapper contactLookupResult = buildLookupResultFromSObject(contact);
            LookupSearchResultWrapper ProductLookupResult = buildLookupResultFromSObject(product);
            GiftWrapper gw = new GiftWrapper(g);
            gw.contact = new List<LookupSearchResultWrapper>{contactLookupResult};
                gw.product = new List<LookupSearchResultWrapper>{ProductLookupResult};
                    gifts.add(gw);
        }
        
        return gifts;
    }
    //EOC - Aritra added this part to pull gift details associated to the call for INTL (SC-004726)
    
    @TestVisible
    static LookupSearchResultWrapper buildLookupResultFromSObject(SObject obj) {
        String objectApiName = obj.getSObjectType().getDescribe().getName();
        String objectLabel = obj.getSObjectType().getDescribe().getLabel();
        SObjectField titleField = OBJECT_TITLE_MAPPING.get(objectApiName);
        SObjectField subTitleField = OBJECT_SUBTITLE_MAPPING.get(objectApiName);
        String subTitleValue;
        if(subTitleField == null) {
            subTitleValue = '';
        }
        else {
            if(!String.isBlank((String)obj.get(subTitleField))) {
                subTitleValue = ' • ' + (String)obj.get(subTitleField);
            }
            else {
                subTitleValue = '';
            }
        }
        return new LookupSearchResultWrapper(
            (Id)obj.get('Id'),
            objectLabel,
            objectApiName,
            OBJECT_ICON_MAPPING.get(objectApiName),
            (String)obj.get(titleField),
            objectLabel + subTitleValue,
            obj
        );
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getSubTypes (String callId)
    {
        List<Map<String,String>> subTypeValuesMap = new List<Map<String,String>>();
        
        List<Call__c> callRecords = [SELECT Id, ZTS_EU_Account__c FROM Call__c WHERE Id = :callId];
        Call__c callRecord = new Call__c();
        if(callRecords.size() > 0) {
            callRecord = callRecords[0];
        }
        
        List<Map<String,String>>subtypelist = new List<Map<String,String>>();
        List<String> forceidfields= new List<String>();     
        String name=Userinfo.getFirstName()+' '+Userinfo.getLastName();
        String userId=Userinfo.getuserid();
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
 
        List<ZTS_EU_Account_Position__c> accposlist = new List<ZTS_EU_Account_Position__c>();
        accposlist =[SELECT Id,ZTS_EU_Employee__c,ZTS_Field_ForceID__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c=:callRecord.ZTS_EU_Account__c and ZTS_EU_Employee__c=:name AND ZTS_EU_Market__c = 'United States']; 
        if(accposlist!=null && accposlist.size()>0)
        {
            for (ZTS_EU_Account_Position__c acpo:accposlist)
            {
                forceidfields.add(acpo.ZTS_Field_ForceID__c);
            }    
            List<String> subTypeSecondValue = new List<String>(); 
            List<String> subTypeFirstValue = new List<String>(); 
            List<String> finalsubtypeValue = new List<String>();//Aritra added this final list of string to hold both the list from the Custom settings and finally do a "Sort"(SC-008047)
            List<ZTS_US_Call_CS__c> callcs = [Select Name,ZTS_US_Sub_Type_Value__c,ZTS_US_Sub_Type_Value_2__c from ZTS_US_Call_CS__c where Name=:forceidfields];
            
            if(callcs!=null && callcs.size()>0)
            {
                subTypeFirstValue = callcs[0].ZTS_US_Sub_Type_Value__c.split(';');
                finalsubtypeValue.addAll(subTypeFirstValue);
                if(callcs[0].ZTS_US_Sub_Type_Value_2__c!= null)
                {
                    subTypeSecondValue = callcs[0].ZTS_US_Sub_Type_Value_2__c.split(';');
                    finalsubtypeValue.addAll(subTypeSecondValue);
                }
                finalsubtypeValue.sort();//Vijay Vemuru asked to show the subtypes in sorted format (SC-008047)
                
                if(profileName == 'US Poultry Rep')
                {
                    Map<String,String> mapOfSubTypeNone = new Map<String,String>();         
                    mapOfSubTypeNone.put('value', '---NONE---');
                    mapOfSubTypeNone.put('label', '---NONE---');
                    
                    subTypeValuesMap.add(mapOfSubTypeNone);
                }
                
                for(String field : finalsubtypeValue)
                {  
                    Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();
                    
                    individualSubTypeValueToLabelMap.put('value', field);
                    individualSubTypeValueToLabelMap.put('label', field);
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap);
                }
                //Commented this part as the 2nd list is already added in final list.(SC-008047)
                /*for(String field : subTypeSecondValue)
{  
if(subTypeSecondValue!=null && subTypeSecondValue.size()>0)
{
Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();                       
individualSubTypeValueToLabelMap.put('value', field);
individualSubTypeValueToLabelMap.put('label', field);
subTypeValuesMap.add(individualSubTypeValueToLabelMap);
}
} */                 
            }
            else
            {
                Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();
                Map<String,String> individualSubTypeValueToLabelMap2 = new Map<String,String>();
                
                
                individualSubTypeValueToLabelMap.put('value', 'Account Call');
                individualSubTypeValueToLabelMap.put('label', 'Account Call');
                subTypeValuesMap.add(individualSubTypeValueToLabelMap);
                
                individualSubTypeValueToLabelMap2.put('value', 'Sample Drop');
                individualSubTypeValueToLabelMap2.put('label', 'Sample Drop');
                
                subTypeValuesMap.add(individualSubTypeValueToLabelMap2);
            }
        }
        else
        {
            List<ZTS_EU_Position__c> userTerritoryLst = new List<ZTS_EU_Position__c>();
            //Rahul TPDEV-2057-Start
            	userTerritoryLst = [Select Id, Name,ZTS_EU_Position__c.ZTS_EU_Territory__r.ZTS_FieldForce_ID__c  from ZTS_EU_Position__c where ZTS_EU_Employee__r.id=:userId];
            //Rahul TPDEV-2057-Start
		    Set<Id> terrIds = new Set<Id>();
            //Pooja TPDEV-1215 START
            if(userTerritoryLst.size() >0  && userTerritoryLst != null){
             for(ZTS_EU_Position__c userTerr : userTerritoryLst)
			{
			forceidfields.add(userTerr.ZTS_EU_Territory__r.ZTS_FieldForce_ID__c);
			}
            }else{
                list<user> userList = [SELECT ID, ZTS_US_FieldForce_ID__c FROM USER WHERE ID =:userId LIMIT 1];
                forceidfields.add(userlist[0].ZTS_US_FieldForce_ID__c);
            }//Pooja TPDEV-1215 END
            
            /* for(ZTS_EU_Position__c userTerr : userTerritoryLst) pooja commented out
{
forceidfields.add(userTerr.ZTS_EU_Territory__r.ZTS_FieldForce_ID__c);
}*/
            
            List<String> subTypeSecondValue = new List<String>();
            List<String> subTypeFirstValue = new List<String>(); 
            List<String> finalsubtypeValue = new List<String>();//Aritra added this final list of string to hold both the list from the Custom settings and finally do a "Sort"(SC-008047)
            List<ZTS_US_Call_CS__c> callcs = [Select Name,ZTS_US_Sub_Type_Value__c,ZTS_US_Sub_Type_Value_2__c from ZTS_US_Call_CS__c where Name=:forceidfields];

            if(callcs!=null && callcs.size()>0)
            {
                subTypeFirstValue = callcs[0].ZTS_US_Sub_Type_Value__c.split(';');
                finalsubtypeValue.addAll(subTypeFirstValue);
                if(callcs[0].ZTS_US_Sub_Type_Value_2__c!= null)
                {
                    subTypeSecondValue = callcs[0].ZTS_US_Sub_Type_Value_2__c.split(';');
                    finalsubtypeValue.addAll(subTypeSecondValue);
                }
                
                finalsubtypeValue.sort();//Vijay Vemuru asked to show the subtypes in sorted format (SC-008047)
                //DEF-0001577 for US Poultry Rep Users
                if(profileName == 'US Poultry Rep')
                {   
                    Map<String,String> mapOfSubTypeNone = new Map<String,String>();
                    
                    mapOfSubTypeNone.put('value', '---NONE---');
                    mapOfSubTypeNone.put('label', '---NONE---');
                    
                    subTypeValuesMap.add(mapOfSubTypeNone);
                }
                // EOC DEF-0001577 for US Poultry Rep Users*/
                for(String field : finalsubtypeValue)
                {   
                    Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();                       
                    individualSubTypeValueToLabelMap.put('value', field);
                    individualSubTypeValueToLabelMap.put('label', field);
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap);
                }
                //Commented this part as the 2nd list is already added in final list.(SC-008047)
                /*for(String field : subTypeSecondValue)
{  
if(subTypeSecondValue!=null && subTypeSecondValue.size()>0)
{
Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();                       
individualSubTypeValueToLabelMap.put('value', field);
individualSubTypeValueToLabelMap.put('label', field);
subTypeValuesMap.add(individualSubTypeValueToLabelMap);
}
}  */                    
            }
            else
            {
                //DEF-0001577 for US Poultry Rep Users
                if((profileName == 'US Poultry Rep')||(profileName == 'US Poultry Manager'))
                { 
                    Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();
                    Map<String,String> individualSubTypeValueToLabelMap2 = new Map<String,String>();
                    Map<String,String> individualSubTypeValueToLabelMap3 = new Map<String,String>();
                    Map<String,String> individualSubTypeValueToLabelMap4 = new Map<String,String>();
                    
                    //Aritra changed the subtype values for Poultry Reps as requested in SC-009094
                    individualSubTypeValueToLabelMap.put('value', 'Educational Call');
                    individualSubTypeValueToLabelMap.put('label', 'Educational Call');
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap);
                    
                    individualSubTypeValueToLabelMap2.put('value', 'Sales Call');
                    individualSubTypeValueToLabelMap2.put('label', 'Sales Call');
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap2);
                    
                    individualSubTypeValueToLabelMap3.put('value', 'Service Call');
                    individualSubTypeValueToLabelMap3.put('label', 'Service Call');
                    
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap3);
                    
                    individualSubTypeValueToLabelMap4.put('value', 'Sponsorship Call');
                    individualSubTypeValueToLabelMap4.put('label', 'Sponsorship Call');
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap4);
                    
                    
                    
                }
                
                else
                {
                    Map<String,String> individualSubTypeValueToLabelMap = new Map<String,String>();
                    Map<String,String> individualSubTypeValueToLabelMap2 = new Map<String,String>();
                    
                    
                    individualSubTypeValueToLabelMap.put('value', 'Account Call');
                    individualSubTypeValueToLabelMap.put('label', 'Account Call');
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap);
                    
                    individualSubTypeValueToLabelMap2.put('value', 'Sample Drop');
                    individualSubTypeValueToLabelMap2.put('label', 'Sample Drop');
                    
                    subTypeValuesMap.add(individualSubTypeValueToLabelMap2);
                }
                
            } 
        }
        
        return subTypeValuesMap;
        
    }
    
    @AuraEnabled(cacheable=true) 
    public static Boolean isInternationalUser(){
        User currentUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        return currentUser.ZTS_EU_Market__c != MARKET_CHECK;
    }
    //Aritra added this method to pull accountid from Opportunity(SC-008128)
    @AuraEnabled
    public static Id getAccountIdfromOppty(Id oppId){
        Opportunity opp = [Select AccountId from Opportunity where Id =: oppId LIMIT 1];
        return opp.AccountId;
        
    }
    //EOC - Aritra added this method to pull accountid from Opportunity(SC-008128)
    //Aritra added this method for SC-004726 to restrict new Contact creation option for Russia
    @AuraEnabled(cacheable=true) 
    public static Boolean isContactCreationRestrictedMarket(){
        User currentUser = [SELECT ZTS_EU_Market__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        if(currentUser.ZTS_EU_Market__c == CONTACT_CREATION_RESTRICTED_MKT_CHECK){
            return true;
        }
        else{
            return false;
        }
    }
    //SC-004726 - Created to pull task picklist field LOVs in native language (not possible to fetch by LWC UI API)
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTaskPriority ()
    {
        List<Map<String,String>> pickListValuesList= new List<Map<String,String>>();
        Schema.DescribeFieldResult fieldResult = Task.Priority.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map <String, String > values = new Map <String, String > {'label' => pickListVal.getLabel(),'value' => pickListVal.getValue()};
                pickListValuesList.add(values);
        }     
        return pickListValuesList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTaskStatus ()
    {
        List<Map<String,String>> pickListValuesList= new List<Map<String,String>>();
        Schema.DescribeFieldResult fieldResult = Task.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            Map <String, String > values = new Map <String, String > {'label' => pickListVal.getLabel(),'value' => pickListVal.getValue()};
                pickListValuesList.add(values);
        }     
        return pickListValuesList;
    }
    
    //Added the below method to save the call record by Imperative Apex Called from "US" Sales Call LWC Page (SC-008846)
    @AuraEnabled
    public static String createCallRecord(String callRecord, Boolean forceSave){
        String returnVal = 'ERROR';
        Call__c c = (Call__c)JSON.deserialize(callRecord, Call__c.class);
        Id callId;
        if(c.Id <> null){
            callId = Id.valueOf(c.Id);
        }
        else{callId = null;}
        Database.saveResult sr2;
        Database.DMLOptions dml =  new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = forceSave;
        try{
            if(callId <> null)
            {
                sr2 = Database.update(c, dml);
            }
            else
            {
                sr2 = Database.insert(c, dml);
            }
        }
        catch (DMLException dex) {
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                throw new AuraHandledException(dex.getDmlMessage(i));
            }
        }
        catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
            
        }
        if(sr2.isSuccess())
        {
            returnVal = c.Id;
        }
        return returnVal;
    }
    //This method is called on submit event of "US" Call Lightning Record Edit page.(SC-008846)
    //Purpose is to check the duplicate call
    //String in the parameter contains the field values for duplicate checking - activity date, account id, subtype, owner ids, list of attendees, discussions
    @AuraEnabled
    public static List<Call__c> lookForDuplicate(String dupeCheckDetails)
    {
        CallDuplicateCheckWrapper wrap = (CallDuplicateCheckWrapper)JSON.deserialize(dupeCheckDetails, CallDuplicateCheckWrapper.class);
        //Id callId = wrap.callId;
        List<Id> currCallRecId = new List<Id>();
        if(wrap.callId <> '')
        {
            currCallRecId.add(Id.valueOf(wrap.callId));
        }
        Id accId = wrap.accountId;
        String subtype = wrap.subtype;
        Datetime callStartDate = wrap.activityDate;
        Set<Id> newConIdSet;
        List<Id> finalConIdList = new list<Id>();
        List<Id> conIds = new List<Id>();
        List<Id> attIds = new List<Id>();
        List<Id> affIds = new List<Id>();
        if(wrap.contacts.size()>0)
        {
            conIds.addAll(pluckIdsFromWrapper(wrap.contacts));     
        }
        if(wrap.attendees.size()>0)
        {
            attIds.addAll(pluckIdsFromWrapper(wrap.attendees));
        }
        if(wrap.affiliations.size()>0)
        {
            affIds.addAll(pluckIdsFromWrapper(wrap.affiliations));
        }
        
        Set<String> newDiscussionNameSet = new Set<String>();
        //to fetch products associated to discussion items and campaigns
        if(wrap.discussionNames.size()>0)
        {
            for(LookupSearchResultWrapper dis : wrap.discussionNames)
            {
                if(dis.sObjectType == 'ZTS_EU_Discussion_Item__c')
                {
                    for(Discussion_Item_Product__c dip: [Select Product_Hierarchy__r.Name from Discussion_Item_Product__c where Discussion_Item__c = :dis.id])
                    {
                        newDiscussionNameSet.add(dip.Product_Hierarchy__r.Name);
                    }
                }
                else if(dis.sObjectType == 'Campaign')
                {
                    for(ZTS_EU_Campaign_Brand__c cb: [Select ZTS_EU_Product__r.Name from ZTS_EU_Campaign_Brand__c where ZTS_EU_Campaign__c = :dis.id])
                    {
                        newDiscussionNameSet.add(cb.ZTS_EU_Product__r.Name);
                    }
                }
                newDiscussionNameSet.add(dis.title);
            }
        }
        for(Attendee__c att: [Select ZTS_EU_Contact__c from Attendee__c where Id in :attIds])
        {
            finalConIdList.add(att.ZTS_EU_Contact__c);
        }
        for(ZTS_EU_Affiliations__c aff: [Select ZTS_EU_Contact__c from ZTS_EU_Affiliations__c where Id in :affIds])
        {
            finalConIdList.add(aff.ZTS_EU_Contact__c);
        }
        if(conIds.size()>0)
        {
            finalConIdList.addAll(conIds);
        }
        newConIdSet = new Set<Id>(finalConIdList); 
        List<Call__c> retCallList = new List<Call__c>();
        
        Map<Id,Call__c> mapMatchingCall = new Map<Id,Call__c>([Select Id, Name, ZTS_EU_Call_Objectives__c, ZTS_EU_Start_Date_Time__c, Account_name__c from Call__c 
                                                               where createdById = :UserInfo.getUserID() and ZTS_EU_Account__c = :accId and ZTS_EU_Sub_Type__c = :subtype 
                                                               and Id not in :currCallRecId and ZTS_EU_Start_Date_Time__c =:callStartDate]);
        if(mapMatchingCall.size()>0)
        {
            Set<String> setMatchingCallDisNames;
            Set<Id> setMatchingCallConIds;
            for(Id cId: mapMatchingCall.keyset())
            {
                setMatchingCallDisNames = new Set<String>();
                List<ZTS_EU_Discussion__c> lstDisMatchingCalls = [Select Name from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__r.ZTS_EU_call__c = :cId];
                for(ZTS_EU_Discussion__c d: lstDisMatchingCalls)
                {
                    setMatchingCallDisNames.add(d.Name);
                }
                setMatchingCallConIds = new Set<Id>();
                List<Attendee__c> lstAttMatchingCalls = [Select ZTS_EU_Contact__c from Attendee__c where ZTS_EU_call__c = :cId];
                for(Attendee__c a: lstAttMatchingCalls)
                {
                    setMatchingCallConIds.add(a.ZTS_EU_Contact__c);
                }
                Boolean disMatched;
                Boolean conMatched;
                if(setMatchingCallDisNames.size() == newDiscussionNameSet.size())
                {
                    if(setMatchingCallDisNames.size()>0)
                        disMatched = newDiscussionNameSet.containsAll(setMatchingCallDisNames);
                    else if(setMatchingCallDisNames.size() == 0)
                        disMatched = true;
                }
                if(setMatchingCallConIds.size() == newConIdSet.size())
                {
                    if(setMatchingCallConIds.size()>0)
                        conMatched = newConIdSet.containsAll(setMatchingCallConIds);
                    else if(setMatchingCallConIds.size() == 0)
                        conMatched = true;
                }
                if(disMatched == true && conMatched == true)
                {
                    retCallList.add(mapMatchingCall.get(cId));
                }
            }
            
        }
        
        return retCallList;
        
    }
    //This is a wrapper class used to hold the duplicate criteria field values for identifying matching calls for US
    Public class CallDuplicateCheckWrapper{
        @AuraEnabled public String callId {get;set;}
        @AuraEnabled public datetime activityDate {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String subtype {get;set;}
        @AuraEnabled public String ownerId {get;set;}
        @AuraEnabled public List<LookupSearchResultWrapper> attendees {get;set;}
        @AuraEnabled public List<LookupSearchResultWrapper> affiliations {get;set;}
        @AuraEnabled public List<LookupSearchResultWrapper> contacts {get;set;}
        @AuraEnabled public List<LookupSearchResultWrapper> discussionNames {get;set;}
        
        public CallDuplicateCheckWrapper() {
            this.attendees = new List<LookupSearchResultWrapper>();
            this.affiliations = new List<LookupSearchResultWrapper>();
            this.contacts = new List<LookupSearchResultWrapper>();
            this.discussionNames = new List<LookupSearchResultWrapper>();
        }
    }
    
    
}