public class ZTS_US_accountContactAffController {
    public String accntId {get;set;}
    public Boolean renderButton {get;set;}
    public String conId {get;set;}
    public Boolean fromCon {get;set;}
    public Boolean renProf {get;set;}
    public Boolean editFunc {get;set;}
    public ZTS_EU_Affiliations__c accConAff {get;set;}
    public ZTS_US_accountContactAffController(ApexPages.StandardController controller) {
        renProf = false;
        renderButton = false;
        fromCon = false;
        editFunc = false;
        accConAff = new ZTS_EU_Affiliations__c();
        accConAff.Name = '-Autopopulates on Save-';
        accntId = ApexPages.currentPage().getParameters().get('accntId');
        conId = ApexPages.currentPage().getParameters().get('conId');
        if(accntId != Null && conId == Null){          
            accConAff.ZTS_EU_Account__c = accntId;
        }
        else if(conId != Null && accntId == Null){
            fromCon = true;
            accConAff.ZTS_EU_Contact__c = conId;
            populateProfValue();
        }
        else{
            Id accConId = ApexPages.currentPage().getParameters().get('Id');
            accConAff = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Contact__c, ZTS_US_Profession__c, ZTS_EU_Affiliation_Status__c, ZTS_US_LE_Contact__c, ZTS_US_Job_Function__c,Profit_Solver_Contact__c, ZTS_EU_Account_influence__c,Key_Contact__c,eCommerce_Eligible__c,ZTS_EU_Market_from_Parent__c from ZTS_EU_Affiliations__c where Id = :accConId];
            accntId = accConAff.ZTS_EU_Account__c;
            conId = accConAff.ZTS_EU_Contact__c;
            editFunc = true;
            renProf = true;
            renderButton = (accConAff.ZTS_EU_Market_from_Parent__c == 'United States') ? false : true;
        }                   
     }
     public void populateProfValue(){
       system.debug('--------------contact id: ');
       renProf = true;
       Contact conIns = [Select Id, Name, ZTS_US_Profession__c, AccountId From Contact where Id =: accConAff.ZTS_EU_Contact__c limit 1];
       accConAff.ZTS_US_Profession__c = conIns.ZTS_US_Profession__c;
       //accConAff.ZTS_EU_Account__c = conIns.AccountId;
    }
    
    public PageReference save(){
        try{
            if(editFunc){
                update accConAff;
            }else{
            insert accConAff;
            }
            PageReference pg = new PageReference('/'+accntId);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            System.debug('Error when insert'+ e.getMessage()); //TPDEV-733 Pooja: to show single line error message in Account Contact Affilation
            if(e.getMessage().contains('duplicate value'))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate record Exists, Cannot be saved.'));
            else if(!e.getMessage().contains('Make Primary')) //TPDEV-733 Pooja: to show single line error message in Account Contact Affilation
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
    public PageReference saveCon(){
        try{
            if(editFunc){
                update accConAff;
            }else{
            insert accConAff;
            }
            PageReference pg = new PageReference('/'+conId);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            if(e.getMessage().contains('duplicate value'))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate record Exists, Cannot be saved.'));
            else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
    public PageReference doRedirect()
    {
        //if is INTL AccContactAffiliation then do Edit view 
        if (accConAff.ZTS_EU_Market_from_Parent__c != 'United States' && editFunc) {
            try {
                String returnUrl = '/lightning/cmp/c__EditAccContAffIntl?c__recordId='+accConAff.Id;
                PageReference pgReturnPage = new PageReference(returnUrl);
                pgReturnPage.setRedirect(true);
                return pgReturnPage;
            } catch(Exception e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                return null;
            }
        }
        else {
            renderButton = true;
            return null;
        }
    }
}