public class ZTS_EU_AddtoCampaignRedirect {
    
    public String fromCamp {set;get;}
    public String fromCampId {set;get;}
    //Added by Aritra for SC-008159
    public String targAccIds {set;get;}
    public String selectedCampaignIds{set;get;}
    public String selectedCampaignNames{set;get;}
    public ZTS_EU_Campaign_Account__c campAccnt {set;get;}
    public List<String> listAccID;
    public ZTS_EU_AddtoCampaignRedirect(ApexPages.StandardController controller) {
         campAccnt = new ZTS_EU_Campaign_Account__c();
         listAccID = new List<String>();
         //selectedCampaignNames = '-- Click on the icon to select Campaign/s --';
        // selectedCampaignIds = '';
         listAccID = ApexPages.currentPage().getParameters().get('records').split(',');
         system.debug('accntids >>>>>>>>>>>>>>'+listAccID);         
    }
    public PageReference fromCampMethod(){
        if(ApexPages.currentPage().getParameters().containsKey('fromCamp'))
        {
          fromCamp = ApexPages.currentPage().getParameters().get('fromCamp');
          fromCampId = ApexPages.currentPage().getParameters().get('fromCampId');
          system.debug('>>>>>>>>>>>>>'+ fromCamp);
        
        List<ZTS_EU_Affiliations__c> listAccConAff = new List<ZTS_EU_Affiliations__c>();
        List<ZTS_EU_Campaign_Account__c> listCampAccIns = new List<ZTS_EU_Campaign_Account__c>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<CampaignMember> listAccCampMem = new List<CampaignMember>();
        
        listAccConAff = [Select Id, ZTS_EU_Account__c, ZTS_EU_Contact__c, ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c from ZTS_EU_Affiliations__c where ZTS_EU_Account__c IN: listAccID AND ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c = 'Active' AND ZTS_EU_Market_from_Parent__c != 'United States'];
        for(ZTS_EU_Affiliations__c oAccConAff : listAccConAff){
            conIds.add(oAccConAff.ZTS_EU_Contact__c);
        }
        for(String oAccId : listAccID){
        ZTS_EU_Campaign_Account__c campAccIns = new ZTS_EU_Campaign_Account__c();
        campAccIns.ZTS_EU_Account__c = oAccId;
        campAccIns.ZTS_EU_Campaign__c = fromCampId;
        listCampAccIns.add(campAccIns);
        }
        //Added by Aritra (SC-08159)
        targAccIds = '';  
        for(Id i : listAccID){
            targAccIds += i+ ',';                       
        }
        targAccIds = targAccIds.removeEnd(','); 
        //End 
        /*Id selectedCampId = fromCampId;
       
                CampaignMemberStatus campMemStatusDefault = new CampaignMemberStatus();
                campMemStatusDefault = [Select label from CampaignMemberStatus where CampaignId =: selectedCampId AND IsDefault = True limit 1];
                for(Id conId : conIds){
                CampaignMember accCampMem = new CampaignMember();
                accCampMem.CampaignId = selectedCampId;
                accCampMem.ContactId = conId;
                accCampMem.Status = campMemStatusDefault.label;
                listAccCampMem.add(accCampMem);
                }*/ //Commented by Aritra for SC-008159
        
       
         try{
            if(listCampAccIns.size()>0)
            Database.insert(listCampAccIns,false);
            //if(listAccCampMem.size()>0)
            //Database.insert(listAccCampMem,false);
            dupTargetAccUpdate();
            //PageReference pg = new PageReference('/'+fromCampId);--Commented out by Aritra SC-008159
            PageReference pg = new PageReference('/apex/ZTS_EU_AddContactToCampaign?fromAccount=false&campId='+fromCampId+'&accIds='+ targAccIds);
            pg.setRedirect(true);
            return pg;
         }
            catch(Exception e)
            { 
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
             return null;
            }
        }else{
        return null;
        }
    }
    public PageReference addAccCampaign()
    {
        List<ZTS_EU_Campaign_Account__c> listCampAccIns = new List<ZTS_EU_Campaign_Account__c>();
        Id selectedCampId = campAccnt.ZTS_EU_Campaign_Hidden__c;
        
        if(String.isNotEmpty(selectedCampId))
        {
            fromCampId = selectedCampId;
            for(String oAccId : listAccID)
            { 
                ZTS_EU_Campaign_Account__c campAccIns = new ZTS_EU_Campaign_Account__c();
                campAccIns.ZTS_EU_Account__c = oAccId;
                campAccIns.ZTS_EU_Campaign__c = selectedCampId;
                listCampAccIns.add(campAccIns);
            
            }
        }
        if(listCampAccIns.size()>0)
        {
            try
            {
                Database.insert(listCampAccIns,false);
                dupTargetAccUpdate();
                //PageReference pg = new PageReference('/001'); -- commented by Aritra for SC-008159
                PageReference pg = new PageReference('/apex/ZTS_EU_AddContactToCampaign?campId='+fromCampId);
                pg.setRedirect(true);
                return pg;
            }
            catch(Exception e)
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
                return null;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Campaign record.')); 
            return null;
        }
    }
    
    public void dupTargetAccUpdate()
    {
        List<ZTS_EU_Campaign_Account__c> listCampAcc = new List<ZTS_EU_Campaign_Account__c>();
        listCampAcc = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c 
                        From ZTS_EU_Campaign_Account__c 
                        where ZTS_EU_Account__c IN: listAccID AND ZTS_EU_Campaign__c =: fromCampId AND ZTS_EU_Market_From_Parent__c != 'United States'];
        
        If(listCampAcc.size()>0)
        {
            for(ZTS_EU_Campaign_Account__c oCampAcc : listCampAcc)
                oCampAcc.ZTS_EU_Member_Status__c = 'Added';
            
            try
            {
                update listCampAcc; 
            }
            catch(Exception e)
            { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
            }
        }
    }
}