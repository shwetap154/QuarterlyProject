/*******************************************************************************************************************************************
* File Name     :   ZTS_EU_UncheckBrickBatch 
* Description   :  Query all the brick where need synced is true and based on the sucess record of ZTS_EU_UncheckZip,It will update zip.

Sequence of events : Account(s) is/are updated with ZTS_EU_TSF_PBC__c field value.
                   : Finish method triggers
                        ->Send out an email with following infromation.
                            a> No of records which are successfully updated.
                            b>No of records which are not updated.
                            c>Notification when batch process is completed.
* @author       :   Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     5/13/2014     Sunil           Created the class.

********************************************************************************************************************************************/
public class ZTS_EU_UncheckBrickBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Double failedUpdates = 0;
    public Set<Id> failedZipId;
    public Map<id,id> updatedZipMap;
    public Map<id,id> failedZipMap = new Map<id,id>();
    public Database.QueryLocator start(Database.BatchableContext BC){
         return Database.getQueryLocator([select id,name,ZTS_EU_To_Be_Synced__c,ZTS_EU_Territory__c from ZTS_GL_BrickToTerr__c  where ZTS_EU_To_Be_Synced__c = true]);
    }
    public void execute(Database.BatchableContext BC,List<sObject> scope){
        List<ZTS_GL_BrickToTerr__c> updateBrickList = new List<ZTS_GL_BrickToTerr__c>();
        for(ID zip : failedZipId){
            if(updatedZipMap.containsKey(zip)){
                failedZipMap.put(updatedZipMap.get(zip),updatedZipMap.get(zip));
            }
        
        }
        for(sObject s : scope){
            ZTS_GL_BrickToTerr__c brick = (ZTS_GL_BrickToTerr__c)s;
            if(!failedZipMap.containsKey(brick.id)){
                brick.ZTS_EU_To_Be_Synced__c = false;
                updateBrickList.add(brick);
            }
        
        }
        List<Database.SaveResult> dBrickResult = Database.update(updateBrickList, false);
    }
    public void finish(Database.BatchableContext ctx){
        Boolean isMassAssign;
        ZTS_EU_MassTerritoryAssignment__c massTerr = ZTS_EU_MassTerritoryAssignment__c.getValues('Territory_Sync'); 
        if(massTerr != null){
            isMassAssign = massTerr.ZTS_EU_Start_Syncing__c;
            if(isMassAssign == true){
                massTerr.ZTS_EU_Start_Syncing__c = false;
                update massTerr;
            }
           
        }
        AsyncApexJob a = [SELECT id, ApexClassId,JobItemsProcessed, TotalJobItems,NumberOfErrors, CreatedBy.Email FROM AsyncApexJob WHERE id = :ctx.getJobId()];
        String emailMessage = System.Label.ZTS_EU_TerritoryClassBMsg
              
             +'  '     
             + a.totalJobItems
             
              +'  '
             + System.Label.ZTS_EU_TerritoryClassBMsg1 +'  '+  a.jobitemsprocessed  +'  '

             + System.Label.ZTS_EU_TerritoryClassBMsg2  +'  '
             
             + a.numberOfErrors +  '  '+ 
             

             System.Label.ZTS_EU_TerritoryClassBMsg3 +'  '
             

             +  System.Label.ZTS_EU_TerritoryClassBMsg4  +'  '

             + failedUpdates  +'  '

             + System.Label.ZTS_EU_TerritoryClassBMsg5;
             
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.createdBy.email};
        mail.setToAddresses(toAddresses);       
        mail.setSenderDisplayName(System.Label.ZTS_EU_TerritoryClassBMsg6);
        mail.setSubject(System.Label.ZTS_EU_TerritoryClassMailSubject);
        mail.setPlainTextBody(emailMessage);
        mail.setHtmlBody(emailMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }
}