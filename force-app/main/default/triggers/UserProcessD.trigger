trigger UserProcessD on User (after insert, after update, before insert, 
before update) {
   
    
   if(Trigger.isAfter &&  (Trigger.isUpdate||Trigger.isInsert) ){  
    List<User> UserList = Trigger.new;
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
    
   }
  } 
    
}