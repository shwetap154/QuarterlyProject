/*************************************************************************************************************************
  Class Name     : ZTS_GL_submit_CR_record
  Description    : This class is called from custom button / trigger of Change request.
  Created By     : Ninad
  Created On     : 02/26/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  Deloitte Constulting/Ninad Patil    02/26/2014              Created

***************************************************************************************************************************/
global class ZTS_EU_submit_CR_record
{
    /***********
    * Method name  : submitRecord
    * Description  : This will chaneg ownership of the object to que and status to submitted.
    * Return Type  : None.
    * Parameters   : record id being updated.
    ***********/
    @AuraEnabled
    webservice static void submitRecord(String recid)
    {
        String queueID = [select Id from Group where Name = 'Change Request Queue' and Type = 'Queue' limit 1].id;
        ZTS_EU_Request__c req  = new ZTS_EU_Request__c(id = recid, ownerID = queueID, ZTS_EU_Status__c = 'Submitted');
        update req;
        
    }
    
    /***********
    * Method name  : updateCRRecord
    * Description  : This will chaneg ownership of the object to requester once status is updated.
    * Return Type  : None.
    * Parameters   : Trigger Context variables.
    ***********/
    public  static void updateCRRecord(List<ZTS_EU_Request__c> triggerNew, Map <id, ZTS_EU_Request__c>triggerNewMap,
                                            Map <id, ZTS_EU_Request__c>triggerOldMap)
    {
        for(ZTS_EU_Request__c oReq : triggerNew)
        {
            if(oReq.ZTS_EU_Status__c<>triggerOldMap.get(oReq.id).ZTS_EU_Status__c)
            {
                if(oReq.ZTS_EU_Status__c == 'Accepted' || oReq.ZTS_EU_Status__c == 'Rejected')
                {
                    oReq.ownerId = oReq.ZTS_EU_Requestor__c;
                }
            }
        }
    }
}