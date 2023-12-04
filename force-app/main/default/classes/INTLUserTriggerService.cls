/****************************************************************************************************************************************** 
 * Trigger Name : INTLUserTriggerService
 * Description  : Service class to handle User trigger logic  
 * Created By   : Slalom(Mohamed Seliman) 
 * Created Date : 6th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Mohamed Seliman			02/06/2020		Moved from UserProcessD to Service Class, duplicated after update and after insert code for granularity
 * Mohamed Seliman			02/06/2020		Moved from ZTS_EU_Usertrigger to Service Class, duplicated after update and after insert code for granularity
 * 
 * @Name: ZTS_EU_Usertrigger 
 * @Desciption: Trigger on User.
                1. Populates the state Id on the user record if the appropriate state and country are added. Else gives an error.
 * Author: CloudSense (Shreyas) 
 * @Date: 30th-Sep-2014

	Modification Log
    ----------------
    Date             Developer                Comments  
    ---------------------------------------------------------------------------------------
    13-Feb-2017     Aritra(Cognizant)        Added logic to create TOT for holiday records automatically when a new user joins on after insert event. (as a part of SC-002868)

*****************************************************************************************************************************************/
public class INTLUserTriggerService 
{
    public static void beforeUpdate(List<User> triggerOld, Map<Id, User> triggerOldMap, List<User> triggerNew, Map<Id, User> triggerNewMap) 
    {
        List<User> userList= new List<User>();

        // added by Akshay As part of LIGHTNI-1736
        new SL_UserTriggerHandler().onBeforeUpdate(triggerNewMap, triggerOldMap);

        for(User u: triggerNew){
            if((u.state != triggerOldMap.get(u.id).state) || (u.Default_Country__c != triggerOldMap.get(u.id).Default_Country__c) ){
                userList.add(u);
            }
        }
        ZTS_EU_UserUtility.populateStateId(userList);
        
    }

    public static void beforeInsert(List<User> triggerNew)
    {
        List<User> userList= new List<User>();

        // added by Akshay As part of LIGHTNI-1736
        new SL_UserTriggerHandler().onBeforeInsert(triggerNew);
        
        for(User u: triggerNew)
        {
            userList.add(u);
        }
        ZTS_EU_UserUtility.populateStateId(userList);

    }

    public static void afterUpdate(List<User> triggerOld, Map<Id, User> triggerOldMap, List<User> triggerNew, Map<Id, User> triggerNewMap)
    {
        /*List<User> UserList = triggerNew;
        List<Profile> ProfileList = [select Id, Name from Profile Where Name Like '%Partner%'];
        SET<Id> ProfileSetId = new SET<Id>();
        if(!ProfileList.isEmpty()){
            for(Profile pr:ProfileList){
                ProfileSetId.add(pr.Id);
            }
            
            Id UserId;  
            Boolean checkF = false;  
            for(User u:UserList){
                if(u.IsActive){  	
                    if(String.ValueOf(u.LastName).contains('$')){	        	
                        system.debug('str 17a' + ProfileSetId);   
                        system.debug('str 17b' + u.ProfileId);  
                        
                        if(ProfileSetId.contains(u.ProfileId)){
                            system.debug('str 21');           	
                            if(Boolean.valueOf(u.get('IsPortalEnabled'))){
                                system.debug('str 23');                
                                checkF = true;
                                UserId = u.Id;          
                            }
                        }              
                    }        
                }
                
            }
            if(checkF){
                TriggerHelperD.updatePartnerUser(UserId); 
            }
            
        }*/
        
         List <Excluded_Profiles_for_Auto_TOT__c> Profs = Excluded_Profiles_for_Auto_TOT__c.getall().values();
        Map <Id,String> mapUserId = new Map <Id,String> ();
        Set <String> setProfs =new Set <String> ();
        
        for(Excluded_Profiles_for_Auto_TOT__c customvalues:Profs){
            setProfs.add(customvalues.Profile_Id__c);
        }   
        
        Map<Id, List<Time_Out_of_Territory__c>> userTotMap = new Map<Id, List<Time_Out_of_Territory__c>>();
        userTotMap = ZTS_EU_UserUtility.fetchUserTotRecords(triggerNew);
       
        
        for(user u : triggerNew){
            if (u.IsActive == true && !setProfs.contains(u.ProfileId)){
                List<Time_Out_of_Territory__c> totList = userTotMap.get(u.Id);
                if(totList == null){
                    mapUserId.put(u.Id, u.ZTS_EU_Market__c); 
                }
                
            }
        }
             if(mapUserId != null && mapUserId.size() > 0 && !System.isBatch()){
                     ZTS_EU_UserUtility.createTotforHoliday(mapUserId);
                }


    }
    
    public static void afterInsert(List<User> triggerNew, Map<Id, User> triggerNewMap)
    {
        /*List<User> UserList = triggerNew;
        List<Profile> ProfileList = [select Id, Name from Profile Where Name Like '%Partner%'];
        SET<Id> ProfileSetId = new SET<Id>();
        if(!ProfileList.isEmpty()){
            for(Profile pr:ProfileList){
                ProfileSetId.add(pr.Id);
            }
            
            Id UserId;  
            Boolean checkF = false;  
            for(User u:UserList){
                if(u.IsActive){  	
                    if(String.ValueOf(u.LastName).contains('$')){	        	
                        system.debug('str 17a' + ProfileSetId);   
                        system.debug('str 17b' + u.ProfileId);  
                        
                        if(ProfileSetId.contains(u.ProfileId)){
                            system.debug('str 21');           	
                            if(Boolean.valueOf(u.get('IsPortalEnabled'))){
                                system.debug('str 23');                
                                checkF = true;
                                UserId = u.Id;          
                            }
                        }              
                    }        
                }
                
            }
            if(checkF){
                TriggerHelperD.updatePartnerUser(UserId); 
            }
            
        }*/
        //Added this part to create TOT for holiday records automatically when a new user record inserted.
        List <Excluded_Profiles_for_Auto_TOT__c> Profs = Excluded_Profiles_for_Auto_TOT__c.getall().values();
        Map <Id,String> mapUserId = new Map <Id,String> ();
        Set <String> setProfs =new Set <String> ();
        
        for(Excluded_Profiles_for_Auto_TOT__c customvalues:Profs){
            setProfs.add(customvalues.Profile_Id__c);
        }
        for(User u: triggerNew){
            if (u.IsActive == true && !setProfs.contains(u.ProfileId))
            { 
                mapUserId.put(u.Id, u.ZTS_EU_Market__c); 
            }
        }
        ZTS_EU_UserUtility.createTotforHoliday(mapUserId);        
	}
}