public class ZTS_EU_AddtoCampaignFromConController {
    
    public String conCampId {set;get;}
    public Contact conCamp {set;get;}
   
    public ZTS_EU_AddtoCampaignFromConController(ApexPages.StandardController controller) {
         conCamp = new Contact();
         conCampId = ApexPages.currentPage().getParameters().get('conCampId');
    }
    public PageReference addConCampaign(){
        CampaignMember conCampMem = new CampaignMember();
        Id selectedCampId = conCamp.ZTS_EU_Campaign_for_Contact__c;
       
                CampaignMemberStatus campMemStatusDefault = new CampaignMemberStatus();
                campMemStatusDefault = [Select label from CampaignMemberStatus where CampaignId =: selectedCampId AND IsDefault = True limit 1];
                conCampMem.CampaignId = selectedCampId;
                conCampMem.ContactId = conCampId;
                conCampMem.Status = campMemStatusDefault.label;
            
       
        
           // insert listCampAccIns;
         try{
            insert conCampMem;
            PageReference pg = new PageReference('/'+conCampId);
            pg.setRedirect(true);
            return pg;}catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); return null;}
       
    }
}