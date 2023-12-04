/**
* @ClassName    : SL_UserTriggerHandler 
* @JIRATicket   : LIGHTNI-1736
* @CreatedOn    : 19th Nov 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : 
* @Description  : User trigger handler class.
******************************************************************************************************************************
Modification Log:
******************************************************************************************************************************
Author					Date					Comments
------------------------------------------------------------------------------------
Aritra(Cognizant)       25-Aug-2021				Added a null checking in 'onBeforeUpdate' method(SC-008886)
Prasun(Cognizant)		01-Jan-2023				Added eventPermissionUpdate method to assign permission set based on role to customize events
Yadagiri(Cognizant)     03-Mar-2023             Added addUser and updateUser method to add users to Public groups.
******************************************************************************************************************************
*/
public class SL_UserTriggerHandler {
	
    /***********
    * Method name  : onBeforeInsert
    * Description  : This method get called on before insert event.
    * Return Type  : NA
    * Parameters   : List<User> lstNewUsers
    ***********/
    public void onBeforeInsert(List<User> lstNewUsers) {
        FillAdditionalMarketTextAreaFields(lstNewUsers);
    }
    
    /***********
    * Method name  : onBeforeUpdate
    * Description  : This method get called on before update event.
    * Return Type  : NA
    * Parameters   : Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers
    ***********/
    public void onBeforeUpdate(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers) {
        List<User> lstUsers = new List<User>();
        for(User usr : mapNewUsers.values()) {
            if(mapOldUsers!= null) //Aritra added this criteria for null checking to stop null pointer exception during bulk user load from Workday (SC-008918)
            { 
                if((mapOldUsers.get(usr.Id)) != null) //Added as part of TPDEV-1715
                {
                  if(usr.Additional_Markets__c!= null)//Aritra added this criteria for null value checking in additional market field (SC-008886)
                  {
                    if(usr.Additional_Markets__c != mapOldUsers.get(usr.Id).Additional_Markets__c)
                        lstUsers.add(usr);
                  }
                }
           }
        }
        FillAdditionalMarketTextAreaFields(lstUsers);
    }
    
    /***********
    * Method name  : FillAdditionalMarketTextAreaFields
    * Description  : This method stamp the additional market field value into additional market text 1/2/3 fields.
    * Return Type  : NA
    * Parameters   : List<User> lstUsers
    ***********/
    private void FillAdditionalMarketTextAreaFields(List<User> lstUsers) {
        
        for(User usr : lstUsers) {
            usr.Additional_Markets_Text_1__c = '';
            usr.Additional_Markets_Text_2__c = '';
            usr.Additional_Markets_Text_3__c = '';
            String markets = String.isNotBlank(usr.Additional_Markets__c) ? usr.Additional_Markets__c : '';
            if(markets.length() <= 255) {
                usr.Additional_Markets_Text_1__c = markets.replaceAll(';', ' ');
            }else {
                Integer i = Markets.LastIndexOf(';', 255);
                usr.Additional_Markets_Text_1__c = Markets.substring(0, i).replaceAll(';', ' ');
                String market2 = Markets.substring(i+1);
                if(market2.length() <= 255) {
                    usr.Additional_Markets_Text_2__c = market2.replaceAll(';', ' ');
                }else {
                    i = market2.LastIndexOf(';', 255);
                    usr.Additional_Markets_Text_2__c = market2.substring(0, i).replaceAll(';', ' ');
                    usr.Additional_Markets_Text_3__c = market2.substring(i+1).replaceAll(';', ' ');
                    
                }
            }
        }
    }
    
    /**********
     * Method Name	: onAfterUpdate
     * Description	: Method will run after data in committed on update
     * Return Type	: void
     * Parameters	: Map<Id,User> oldUserMap, Map<Id,User> newUserMap
     * ***********/
    
    public void eventPermissionUpdate(Map<Id, User> mapNewUsers, Map<Id, User> mapOldUsers){
        Map<Id,List<User>> permissionToAdd = new Map<Id,List<User>>();
        Map<Id,List<User>> permissionToRemove = new Map<Id,List<User>>();
        Set<Id> roleSet = new Set<Id>();
        Map<Id,String> roleToIdMap = new Map<Id,String>();
        Map<String,String> roleToSpeciesMap = new Map<String,String>();
        Map<String,Id> permissionSetMap = new Map<String,Id>();
        
        Set<Id> usersWithPermissionGroupSet = new Set<Id>();
        Map<Id,Id> userToGroupPermissionMap = new Map<Id,Id>();
        Map<Id,Set<Id>> usersWithPermissionSetMap = New Map<Id,Set<Id>>();
        Map<Id,Set<String>> usersWithPermissionSetIdMap = New Map<Id,Set<String>>();
        
        for(Id userId : mapNewUsers.keySet()){
            if((mapNewUsers.get(userId).UserRoleId <> null && mapOldUsers.get(userId) == null) || (mapNewUsers.get(userId).UserRoleId <> null && mapOldUsers.get(userId).UserRoleId <> null
               && mapNewUsers.get(userId).UserRoleId <> mapOldUsers.get(userId).UserRoleId)){
                   if(mapNewUsers.get(userId).UserRoleId <> null){
                       if(permissionToAdd.containsKey(mapNewUsers.get(userId).UserRoleId))
                           permissionToAdd.get(mapNewUsers.get(userId).UserRoleId).add(mapNewUsers.get(userId));
                       else
                           permissionToAdd.put(mapNewUsers.get(userId).UserRoleId,new List<User>{mapNewUsers.get(userId)});
                   }
                   if(mapOldUsers.get(userId) <> null && mapOldUsers.get(userId).UserRoleId <> null){
                       if(permissionToRemove.containsKey(mapOldUsers.get(userId).UserRoleId))
                           permissionToRemove.get(mapOldUsers.get(userId).UserRoleId).add(mapOldUsers.get(userId));
                       else
                           permissionToRemove.put(mapOldUsers.get(userId).UserRoleId,new List<User>{mapOldUsers.get(userId)});
                   }
               }
        }
        
        if(!permissionToAdd.isEmpty() || !permissionToRemove.isEmpty() ){
            roleSet.addAll(permissionToAdd.keySet());
            roleSet.addAll(permissionToRemove.keySet());
            
            List<UserRole> roleList = new List<UserRole>();
            roleList = [Select Id,Name From UserRole Where Id in: roleSet];
            
            for(UserRole ur: roleList){
                roleToIdMap.put(ur.Id,ur.Name);
            }
            
            // Getting permission set required as per user's role.
            List<Role_2_Species_Mapping__mdt> roleToSpeciesList = new List<Role_2_Species_Mapping__mdt>();
            roleToSpeciesList = [Select Role__c,FieldForce__c From Role_2_Species_Mapping__mdt Where Market__c = 'United States'];
            Set<String> permissionSetNames = new Set<String>();
            for(Role_2_Species_Mapping__mdt mdt: roleToSpeciesList){
                roleToSpeciesMap.put(mdt.Role__c, mdt.FieldForce__c);
                if(mdt.FieldForce__c != null && mdt.FieldForce__c != 'All')
                	permissionSetNames.add('Event_'+ mdt.FieldForce__c.replaceAll(' ', '_'));
            }
            
            for(PermissionSet ps: [Select Id,Name From PermissionSet Where Name In: permissionSetNames]){
                permissionSetMap.put(ps.Name,ps.Id);
            }
            
            PermissionSetGroup allPermission = [Select Id From PermissionSetGroup Where DeveloperName = 'Event_permissions' limit 1];
        
        	List<PermissionSetAssignment> usersWithPermissionGroupList = [Select AssigneeId,Id From PermissionSetAssignment Where PermissionSetGroupId =: allPermission.Id AND AssigneeId in: mapNewUsers.KeySet()];
        	List<PermissionSetAssignment> usersWithPermissionSetList = [Select AssigneeId,PermissionSetId,Id From PermissionSetAssignment Where PermissionSetId in: permissionSetMap.values() AND AssigneeId in: mapNewUsers.KeySet()];
            
            //Checking already assigned permission set
            for(PermissionSetAssignment psa: usersWithPermissionSetList){
                if(usersWithPermissionSetMap.containsKey(psa.AssigneeId)){
                    usersWithPermissionSetMap.get(psa.AssigneeId).add(psa.PermissionSetId);
                    usersWithPermissionSetIdMap.get(psa.AssigneeId).add(psa.PermissionSetId+'+'+psa.Id);
                }else{
                    usersWithPermissionSetMap.put(psa.AssigneeId, new Set<Id>{psa.PermissionSetId});
                    usersWithPermissionSetIdMap.put(psa.AssigneeId, new Set<String>{psa.PermissionSetId+'_'+psa.Id});
                }
            }
            //Checking already assigned permission group
            for(PermissionSetAssignment psa: usersWithPermissionGroupList){
            	usersWithPermissionGroupSet.add(psa.AssigneeId);
                userToGroupPermissionMap.put(psa.AssigneeId,psa.Id);
            }
            
            List<PermissionSetAssignment> psaToAdd = new List<PermissionSetAssignment>();
            
            for(Id roleId: permissionToAdd.keySet()){
                if(roleToSpeciesMap.containsKey(roleToIdMap.get(roleId))){
                    String fieldForce = roleToSpeciesMap.get(roleToIdMap.get(roleId));
                    for(User u: permissionToAdd.get(roleId)){
                        // Check to verify if permission set or permission group is already present
                        system.debug('___'+ usersWithPermissionGroupSet);
                        system.debug('+++++++++'+ JSON.serialize(usersWithPermissionSetMap));
                        If((fieldForce == 'All' && !usersWithPermissionGroupSet.contains(u.Id)) || (fieldForce != 'All' && !usersWithPermissionSetMap.containsKey(u.Id)) || 
                           			(fieldForce != 'All' && usersWithPermissionSetMap.containsKey(u.Id) && !usersWithPermissionSetMap.get(u.Id).contains(permissionSetMap.get('Event_'+ fieldForce.replaceAll(' ', '_'))))){
                            PermissionSetAssignment psa = new PermissionSetAssignment();
                            psa.AssigneeId = u.Id;
                            if( fieldForce != 'All')
                                psa.PermissionSetId = permissionSetMap.get('Event_'+ fieldForce.replaceAll(' ', '_'));
                            else
                                psa.PermissionSetGroupId = allPermission.Id;
                            psaToAdd.add(psa);
                        }
                    }
                }
            }
               
            Set<Id> userWithAllPermission = new Set<Id>();
            Set<Id> userIdSet = new Set<Id>();
            Set<Id> permissionIdSet = new Set<Id>();
            List<Id> permissionSetToRemove = new List<Id>();
            
            for(Id roleId: permissionToRemove.keySet()){
                if(roleToSpeciesMap.containsKey(roleToIdMap.get(roleId))){
                    String fieldForce = roleToSpeciesMap.get(roleToIdMap.get(roleId));
                    for(User u: permissionToRemove.get(roleId)){
                        if(fieldForce == 'All' && userToGroupPermissionMap.containsKey(u.Id)){
                            permissionSetToRemove.add(userToGroupPermissionMap.get(u.Id));
                        }else{
                            if(usersWithPermissionSetIdMap.containsKey(u.Id)){
                                Set<String> strlist = usersWithPermissionSetIdMap.get(u.Id);
                                for(String str :strlist){
                                    List<String> permissionSetArr = str.split('_');
                                    if(permissionSetArr[0] == permissionSetMap.get('Event_'+ fieldForce.replaceAll(' ', '_'))){
                                        permissionSetToRemove.add(permissionSetArr[1]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            try{
                if( permissionSetToRemove.size() > 0 )
                	Database.delete(permissionSetToRemove);
                
                if(psaToAdd != null && psaToAdd.size() > 0){
                    insert psaToAdd;
                }
            }catch(Exception ex){
                system.debug('Exception: '+ ex.getMessage());
            }
        }
    }
    
     /***********
    * Method name  : addUser
    * Description  : This method used to add users to Public group.
    * Return Type  : NA
    * Parameters   : list<User> user
    ***********/
    
    public  void addUser(list<User> userList){
        List<GroupMember> listGroupMember =new List<GroupMember>();
        list<Group> grouplist = new list<Group>();
        Map<String,Id> groupMap = new Map<String,Id>();
        Map<Id,String> userGroupMap = new Map<Id,String>();
        for(User u : userList){
            String sharingbusinessunit = u.Sharing_Business_Unit__c; 
            if(!String.isBlank(sharingbusinessunit)){
                String groupname = label.Sharing_Business_Unit+sharingbusinessunit;
                userGroupMap.put(u.id,groupname);
            }
        }
        if(userGroupMap.size()>0){ 
            grouplist = [select id,name from Group where Name=:userGroupMap.values() and type='regular'];
            for(Group grp: grouplist){
                groupMap.put(grp.Name,grp.Id);
            }
        }
        if(grouplist !=null){
            for(User u : userList){
                GroupMember gm= new GroupMember(); 
                gm.GroupId = groupMap.get(label.Sharing_Business_Unit+u.Sharing_Business_Unit__c);
                gm.UserOrGroupId = u.id;
                listGroupMember.add(gm);
            }
        }
        try{
            insert listGroupMember;
        }catch(DmlException ex){
            ex.getMessage();
        }
        
    }
    
      /***********
    * Method name  : updateUser
    * Description  : This method used to update users to Public group.
    * Return Type  : NA
    * Parameters   : list<User> oldlist,list<User> newlist
    ***********/
    
   public void updateUser(list<User> oldlist, list<User> newlist) {

    List<GroupMember> listGroupMember = new List<GroupMember>();
    List<GroupMember> listGroupMemberdelete = new List<GroupMember>();
    Map<Id, String> oldsharingBusinessunitmap = new Map<Id, String>();
    Map<Id, User> oldusermap = new Map<Id, User>(oldlist);

  
       for(user newu : newlist){
           if((oldusermap.get(newu.id)) != null ){ 		//Added as part of TPDEV-1715
            if((oldusermap.get(newu.id).Sharing_Business_Unit__c != newu.Sharing_Business_Unit__c) && 
               oldusermap.get(newu.id).Sharing_Business_Unit__c !='Other'){ 
                   oldsharingBusinessunitmap.put(newu.id,label.Sharing_Business_Unit+oldusermap.get(newu.id).Sharing_Business_Unit__c);
                   
                }
          }
      }
        if(oldsharingBusinessunitmap.size()>0 ){
            listGroupMember = [select Id,Group.name,UserOrGroupId from GroupMember where  Group.name in: oldsharingBusinessunitmap.values() and UserOrGroupId in: oldsharingBusinessunitmap.keyset()];
            for(GroupMember groupmember : listGroupMember){
                if(oldsharingBusinessunitmap.containskey(groupmember.UserOrGroupId) && 
                   groupmember.Group.name == oldsharingBusinessunitmap.get(groupmember.UserOrGroupId) ){
                       listGroupMemberdelete.add(groupmember);
                   }
            }
        }
        
        try{
            if(!listGroupMemberdelete.isempty()){
                delete listGroupMemberdelete;  
            }
            
        }catch(DmlException ex){
            ex.getMessage();
        }
        
        adduser(newlist);
    }
}