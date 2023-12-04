/****************************************************************************************************************************************** 
* CLass Name : TestLeadListController
* Description  : Controller test for new buttons (that used to be JS) on Lead object
* Created By   : Slalom(David Stern) 
* Created Date : 4th June, 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern            06/04/2020          Created 
*****************************************************************************************************************************************/
@isTest
public class TestLeadListController 
{
    private static Id vetRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
    private static Id reprodRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Diagnostic_or_Reproduction').getRecordTypeId();
    
    @testSetup
    public static void testSetup()
    {        
        Lead lead = new Lead();
        lead.FirstName='t$1c1688964aa44b9cb15119544a01011cf1zr$';
        lead.LastName = 't$1c1688964aa44b9cb15119544a01011cf1zr$';
        lead.Company = 'Company';
        lead.Market__c = 'United States';
        lead.RecordTypeId = vetRecTypeId;
        insert lead;
    }
    
    @isTest
    public static void testDoMakePrimaryRedirect()
    {
        Lead lead = [
            SELECT Id
            FROM Lead
            LIMIT 1
        ];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(lead);
        PageReference LeadConvertReproToVetAndBackPage = Page.LeadConvertReproToVetAndBack;
        Test.setCurrentPage(LeadConvertReproToVetAndBackPage);
        
        LeadListController controller = new LeadListController(sc);
        controller.switchRecordTypes();
        
        System.assertEquals([SELECT Id, RecordTypeId FROM Lead LIMIT 1].RecordTypeId, reprodRecTypeId);

        PageReference pg = controller.goBackToLead();
        System.assertEquals(pg.getUrl(), '/' + lead.Id);
    }
}