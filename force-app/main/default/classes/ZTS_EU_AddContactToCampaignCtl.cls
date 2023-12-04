/****************************************************************************************************************************************** 
 * Class Name       : ZTS_EU_AddContactToCampaignCtl
 * Description      : The class is used to show contact selection Screen after Accounts added to campaign  (SC-008159)                                 
 * Created By   : Cognizant
 * Created Date : March 3rd, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/03/2021          Created 
*****************************************************************************************************************************************/
public with sharing class ZTS_EU_AddContactToCampaignCtl {
    public Campaign currentCampaignRecord    {get;set;}
    public Boolean allChecked { get; set; }
    public string isAccsource { get; set;}
    public List<ContactWrapper> categories  { get; set; }
    public String currentCampName { get; set; }
    public List<ZTS_EU_Affiliations__c> lstCon {get;set;} {lstCon = new List<ZTS_EU_Affiliations__c>();}
    List<ID> listAccID {get;set;}   
    List<ID> listContactId {get;set;}
    public String name {get; set;} 

    
   public ZTS_EU_AddContactToCampaignCtl() {
        
                listAccID = new List<ID>();
                listContactId = new List<ID>();
                categories = new List<ContactWrapper>();
                String campId = ApexPages.currentPage().getParameters().get('campId');
                String accId = ApexPages.currentPage().getParameters().get('accIds');
                isAccsource = ApexPages.currentPage().getParameters().get('fromAccount');
                system.debug('accId>>'+accId);
                
                if(campId != null && campId != ''){
                    currentCampaignRecord = [select Name,Id from Campaign where Id=: campId];
                    currentCampName = currentCampaignRecord.Name;
                }
                List<String> lstIds = accId.split(',');
                for (String i: lstIds){ Id iden = Id.valueOf(i); listAccID.add(iden);}
                system.debug('listAccID>>'+listAccID);
                for(CampaignMember camMem : [select ContactId, CampaignId from CampaignMember 
                                                                    where CampaignId =: campId
                                                                    ]){
                    listContactId.add(camMem.ContactId);                                                   
                }
                system.debug('listContactId>>'+listContactId);
                for(ZTS_EU_Affiliations__c aff: [Select Id, ZTS_EU_Account__c,ZTS_EU_Account__r.Name, ZTS_EU_Contact__c, ZTS_EU_Contact__r.FirstName,ZTS_EU_Contact__r.LastName,ZTS_EU_Contact__r.ZTS_US_Job_Function__c,ZTS_EU_Contact__r.ZTS_US_Profession__c,ZTS_EU_Contact__r.Interface_Email__c,ZTS_EU_Contact__r.Email,ZTS_EU_Contact__r.Phone from ZTS_EU_Affiliations__c
                                                     where ZTS_EU_Account__c IN: listAccID AND ZTS_EU_Contact__c NOT IN: listContactId AND ZTS_EU_Contact__r.ZTS_EU_Contact_Status__c != 'Inactive' order by ZTS_EU_Contact__r.FirstName]){
                    categories.add(New ContactWrapper(aff));                          
                }
                system.debug('categories>>'+categories);     
                if(categories.size()==0)
                {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no contacts to select as camapign member')); 
                }
            } 
           
        
        
    
    
    /* Method Name  : saveContacts
    *  Description  : This method is used to save the selected contacts and create junction between Contact and Event
    *  Return type  : PageReference
    *  Parameters   : None
    */
    public PageReference saveContacts(){
        List<CampaignMember> lstCampMembers = new List<CampaignMember>();
        List<String> listConID = new List<String>();
        Integer countSelectedContact=0;
        String campId = ApexPages.currentPage().getParameters().get('campId');
        String accId = ApexPages.currentPage().getParameters().get('accIds');
        System.debug('categories----'+categories);
        System.debug('categories Size----'+categories.Size());
        for (ContactWrapper cw : categories) {
            if (cw.checked == true){
                listConID.add(cw.con.ZTS_EU_Contact__c);
                countSelectedContact ++;
            }
        }
        System.debug('listConID----'+listConID);
        List<CampaignMember> listExstCampMember = [select ContactId, CampaignId from CampaignMember 
                                                                    where ContactId IN: listConID and CampaignId =: campId];
        if(listExstCampMember != null && listExstCampMember.size() > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
        }
        else if(countSelectedContact==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: You need to select at least one contact'));
        }else{
            CampaignMemberStatus campMemStatusDefault = new CampaignMemberStatus();
            campMemStatusDefault = [Select label from CampaignMemberStatus where CampaignId =: campId AND IsDefault = True limit 1];
            for(String oConId: listConID){
                CampaignMember campMember = new CampaignMember(CampaignId=campId,ContactId=oConId,Status=campMemStatusDefault.label);
                System.debug('campMember----'+campMember);
                lstCampMembers.add(campMember);
            }
            
            System.debug('lstCampMembers----'+lstCampMembers);
            try{
                if(lstCampMembers != null && lstCampMembers.size() > 0){
                    System.debug('If loop');
                    insert lstCampMembers;
                    PageReference pg;
                    if(isAccsource == 'false')
                         pg = new PageReference('/'+campId);
                    else
                         pg = new PageReference('/'+accId.split(',')[0]);
                    pg.setRedirect(true);
                    return pg;
                }
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: The selected Contact(s) has already been added to the Event'));
            }
        }
        return null;
    }
    /* Method Name  : cancel
    *  Description  : This method is used to cancel the selection of contacts and return to the event detail page
    *  Return type  : PageReference
    *  Parameters   : None
    */
    public PageReference cancel(){
        String campId = ApexPages.currentPage().getParameters().get('campId');
        PageReference page = new PageReference('/'+campId);
        page.setRedirect(true);
        return page;
    }
    /* Method Name  : checkAll
    *  Description  : This method is used to cancel the selection of contacts and return to the event detail page
    *  Return type  : PageReference
    *  Parameters   : None
    */
    public PageReference CheckAll(){
        
        for(ContactWrapper contact : categories){
            contact.checked = allChecked;
        }
        
        return null;
    }
     
   
    public class ContactWrapper {
 
        public Boolean checked  { get; set; }
        public ZTS_EU_Affiliations__c con      { get; set;}
     
     
        public ContactWrapper(ZTS_EU_Affiliations__c c){
            con = c;
            checked = true;
        }
  }
 
}