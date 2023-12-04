/*************************************************************************************************************************
  Class Name     : ZTS_EU_BO_AccUtil_Queueable
  Description    : This Queueable class is used to call the future method classes i.e., AccountUtility and ZTS_EU_Bring_Offline_UtilityClass from Account Trigger.
  Created By     : Cognizant:Saipraneeth
  Created On     : 07/11/2018
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Cognizant:Saipraneeth               07/11/2018                 Created

***************************************************************************************************************************/
public class ZTS_EU_BO_AccUtil_Queueable implements Queueable {
	
    Public final List<string> emailList;
    Public final Set<Id> accountIDs;
    Public final Map<string,boolean> emailMap;
    public final string triggerContext;
    Public final List<Id> newAccIdList;
    
    Public ZTS_EU_BO_AccUtil_Queueable(List<string> emailList, Set<Id> accountIDs, Map<string,boolean> emailMap, List<Id> newAccIdList, string triggerContext){
        this.emailList = emailList;
        this.accountIDs = accountIDs;
        this.emailMap = emailMap;
        this.newAccIdList = newAccIdList;
        this.triggerContext = triggerContext;
    }
   
    Public void execute(QueueableContext context){
        if(emailList.size() > 0){
       		AccountUtility.syncOptOutField(emailList,accountIDs,emailMap);
        }
        if(triggerContext == 'AfterUpdate' && !newAccIdList.isEmpty()){
       		ZTS_EU_Bring_Offline_UtilityClass.makeAccountPositionInActive(newAccIdList);
        }
    }
    
}