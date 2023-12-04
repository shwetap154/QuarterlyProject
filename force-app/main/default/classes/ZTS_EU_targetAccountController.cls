public with sharing class ZTS_EU_targetAccountController {
    
    public ZTS_EU_Campaign_Account__c campAccnt {set;get;}    
    public String campId {set;get;}
    public Id selectedAccId = null ;
    public ZTS_EU_targetAccountController(ApexPages.StandardController controller) {
        campAccnt = new ZTS_EU_Campaign_Account__c();
        campId = ApexPages.currentPage().getParameters().get('campId');
    }
    public PageReference addTargetAccount(){
        List<ZTS_EU_Affiliations__c> listAccConAff = new List<ZTS_EU_Affiliations__c>();
        List<ZTS_EU_Campaign_Account__c> listCampAcc = new List<ZTS_EU_Campaign_Account__c>();
        Set<Id> conIds = new Set<Id>();
        List<CampaignMember> listAccCampMem = new List<CampaignMember>();
        selectedAccId = campAccnt.ZTS_EU_Account__c;
        system.debug('-------------values: ' +selectedAccId +'---------'+campId+'\n'+[select ZTS_EU_Account__c,ZTS_EU_Campaign__c from ZTS_EU_Campaign_Account__c WHERE ZTS_EU_Market_From_Parent__c != 'United States']);
        listCampAcc = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c where ZTS_EU_Account__c =: selectedAccId AND ZTS_EU_Campaign__c =: campId AND ZTS_EU_Market_From_Parent__c != 'United States'];
        If(listCampAcc.size()>0){
            for(ZTS_EU_Campaign_Account__c oCampAcc : listCampAcc)
            oCampAcc.ZTS_EU_Member_Status__c = 'Added';
            
            try{
            update listCampAcc;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
            PageReference pg = new PageReference('/'+campId);
            pg.setRedirect(true);
            return pg;
        }
        ZTS_EU_Campaign_Account__c campAccIns = new ZTS_EU_Campaign_Account__c();
        if(selectedAccId != null || selectedAccId != ''){       
        campAccIns.ZTS_EU_Account__c = selectedAccId;
        campAccIns.ZTS_EU_Campaign__c = campId;
        }       
         try{
            if(selectedAccId != null)
            Database.Insert(campAccIns,false);
            PageReference pg = new PageReference('/'+campId);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
       
    }

}