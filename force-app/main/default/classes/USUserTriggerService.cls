/****************************************************************************************************************************************** 
 * Trigger Name : USUserTriggerService
 * Description  : Service class to handle User trigger logic  
 * Created By   : Slalom(David Stern) 
 * Created Date : 12th August, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern			08/12/2020		Copied code from INTL User Trigger Service here.
 * Aritra (Cognizant)   02/09/2021      Added null checking in before update method to stop null pointer exception during Bulk API user load (SC-008918)
*****************************************************************************************************************************************/
public class USUserTriggerService 
{
    public static void beforeUpdate(List<User> triggerOld, Map<Id, User> triggerOldMap, List<User> triggerNew, Map<Id, User> triggerNewMap) 
    {
        List<User> userList= new List<User>();

        // added by Akshay As part of LIGHTNI-1736
        new SL_UserTriggerHandler().onBeforeUpdate(triggerNewMap, triggerOldMap);

        for(User u: triggerNew){
            if(triggerOldMap!= null) //Aritra added this criteria for null checking to stop null pointer exception during Bulk API user load from Workday (SC-008918)
            {
                if((u.state!=null) && (u.Default_Country__c!=null)) {
                    if((u.state != triggerOldMap.get(u.id).state) || (u.Default_Country__c != triggerOldMap.get(u.id).Default_Country__c) ){
                        userList.add(u);
                    }
                }
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
        
        SL_UserTriggerHandler handler = new SL_UserTriggerHandler();
        handler.eventPermissionUpdate(triggerNewMap, triggerOldMap);
        
        // Added below method to update users in public group by Yadagiri for SC-010236
        handler.updateUser(triggerOld,triggerNew);
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
        
        SL_UserTriggerHandler handler = new SL_UserTriggerHandler();
        handler.eventPermissionUpdate(triggerNewMap, new Map<Id,User>());
        
         // Added below method to add users in public group by Yadagiri for SC-010236
        handler.addUser(triggerNew);
	}
}