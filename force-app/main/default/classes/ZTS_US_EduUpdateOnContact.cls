/*************************************************************************************************************************
  Class Name     : ZTS_US_EduUpdateOnContact
  Description    : This class is called from trigger on ZTS_US_AccountUpdatefromEducation to Update Education fields on Contact
                   whenever the fields are modified on Education record.
  Created By     : Akanksha Gupta
  Created On     : 03/24/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Akanksha Gupta                      03/24/2014              Created


***************************************************************************************************************************/
public class ZTS_US_EduUpdateOnContact
{
       /***********
        * Method name  : updateConOnEduCreation
        * Description  : This will update Education fields on Contact record on creation of Education record.
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
        
           
    public static void updateConOnEduCreation(List<ZTS_US_Education_Background__c> triggerNew,Map<Id,ZTS_US_Education_Background__c> eduNewMap)
    {
        Set<Id> setConId = new Set<Id>();
        Map<Id,Id> mapConIdEduId = new Map<Id,Id>();
        List<Contact> listConToUpdate = new List<Contact>();
       
        for(ZTS_US_Education_Background__c edu: triggerNew)
        {
            // if Education Record is created then update corresponding Education fields on Contact record.
             if(edu.ZTS_US_Type__c == 'DVM'){
                setConId.add(edu.ZTS_US_Contact__c);
                mapConIdEduId.put(edu.ZTS_US_Contact__c,edu.Id);
            }
         
         }         
            List<Contact> lstCon = [Select a.ZTS_US_Institution__c, a.ZTS_US_DVM_Year__c,a.Id From Contact a
                                    where a.Id in :setConId AND ZTS_EU_Market__c = 'United States'];
            for(Contact con: lstCon ){
               con.ZTS_US_Institution__c = eduNewMap.get(mapConIdEduId.get(con.id)).ZTS_US_Institution__c;    
               con.ZTS_US_DVM_Year__c = eduNewMap.get(mapConIdEduId.get(con.id)).ZTS_US_DVM_Year__c;      
               listConToUpdate.add(con);
            } 
        
        
        // Updating Contact record list.
        if(listConToUpdate.size()>0){
            try{ 
                // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
				List<Database.SaveResult> sr = Database.update(listConToUpdate,dml);
                //Database.update(listConToUpdate);-- commented for SC-008149
            }catch(Exception e){
                system.debug('Exception*******>'+e);
            }
        }    
     }
     /***********
        * Method name  : updateConOnEduModification
        * Description  : This will update Contact fields when Education record is updated .
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
     
     public static void updateConOnEduModification(List<ZTS_US_Education_Background__c> triggerNew,Map<ID,ZTS_US_Education_Background__c> triggerOldMap,Map<ID,ZTS_US_Education_Background__c> triggerNewMap){
     Set<Id> setConId = new Set<Id>();
     Map<Id,Id> mapConIdEduId = new Map<Id,Id>();
     List<Contact> listConToUpdate = new List<Contact>();
       //if education record is updated, updated the corresponding Contact record with updates. 
         for(ZTS_US_Education_Background__c edu: triggerNew){
            if((edu.ZTS_US_Institution__c != triggerOldMap.get(edu.id).ZTS_US_Institution__c )||(edu.ZTS_US_DVM_Year__c != triggerOldMap.get(edu.id).ZTS_US_DVM_Year__c )){
                     setConId.add(edu.ZTS_US_Contact__c);
                     mapConIdEduId.put(edu.ZTS_US_Contact__c,edu.Id);
             }
         }
         List<Contact> lstCon = [Select a.ZTS_US_Institution__c, a.ZTS_US_DVM_Year__c,a.Id From Contact a
                                    where a.Id in :setConId AND ZTS_EU_Market__c = 'United States'];
                                 
         for(Contact con: lstCon){
               con.ZTS_US_Institution__c = triggerNewMap.get(mapConIdEduId.get(con.id)).ZTS_US_Institution__c;    
               con.ZTS_US_DVM_Year__c = triggerNewMap.get(mapConIdEduId.get(con.id)).ZTS_US_DVM_Year__c;  
               listConToUpdate.add(con);
            } 
         
         try{ 
             //chkUpdate = false;
             // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
				List<Database.SaveResult> sr = Database.update(listConToUpdate,dml);
                //Database.update(listConToUpdate);-- commented for SC-008149
        }
        catch(Exception e){
            system.debug('Exception*******>'+e);
        } 
        
         //Database.update(listConToUpdate);                           
     }
     /***********
        * Method name  : updateConOnEduDeletion
        * Description  : This will update Education fields on Contact when Education record is deleted.
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
     public static void updateConOnEduDeletion(List<ZTS_US_Education_Background__c> triggerNew,Map<Id,ZTS_US_Education_Background__c> eduNewMap)
    {
        Set<Id> setConId = new Set<Id>();
        Map<Id,Id> mapConIdEduId = new Map<Id,Id>();
        List<Contact> listConToUpdate = new List<Contact>();
       
        for(ZTS_US_Education_Background__c edu: triggerNew)
        {
            // if Education Record is created then update corresponding Education fields on Contact record.
             if(edu.ZTS_US_Type__c == 'DVM'){
                setConId.add(edu.ZTS_US_Contact__c);
                mapConIdEduId.put(edu.ZTS_US_Contact__c,edu.Id);
            }
         
                  
            
        }
        List<Contact> lstCon = [Select a.ZTS_US_Institution__c, a.ZTS_US_DVM_Year__c,a.Id From Contact a
                                    where a.Id in :setConId AND ZTS_EU_Market__c = 'United States'];
            for(Contact con: lstCon ){
               con.ZTS_US_Institution__c = '';    
               con.ZTS_US_DVM_Year__c = '';      
               listConToUpdate.add(con);
            } 
        
        // Updating Contact record list.
        if(listConToUpdate.size()>0){
            try{ 
                 // Added below lines to bypass contact duplicate rules for US Contacts (SC-008149)
 				Database.DMLOptions dml = new Database.DMLOptions(); 
 				dml.DuplicateRuleHeader.allowSave = true;
 				dml.DuplicateRuleHeader.runAsCurrentUser = true;
				List<Database.SaveResult> sr = Database.update(listConToUpdate,dml);
                //Database.update(listConToUpdate);-- commented for SC-008149
            }catch(Exception e){
                system.debug('Exception*******>'+e);
            }
        }    
     }  
}