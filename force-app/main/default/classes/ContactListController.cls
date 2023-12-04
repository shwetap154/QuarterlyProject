public with sharing class ContactListController {

    private ApexPages.StandardSetController standardController;

    public ContactListController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference doRedirect()
    {       
        List<Contact> selectedConts = (List<Contact>) standardController.getSelected();
        List<String> selectedRecs = new List<String>();
        String idString;     

        if (selectedConts.size() >= 1){
            for(Contact selectedContact : selectedConts)
            {
                selectedRecs.add(selectedContact.id);
            }       
            idString = string.join(selectedRecs,',');
            pageReference pg = new pageReference('/apex/ZTS_US_Add_Account_Redirect?ContactRecords=' +idString);
            return pg.setRedirect(true);
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one record.');
            ApexPages.addMessage(myMsg);
            return null;
        }   
    }
}