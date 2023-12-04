public with sharing class ZTS_US_removeTargetAccntsController {
    List<String> listTarAccID = new List<String>();
    public String campId {get;set;}
    public ZTS_US_removeTargetAccntsController(ApexPages.StandardController controller) {
         if(ApexPages.currentPage().getParameters().containsKey('records'))
         listTarAccID = ApexPages.currentPage().getParameters().get('records').split(',');
         if(ApexPages.currentPage().getParameters().containsKey('campId'))
         campId = ApexPages.currentPage().getParameters().get('campId');
    }
     public PageReference removeTargetAccnts(){
        System.debug('removeTargetAccnts   ::::::');
        List<ZTS_EU_Campaign_Account__c> listTarAccnt = new List<ZTS_EU_Campaign_Account__c>();
        List<CampaignMember> listCampMem =  new List<CampaignMember>();
        List<ZTS_EU_Affiliations__c> listAccConAff = new List<ZTS_EU_Affiliations__c>();
        Set<Id> accntIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        listTarAccnt = [Select Id, Name, ZTS_EU_Member_Status__c, ZTS_EU_Account__c from ZTS_EU_Campaign_Account__c where Id IN: listTarAccID];
        for(ZTS_EU_Campaign_Account__c oTarAccnt : listTarAccnt){
            oTarAccnt.ZTS_EU_Member_Status__c = 'Removed';
            accntIds.add(oTarAccnt.ZTS_EU_Account__c);
        }
        try{
        update listTarAccnt;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        listAccConAff = [Select ZTS_EU_Account__c, ZTS_EU_Contact__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__c IN: accntIds];
        for(ZTS_EU_Affiliations__c oAccConAff : listAccConAff) {
            conIds.add(oAccConAff.ZTS_EU_Contact__c);
        }
        listCampMem = [Select ContactId, CampaignId from CampaignMember where ContactId IN: conIds AND CampaignId =: campId AND ZTS_EU_Market__c = 'United States'];
        if(listCampMem.size()>0){
        try{
        delete listCampMem;
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
        }
         PageReference pg = new PageReference('/'+campId);
            pg.setRedirect(true);
            return pg;
        
    }
}