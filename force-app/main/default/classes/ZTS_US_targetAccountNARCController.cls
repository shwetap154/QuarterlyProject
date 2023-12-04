public with sharing class ZTS_US_targetAccountNARCController {

    public ZTS_EU_Campaign_Account__c campAccnt {set;get;}
    List<ZTS_EU_Campaign_Account__c> listTargetedAcc;
    public String campId {set;get;}
    public ZTS_US_targetAccountNARCController(ApexPages.StandardController controller) {
        campAccnt = new ZTS_EU_Campaign_Account__c();
        listTargetedAcc = new List<ZTS_EU_Campaign_Account__c>();
        campId = ApexPages.currentPage().getParameters().get('campId');
        campAccnt.ZTS_EU_Campaign__c = campId;
    }
    
    public PageReference addTargetAccountNARC(){
        Set<Id> accIds = new Set<Id>();
        List<String> listNarcIds = new List<String>();
        Set<String> listNarcIdsPresent = new Set<String>();
        List<String> listNarcIdsToAdd = new List<String>();
        system.debug('Narc Ids>>>>>>>>>>>>'+campAccnt.ZTS_US_NARC_IDs__c);
        if(campAccnt.ZTS_US_NARC_IDs__c.contains(';')){
            listNarcIds = campAccnt.ZTS_US_NARC_IDs__c.split(';');
            system.debug('Narc Ids  ; >>>>>>>>>>>>'+listNarcIds);
        }else if(campAccnt.ZTS_US_NARC_IDs__c.contains('\n')){
           
            listNarcIds = campAccnt.ZTS_US_NARC_IDs__c.split('\\r?\\n');
            system.debug('Narc Ids  / >>>>>>>>>>>>'+listNarcIds);
        } else {
            listNarcIds.add(campAccnt.ZTS_US_NARC_IDs__c);
        }
        
        
        
        for(ZTS_EU_Campaign_Account__c listCampAccCheck : [Select Id, Name, ZTS_US_NARC_ID__c, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c where ZTS_US_NARC_ID__c IN: listNarcIds AND ZTS_EU_Campaign__c =: campId AND ZTS_EU_Market_From_Parent__c = 'United States' ]){
            listNarcIdsPresent.add(listCampAccCheck.ZTS_US_NARC_ID__c);
            accIds.add(listCampAccCheck.ZTS_EU_Account__c);
        }
        
        for(String listNar : listNarcIds){
            if(!listNarcIdsPresent.contains(listNar))
            listNarcIdsToAdd.add(listNar);
        }
        
        for(Account oAcc : [Select Id, Name, ZTS_US_NARC_ID__c From Account where ZTS_US_NARC_ID__c IN: listNarcIdsToAdd AND ZTS_EU_Market__c = 'United States']){
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
        listCampAcc = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c where ZTS_EU_Account__c IN: listAccIds AND ZTS_EU_Campaign__c =: campId AND ZTS_EU_Member_Status__c = 'Removed' AND ZTS_EU_Market_From_Parent__c = 'United States'];
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