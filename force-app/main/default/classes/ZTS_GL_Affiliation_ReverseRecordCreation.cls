/*************************************************************************************************************************
  Class Name     : ZTS_GL_Affiliation_ReverseRecordCreation
  Description    : Create reverse records for Account-Account and Contact-Contact affiliation.
  Created By     : Ninad
  Created On     : Jan 29, 2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                            Date                   Description
  ---------                            ----                 -----------
  
***************************************************************************************************************************/
public Class ZTS_GL_Affiliation_ReverseRecordCreation
{
    @testVisible 
    static final String ACC_AFFILIATIONS_INST_ERROR_ORIGIN = 'ZTS_GL_Affiliation_ReverseRecordCreation - undeleteAccountRecord(): insert Account Affiliation ';

    @testVisible 
    static final String ACC_AFFILIATIONS_INST_ERROR_ORIGIN1 = 'ZTS_GL_Affiliation_ReverseRecordCreation - insertRecord(): insert Account Affiliation ';

    @testVisible 
    static final String ACC_AFFILIATIONS_UPDATE_ERROR_ORIGIN = 'ZTS_GL_Affiliation_ReverseRecordCreation - updateAccountRecord(): update Account Affiliation ';
    
    public static boolean isExecuted = false;
    public static boolean isUpdateExecuted = false;
    public static boolean isUpdate = false;
    public static boolean isUndelete = false;
    Map <String,ZTS_EU_Account_Affiliations__c> accList = new map <String,ZTS_EU_Account_Affiliations__c>();
    Map <String,ZTS_EU_Account_Affiliations__c> accList1 = new map <String,ZTS_EU_Account_Affiliations__c>();
    Map <String,ZTS_GL_Contact_Affiliation_Reverse_Roles__c> customSettingCon = new Map<String,ZTS_GL_Contact_Affiliation_Reverse_Roles__c>();
    Map <String,ZTS_GL_Account_Affiliation_Reverse_Roles__c> customSettingAcc = new Map<String,ZTS_GL_Account_Affiliation_Reverse_Roles__c>();
    
    // constructor    
    public ZTS_GL_Affiliation_ReverseRecordCreation()
    {
       
        customSettingCon  = ZTS_GL_Contact_Affiliation_Reverse_Roles__c.getAll();
        customSettingAcc  = ZTS_GL_Account_Affiliation_Reverse_Roles__c.getAll();
    }
    
    /***********       
    * Method name  : insertRecord
    * Description  : This will on insert operation of ZTS_EU_Account_Affiliations__c.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
    public void insertRecord(List<ZTS_EU_Account_Affiliations__c> triggerNew, Map <ID,ZTS_EU_Account_Affiliations__c> triggerNewMap)
    {
        List<ZTS_EU_Account_Affiliations__c> oAccAffiList = new List<ZTS_EU_Account_Affiliations__c>();
        
         for (ZTS_EU_Account_Affiliations__c oAccAffi : triggerNew)
         {
             ZTS_EU_Account_Affiliations__c oAccAffiNew = new ZTS_EU_Account_Affiliations__c();
             oAccAffiNew.ZTS_EU_Account__c = oAccAffi.ZTS_EU_Affiliated_Account__c;
             oAccAffiNew.ZTS_EU_Affiliated_Account__c = oAccAffi.ZTS_EU_Account__c;
             if(triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c != '--None--' || triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c != NULL)
             {    
                 //oAccAffiNew.ZTS_US_Role__c = 'Client';
                 ZTS_GL_Account_Affiliation_Reverse_Roles__c customSet = customSettingAcc.get(triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c);
                 if(customSet != NULL)
                 {
                   oAccAffiNew.ZTS_US_Role__c = customSet.ZTS_GL_Reverse_Role__c; 
                 }
                 
             }
             oAccAffiNew.ZTS_EU_Affiliation_Status__c = oAccAffi.ZTS_EU_Affiliation_Status__c;  
             oAccAffiNew.ZTS_EU_Account_influence__c = oAccAffi.ZTS_EU_Account_influence__c;             
             oAccAffiNew.ZTS_EU_Related_record_ID__c = oAccAffi.ID;
             
             oAccAffiList.add(oAccAffiNew);
         }
         if(isExecuted == false)
         {
             if(oAccAffiList.size() > 0)
             {
                isExecuted = true;
                try{
                  Database.insert(oAccAffiList);
                }
                catch(DmlException dex)
                {	
                  String errorMessages = '';
                  for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(ACC_AFFILIATIONS_INST_ERROR_ORIGIN1);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                  }
                  errorMessages.removeEnd('\n');
                  ZTS_EU_Logger.notify = true;
                  ZTS_EU_Logger.error(errorMessages,null, ACC_AFFILIATIONS_INST_ERROR_ORIGIN1);
                }
             }
         } 
    }
    
    
    
   
    /***********       
    * Method name  : updateAccountRecord
    * Description  : This will on update operation of ZTS_EU_Account_Affiliations__c.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
      //for update Account
      public void updateAccountRecord(List<ZTS_EU_Account_Affiliations__c> triggerNew, List<ZTS_EU_Account_Affiliations__c> triggerOld,
                                        Map <ID,ZTS_EU_Account_Affiliations__c> triggerNewMap, Map <ID,ZTS_EU_Account_Affiliations__c> triggerOldMap )
      {

        List<ZTS_EU_Account_Affiliations__c> newAccAffRecList = [SELECT Id, ZTS_EU_Influence__c, ZTS_EU_Related_Record_ID__c 
                                                                  FROM ZTS_EU_Account_Affiliations__c 
                                                                  WHERE ZTS_EU_Related_Record_ID__c IN :TriggerNewMap.keyset() AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ];

        System.debug('$$$ newAccAffRecList'+newAccAffRecList);
        for(ZTS_EU_Account_Affiliations__c oAcc : newAccAffRecList)
        {
          accList1.put(oAcc.ZTS_EU_Related_Record_ID__c,oAcc);
        }

        List<String> relatedRecList = new List<String>();
        for(ZTS_EU_Account_Affiliations__c acctAffRec : triggernew)
        {
          if(acctAffRec.ZTS_EU_Related_record_ID__c != null && acctAffRec.ZTS_EU_Related_record_ID__c != ''){
            relatedRecList.add(acctAffRec.ZTS_EU_Related_record_ID__c);
          }
        }

        List<ZTS_EU_Account_Affiliations__c> accAffRelatedRecList = [SELECT Id, ZTS_EU_Influence__c, ZTS_EU_Related_Record_ID__c 
                                                                FROM ZTS_EU_Account_Affiliations__c 
                                                                WHERE Id IN :relatedRecList AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ];
    
        for(ZTS_EU_Account_Affiliations__c oAcc : accAffRelatedRecList){
            accList.put(oAcc.Id,oAcc);
        }
      	
        List<ZTS_EU_Account_Affiliations__c> accAffToUpdateList = new List<ZTS_EU_Account_Affiliations__c>();

        for(ZTS_EU_Account_Affiliations__c oAccAffi : triggernew)
        {

          if( (triggerNewMap.get(oAccAffi.ID).ZTS_EU_Account_influence__c != triggerOldMap.get(oAccAffi.ID).ZTS_EU_Account_influence__c) ||
              (triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c != triggerOldMap.get(oAccAffi.ID).ZTS_US_Role__c) ||
              (triggerNewMap.get(oAccAffi.ID).ZTS_EU_Affiliation_Status__c != triggerOldMap.get(oAccAffi.ID).ZTS_EU_Affiliation_Status__c) )  
          {
            ZTS_EU_Account_Affiliations__c oAccAffiUpdate = new ZTS_EU_Account_Affiliations__c();
                              
            if(accList.containskey(triggerOldMap.get(oAccAffi.ID).ZTS_EU_Related_record_ID__c))
            {
              oAccAffiUpdate = accList.get(triggerNewMap.get(oAccAffi.ID).ZTS_EU_Related_record_ID__c);
              if(oAccAffi.ZTS_US_Role__c != '--None--' && oAccAffi.ZTS_US_Role__c != NULL) 
                {
                    
                    ZTS_GL_Account_Affiliation_Reverse_Roles__c customSet = customSettingAcc.get(triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c);
                    if(customSet != NULL)
                    {
                      oAccAffiUpdate.ZTS_US_Role__c = customSet.ZTS_GL_Reverse_Role__c; 
                    }
                }
                oAccAffiUpdate.ZTS_EU_Affiliation_Status__c = oAccAffi.ZTS_EU_Affiliation_Status__c;
                oAccAffiUpdate.ZTS_EU_Account_influence__c = oAccAffi.ZTS_EU_Account_influence__c;
                accAffToUpdateList.add(oAccAffiUpdate);
              system.debug('updated Account :::' + oAccAffiUpdate);
            }
        
        
            if(accList1.containskey(triggerOldMap.get(oAccAffi.ID).ID))
            {
                System.debug('$$$ Inside if');
                oAccAffiUpdate = accList1.get(triggerNewMap.get(oAccAffi.ID).ID);
                
                if(oAccAffi.ZTS_US_Role__c != '--None--' && oAccAffi.ZTS_US_Role__c != NULL && oAccAffi.ZTS_US_Role__c!= 'Client') 
                {
                      //oAccAffiUpdate.ZTS_US_Role__c = 'Client';
                      ZTS_GL_Account_Affiliation_Reverse_Roles__c customSet = customSettingAcc.get(triggerNewMap.get(oAccAffi.ID).ZTS_US_Role__c);
                      if(customSet != NULL)
                      {
                        oAccAffiUpdate.ZTS_US_Role__c = customSet.ZTS_GL_Reverse_Role__c; 
                      }
                }
                oAccAffiUpdate.ZTS_EU_Affiliation_Status__c = oAccAffi.ZTS_EU_Affiliation_Status__c;
                oAccAffiUpdate.ZTS_EU_Account_influence__c = oAccAffi.ZTS_EU_Account_influence__c;
                accAffToUpdateList.add(oAccAffiUpdate);
                system.debug('updated Account :::' + oAccAffiUpdate);
            }
          }   
        }

        if(isUpdate == false){
          if(accAffToUpdateList.size() > 0){ 
            isUpdate = true;
            try
            {
                System.debug('$$$ accAffToUpdateList'+accAffToUpdateList);
                update accAffToUpdateList;
            }
            catch(DmlException dex)
            {	
              String errorMessages = '';
              for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(ACC_AFFILIATIONS_UPDATE_ERROR_ORIGIN);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
              }
              errorMessages.removeEnd('\n');
              ZTS_EU_Logger.notify = true;
              ZTS_EU_Logger.error(errorMessages,null, ACC_AFFILIATIONS_UPDATE_ERROR_ORIGIN);
            }
          }
        }
      }
      
    /***********       
    * Method name  : undeleteAccountRecord
    * Description  : This will on undelete operation of ZTS_EU_Account_Affiliations__c.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/
      //Undelete Account
    public void undeleteAccountRecord(List<ZTS_EU_Account_Affiliations__c> triggerNew)
    {
        List<ZTS_EU_Account_Affiliations__c> oAccAffiList = new List<ZTS_EU_Account_Affiliations__c>();
        
         for (ZTS_EU_Account_Affiliations__c oAccAffi : triggerNew)
         {
             ZTS_EU_Account_Affiliations__c oAccAffiNew = new ZTS_EU_Account_Affiliations__c();
             oAccAffiNew.ZTS_EU_Account__c = oAccAffi.ZTS_EU_Affiliated_Account__c;
             oAccAffiNew.ZTS_EU_Affiliated_Account__c = oAccAffi.ZTS_EU_Account__c;    
             if(oAccAffi.ZTS_EU_Related_record_ID__c == '' || oAccAffi.ZTS_EU_Related_record_ID__c == NULL) 
             {
                 //oAccAffiNew.ZTS_GL_Influence__c = 'is Influenced by';
                 oAccAffiNew.ZTS_EU_Related_record_ID__c = oAccAffi.ID;
             }
             else
             {
                 //oAccAffiNew.ZTS_GL_Influence__c = 'is Influencing';
                 oAccAffiNew.ZTS_EU_Related_record_ID__c = oAccAffi.ID;
             }
             oAccAffiList.add(oAccAffiNew);
         }
         if(isUndelete == false)
         {
             if(oAccAffiList.size() > 0)
             {
                 isUndelete= true;
                 isExecuted = true;
                try{
                  Database.insert(oAccAffiList);
                }
                catch(DmlException dex)
                {	
                  String errorMessages = '';
                  for (Integer i = 0; i < dex.getNumDml(); i++) {
                    System.debug(ACC_AFFILIATIONS_INST_ERROR_ORIGIN);
                    System.debug('DML Message: ' + dex.getDmlMessage(i));
                    errorMessages += dex.getDmlMessage(i) + '\n';
                  }
                  errorMessages.removeEnd('\n');
                  ZTS_EU_Logger.notify = true;
                  ZTS_EU_Logger.error(errorMessages,null, ACC_AFFILIATIONS_INST_ERROR_ORIGIN);
                }
             }
         } 
      }
      
    
    
              
}