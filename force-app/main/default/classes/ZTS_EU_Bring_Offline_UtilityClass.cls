/*************************************************************************************************************************
  Class Name     : ZTS_EU_Bring_Offline_UtilityClass
  Description    : This class is used to delete Bring Offline records and update Account Position records.
  Created By     : Cognizant:Mayukh
  Created On     : 03/30/2018
                                                           
  Modification Log    :
  ------------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Cognizant:Mayukh                    03/30/2018                 Created

***************************************************************************************************************************/

public class ZTS_EU_Bring_Offline_UtilityClass{
  @future  
    public static void makeAccountPositionInActive(list<Id> acclist){

        List<ZTS_EU_Account_Position__c> updateAccountpostion=new list<ZTS_EU_Account_Position__c>();
        list<ZTS_EU_Account_Position__c> lstAccountpostion=[select id,ZTS_EU_Active__c,ZTS_EU_Bring_offline__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c in:acclist and ZTS_EU_Active__c=true AND ZTS_EU_Market__c != 'United States'];
        List <ZTS_EU_Bring_Offline__c> bringOfflinelst=[select id from ZTS_EU_Bring_Offline__c where ZTS_EU_Account__c in:acclist];
        if(!bringOfflinelst.isEmpty()){
            delete bringOfflinelst;
        }
        if(!lstAccountpostion.isEmpty()){
            for(ZTS_EU_Account_Position__c accpos : lstAccountpostion){
                if(accpos.ZTS_EU_Active__c=true){
                    accpos.ZTS_EU_Active__c=false;
                    accpos.ZTS_EU_Bring_offline__c =false;
                    updateAccountpostion.add(accpos);
                }
            }
        }
        if(!updateAccountpostion.isEmpty() && updateAccountpostion!=null){
            update updateAccountpostion;
        }
    }
    
   
}