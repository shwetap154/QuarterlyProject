/*************************************************************************************************************************
  Class Name     : ZTS_US_educationCreationAndUpdateFromContact
  Description    : This class is called from trigger on Contact for creation of Education record.
  Created By     : Akanksha Gupta
  Created On     : 03/24/2014
 
  Modification Log    :
--------------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
   Akanksha Gupta                      03/24/2014              Created
   Mayank Agarwal                      03/25/2014              Modified (added method updateAccConAffInactive)
***************************************************************************************************************************/
public class ZTS_US_EduCreationAndUpdateFromContact
{
       /***********
        * Method name  : createEducationRecord
        * Description  : This will create Education record on creation of Contact.
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
        
        static boolean chkUpdate = true;
        
    public static void createEducationRecord(List<Contact> triggerNew)
    {
        List<ZTS_US_Education_Background__c> listEdu = new List<ZTS_US_Education_Background__c>();
        
        Set<Id>conId=new Set<Id>();
        for(Contact con:triggerNew){
        conId.add(con.Id);
        }
        
        List<ZTS_US_Education_Background__c> dvmeduList=[Select Id,ZTS_US_Institution__c,ZTS_US_DVM_Year__c,ZTS_US_Type__c from ZTS_US_Education_Background__c where ZTS_US_Type__c='DVM' and ZTS_US_Contact__c in:conId];
        
        for(Contact Con: triggerNew){        
           // if Education fields Entered on Contact are not null or education records with type DVM already not there then create corresponding Education record.
            if((Con.ZTS_US_Institution__c != Null || Con.ZTS_US_DVM_Year__c != Null ) && (dvmeduList==null || dvmeduList.size()==0)){
                ZTS_US_Education_Background__c edu = new ZTS_US_Education_Background__c();
                edu.ZTS_US_Institution__c=Con.ZTS_US_Institution__c;
                edu.ZTS_US_DVM_Year__c=Con.ZTS_US_DVM_Year__c;
                edu.ZTS_US_Type__c='DVM';
                edu.ZTS_US_Contact__c=Con.ID;
                listEdu.add(edu);
            }
            
            }
        // Updating Education record list.
        if(listEdu.size()>0){
            try{ 
                 List<Database.Saveresult> results=Database.insert(listEdu,false);
                 ZTS_EU_Logger.error(results,'ZTS_US_EduCreationAndUpdateFromContact-createEducationRecord');
                 
    

            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_EduCreationAndUpdateFromContact-createEducationRecord');
            }
        }    
     }
     /***********
        * Method name  : updateEducationRecord
        * Description  : This will update Education record on update of Contact.
        * Return Type  : None.
        * Parameters   : trigger parameters.
        ***********/
     public static void updateEducationRecord(List<Contact> triggerNew,Map<ID,Contact> triggerOldMap){
     Set<Id> setConId = new Set<Id>();
     Map<Id,ZTS_US_Education_Background__c> mapConIdAndEdu = new Map<Id,ZTS_US_Education_Background__c>();
     List<ZTS_US_Education_Background__c> lstEduToUpdate = new List<ZTS_US_Education_Background__c>();
     //static boolean chkUpdate = true;
    
         for(Contact cont: triggerNew){
             if((cont.ZTS_US_Institution__c != triggerOldMap.get(cont.id).ZTS_US_Institution__c )||(cont.ZTS_US_DVM_Year__c != triggerOldMap.get(cont.id).ZTS_US_DVM_Year__c )){
                 setConId.add(cont.Id);
             }
         }
         List<ZTS_US_Education_Background__c> lstEdu = [Select a.ZTS_US_Institution__c, a.ZTS_US_DVM_Year__c,a.ZTS_US_Contact__c From ZTS_US_Education_Background__c a
                                      where a.ZTS_US_Contact__c in :setConId];
         for(ZTS_US_Education_Background__c educ: lstEdu){
               mapConIdAndEdu.put(educ.ZTS_US_Contact__c,educ); 
         }
         //whenever a new contact is created, Create a corresponding Education record with DVM as Type.
         for(Contact cont: triggerNew){
             if((cont.ZTS_US_Institution__c != triggerOldMap.get(cont.id).ZTS_US_Institution__c )||(cont.ZTS_US_DVM_Year__c != triggerOldMap.get(cont.id).ZTS_US_DVM_Year__c )){
                 if(mapConIdAndEdu.get(cont.Id) != null && mapConIdAndEdu.containsKey(cont.Id) && chkUpdate){
                    ZTS_US_Education_Background__c educ = new ZTS_US_Education_Background__c();
                    educ = mapConIdAndEdu.get(cont.Id);
                    educ.ZTS_US_Institution__c=cont.ZTS_US_Institution__c;
                    educ.ZTS_US_DVM_Year__c=cont.ZTS_US_DVM_Year__c;
                    educ.ZTS_US_Type__c='DVM';
                    lstEduToUpdate.add(educ);
                }
             }
         }
         
         try{ 
             chkUpdate = false;
             //Database.update(lstEduToUpdate);
                   List<Database.Saveresult> results=Database.update(lstEduToUpdate,false);
                 ZTS_EU_Logger.error(results,'ZTS_US_EduCreationAndUpdateFromContact-updateEducationRecord');
                 
    

            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_EduCreationAndUpdateFromContact-updateEducationRecord');
            }                         
     }
        
    /***********
    * Method name  : updateAccConAffInactive
    * Description  : If an Contact is Inactivated, then all Account Contact Affiliations for that Contact is updated to Status = Inactive
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public static void updateAccConAffInactive(List<Contact> triggerNew){
        Set<Id> inactiveConIds =  new Set<Id>();
        //checking for Contacts where status is inactive
        for(Contact con: triggerNew){
            if(con.ZTS_EU_Contact_Status__c == 'Inactive'){
                inactiveConIds.add(con.Id);
            }
        }
        List<ZTS_EU_Affiliations__c> accConAffList =  new List<ZTS_EU_Affiliations__c>();
        if(inactiveConIds.size()>0){
            accConAffList = [Select Id, ZTS_EU_Affiliation_Status__c, ZTS_EU_Contact__c From ZTS_EU_Affiliations__c where ZTS_EU_Contact__c IN: inactiveConIds AND ZTS_EU_Market_from_Parent__c = 'United States'];
        }
        if(accConAffList.size()>0){
            for(ZTS_EU_Affiliations__c accConAff : accConAffList){
                accConAff.ZTS_EU_Affiliation_Status__c = 'Inactive';
            }
            try{ 
             //Database.update(accConAffList);
             List<Database.Saveresult> results=Database.update(accConAffList,false);
                 ZTS_EU_Logger.error(results,'ZTS_US_EduCreationAndUpdateFromContact-updateAccConAffInactive');
            }
            catch(Exception e){
                ZTS_EU_Logger.error('Non DMLException : '+e.getMessage(), null, 'ZTS_US_EduCreationAndUpdateFromContact-updateAccConAffInactive');
            } 
        }
    }
}