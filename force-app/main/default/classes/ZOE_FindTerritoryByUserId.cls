/*************************************************************************************
* Name          :    ZOE_FindTerritoryByUserId .
* Description   :    Helper Class
* Author        :    Vinay

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
6/03/2014       Vinay Bhatia              Created


**************************************************************************************/


public with sharing class ZOE_FindTerritoryByUserId {
    
    @testVisible static final String USER_TERR_QUERY_ORIGIN_TYPE = 'ZOE_FindTerritoryByUserId - findTerritoriesForUserId: query for user territory';
    @testVisible static final String GROUP_ACCOUNTSHARE_QUERY_ORIGIN_TYPE = 'ZOE_FindTerritoryByUserId - getAllSubChildTerritoryIds: query for group or account share';

    // Find Territories by User Id
    public static Set<Id> findTerritoriesForUserId(Id userId, Boolean allChildTerritories)
    {
        Set<Id> territoriesSet=new Set<Id>();
        Set<Id> finalSetTerritories=new Set<Id>();
        List<UserTerritory2Association> userTerritoryList=new List<UserTerritory2Association>();

        try{
            userTerritoryList=[SELECT Id,Territory2Id,UserId FROM UserTerritory2Association WHERE UserId = :userId AND IsActive = true ]; 
        }
        catch(QueryException qex){
            System.debug(USER_TERR_QUERY_ORIGIN_TYPE);
            System.debug('Query Exception Message: ' + qex.getMessage());
            String errorMessages = qex.getMessage();
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, USER_TERR_QUERY_ORIGIN_TYPE);
        }
        
        if(!userTerritoryList.IsEmpty())
        {
            
            for(UserTerritory2Association tempUserTerritory:userTerritoryList)
            { 
                territoriesSet.add(tempUserTerritory.territory2Id);
            }
            
            if(!territoriesSet.IsEmpty())
            {
                // Find Lower Territory Management 
                for(Id territory2Id:territoriesSet)
                { 
                    finalSetTerritories.add(territory2Id);
                    
                    // Call class to find lower Management.
                    if(allChildTerritories) 
                    {  
                        Set<Id> allSubRoleIds = getAllSubChildTerritoryIds(new Set<ID>{territory2Id});  
                        
                        if(!allSubRoleIds.IsEmpty()) {
                            finalSetTerritories.addAll(allSubRoleIds);
                        }
                    }                                  
                }
            }
            
        }

        return finalSetTerritories;
    }
    public static Set<ID> getAllSubChildTerritoryIds(Set<ID> roleIds) {
        
        Set<ID> currentRoleIds = new Set<ID>();
        
        List<Territory2> lstTerritory = [SELECT AccountAccessLevel,DeveloperName,Id,Name FROM Territory2 
                                         WHERE ParentTerritory2Id IN :roleIds AND ParentTerritory2Id != null];

        // get all of the roles underneath the passed roles
        for(Territory2 userRole : lstTerritory)  
        currentRoleIds.add(userRole.Id);
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubChildTerritoryIds(currentRoleIds));
        }
        
        return currentRoleIds;
    }
    
    public static set<Id> getAllAccountsByTerritory(Set<Id> territoryIdSet, Id userId)
    {
        List<Group> groupMap = new List<Group>();
        List<Account> accountsList=new List<Account>();
        List<AccountShare> accountShareList=new List<AccountShare>();
        Set<Id> accountIds=new Set<Id>();
        try{
            groupMap=[SELECT Id, RelatedId FROM Group WHERE Type = 'Territory' AND RelatedId IN :territoryIdSet];
            accountShareList = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare 
                                WHERE ( UserOrGroupId IN :groupMap OR  UserOrGroupId = :userId ) AND RowCause IN ('Territory', 'TerritoryManual', 'TerritoryRule')]; 
        }
        catch(QueryException qex){
            System.debug(GROUP_ACCOUNTSHARE_QUERY_ORIGIN_TYPE);
            System.debug('Query Exception Message: ' + qex.getMessage());
            String errorMessage = qex.getMessage();
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessage,null, GROUP_ACCOUNTSHARE_QUERY_ORIGIN_TYPE);
        }
        
        if(!accountShareList.IsEmpty())
        {
            for(AccountShare accShareTemp:accountShareList){
                accountIds.add(accShareTemp.AccountId);
            }
        }

        return accountIds;
    }
    
}