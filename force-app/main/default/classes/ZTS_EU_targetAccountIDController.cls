/*************************************************************************************************************************
Class Name  : ZTS_EU_targetAccountIDController 
Description : This class is Controller for VisualForce Page "ZTS_EU_targetAccountID" which will fetch the ZTS_EU_ZOETIS_SFDC_IDs__c instead of ZTS_EU_SFDC_IDs__c and follow the procedure as given 
              Reference :  DEF-000057 - Zoetis SFDC Id for targeting accounts
Modified By :  Sohil Shah (CloudSense)
Edited On   :   02/09/2014

***************************************************************************************************************************/


public with sharing class ZTS_EU_targetAccountIDController {

    public ZTS_EU_Campaign_Account__c campAccnt {set;get;}
    List<ZTS_EU_Campaign_Account__c> listTargetedAcc;
    public String campId {set;get;}
    public ZTS_EU_targetAccountIDController(ApexPages.StandardController controller) {
        campAccnt = new ZTS_EU_Campaign_Account__c();
        listTargetedAcc = new List<ZTS_EU_Campaign_Account__c>();
        campId = ApexPages.currentPage().getParameters().get('campId');
        campAccnt.ZTS_EU_Campaign__c = campId;
    }
    
    public PageReference addTargetAccountID(){
        Set<Id> accIds = new Set<Id>();
        List<String> listSfdcIds = new List<String>();
        Set<String> listSfdcIdsPresent = new Set<String>();
        List<String> listSfdcIdsToAdd = new List<String>();
        // Edited by Sohil Shah(CloudSense) ZTS_EU_ZOETIS_SFDC_IDs__c from ZTS_EU_SFDC_IDs__c ;
        if(String.isNotEmpty(campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c))
        {
            if(campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c.contains(';')){ 
                listSfdcIds = campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c.split(';');
            }else if(campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c.contains('\n')){           
                listSfdcIds = campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c.split('\\r?\\n');
            } else {
                listSfdcIds.add(campAccnt.ZTS_EU_ZOETIS_SFDC_IDs__c);
            }
        }
        
       
        List<String> accountIdLst = new List<String>();
        List<Account> accountList = new List<Account>([Select Id, Name from Account where ZTS_EU_Zoetis_SFDC_ID__c IN: listSfdcIds AND ZTS_EU_Market__c != 'United States']);
           for(Account acc : accountList )
           {
                accountIdLst.add(acc.id);
           }
      // completed code DEF-000057
        for(ZTS_EU_Campaign_Account__c listCampAccCheck : [Select Id, Name, ZTS_EU_Account__r.Id, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c where ZTS_EU_Account__r.Id IN: accountIdLst AND ZTS_EU_Campaign__c =: campId  AND ZTS_EU_Market_From_Parent__c != 'United States']){
            listSfdcIdsPresent.add(listCampAccCheck.ZTS_EU_Account__r.Id);
            accIds.add(listCampAccCheck.ZTS_EU_Account__c);
        }
       
        
        for(String listNar : listSfdcIds){
            if(!listSfdcIdsPresent.contains(listNar))
            listSfdcIdsToAdd.add(listNar);
        }
        
        for(Account oAcc : [Select Id, Name From Account where Id IN: accountIdLst AND ZTS_EU_Market__c != 'United States']){
            ZTS_EU_Campaign_Account__c targetedAcc = new ZTS_EU_Campaign_Account__c();
            targetedAcc.ZTS_EU_Campaign__c = campId;
            targetedAcc.ZTS_EU_Account__c = oAcc.Id;
            listTargetedAcc.add(targetedAcc);            
        }       
        dupTargetAccUpdate(accIds);
         try{            
            if(listTargetedAcc.size()>0)
            Database.insert(listTargetedAcc,false);
            PageReference pg = new PageReference('/'+campId);
            pg.setRedirect(true);
            return pg;
            
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }       
    }
    
    public void dupTargetAccUpdate(Set<Id> listAccIds){
        List<ZTS_EU_Campaign_Account__c> listCampAcc = new List<ZTS_EU_Campaign_Account__c>();
        listCampAcc = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c where ZTS_EU_Account__c IN: listAccIds AND ZTS_EU_Campaign__c =: campId AND ZTS_EU_Member_Status__c = 'Removed' AND ZTS_EU_Market_From_Parent__c != 'United States'];
        System.debug('listCampAcc--------'+listCampAcc);
        
        If(listCampAcc.size()>0){
            for(ZTS_EU_Campaign_Account__c oCampAcc : listCampAcc)
            oCampAcc.ZTS_EU_Member_Status__c = 'Added';            
            try{
            update listCampAcc;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));            
        }
        }
    }
}