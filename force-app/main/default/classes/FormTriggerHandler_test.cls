/****************************************************************************************************************************************** 
 * Trigger Name : FormTriggerHandler_test
 * Description  : Test Class for FormTriggerService, FormTrigger, FormTriggerHandler.
 * Created By   : Aritra (Cognizant)
 * Created Date : 29th Oct, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra Chakraborty      10/29/2021          Created 
******************************************************************************************************************************************/
@isTest
public class FormTriggerHandler_test {
    
    @testSetup
	public static void setup() { 
        
        User IDSM = ZTS_EU_DataUtilityTest.createUserWithProfile('US Inside Sales Manager',false);
        IDSM.ZTS_EU_Market__c = 'United States';
        IDSM.Default_Country__c ='United States';
        insert IDSM;
        User IDSR = ZTS_EU_DataUtilityTest.createUserWithProfile('US Inside Sales Rep',false);
        IDSR.ZTS_EU_Market__c = 'United States';
        IDSR.Default_Country__c ='United States';
        insert IDSR;
        
    }
    //Covered both insert and update functionality in same test method, as to update a record we need to insert the record first and that will test the insert functionality
    static testmethod void beforeInsertUpdateTest()
    {	
        User IDSM = [Select Id from User where profile.Name = 'US Inside Sales Manager' and IsActive=true limit 1][0];
        User IDSR = [Select Id from User where profile.Name = 'US Inside Sales Rep' and IsActive=true  limit 1][0];
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName().get('ACP_Accreditation').getRecordTypeId();  
        Form__c f1 = new Form__c();
        system.runAs(IDSM)
        {
            f1.RecordTypeId = acpRecordTypeId;
            f1.IDSM__c = IDSM.Id;
            f1.IDSR__c = IDSR.Id;
            f1.Date__c = system.today();
            f1.ACP_Topic__c = 'Second Time Purchase';
            f1.Asks_for_the_Business__c = 'Exceeds (E)';
            f1.Call_Selling_Materials__c = 'Exceeds (E)';
            f1.Identify_Confirm_Customer_Needs__c = 'Exceeds (E)';
            f1.Opening_the_Call__c = 'Met Expectations (ME)';
            f1.Technical_Fluency__c = 'Exceeds (E)';
            f1.Status__c = 'New';
            f1.Copy_Comments__c = false;
            
            insert f1;
            
            //f1.Call_Selling_Materials__c= 'Met Expectations (ME)';
            //update f1; 
            
            
            f1.Status__c= 'Pending Rep\'s Comments';
            f1.Copy_Comments__c = true;
            update f1; 
            
        }
        
        String result = [Select Accreditation_Status__c from Form__c where Id = :f1.Id][0].Accreditation_Status__c;
        System.assertEquals('Accredited', result);
        
        
        
        List<Form__Share> fs = [Select Id from Form__Share where ParentId = :f1.Id];
        system.debug(fs);
        System.assertEquals(2, fs.size());
        
        delete f1;
    }
    
    //This method will test the submit button action from Manager's login
    static testmethod void acp_StatusUpdateManagerTest()
    {	
        User IDSM = [Select Id from User where profile.Name = 'US Inside Sales Manager' and IsActive=true limit 1][0];
        User IDSR = [Select Id from User where profile.Name = 'US Inside Sales Rep' and IsActive=true  limit 1][0];
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName().get('ACP_Accreditation').getRecordTypeId();  
        Form__c f1 = new Form__c();
        system.runAs(IDSM)
        {
            f1.RecordTypeId = acpRecordTypeId;
            f1.IDSM__c = IDSM.Id;
            f1.IDSR__c = IDSR.Id;
            f1.Date__c = system.today();
            f1.ACP_Topic__c = 'First Time Purchase';
            f1.Asks_for_the_Business__c = 'Exceeds (E)';
            f1.Call_Selling_Materials__c = 'Exceeds (E)';
            f1.Identify_Confirm_Customer_Needs__c = 'Exceeds (E)';
            f1.Opening_the_Call__c = 'Met Expectations (ME)';
            f1.Technical_Fluency__c = 'Exceeds (E)';
            f1.Status__c = 'New';
            f1.Copy_Comments__c = false;
            
            insert f1;
            
            //f1.Call_Selling_Materials__c= 'Met Expectations (ME)';
            //update f1; 
            
            ACP_StatusUpdateAndNotify.acpUpdStatusAndNotify(f1.Id);
            
        }
       
        
        String result = [Select Status__c from Form__c where Id = :f1.Id][0].Status__c;
        System.assertEquals('Pending Rep\'s Comments', result);
    }
    
    //This method will test the submit button action from Manager's login
    static testmethod void acp_StatusUpdateRepTest()
    {	
        User IDSM = [Select Id from User where profile.Name = 'US Inside Sales Manager' and IsActive=true limit 1][0];
        User IDSR = [Select Id from User where profile.Name = 'US Inside Sales Rep' and IsActive=true  limit 1][0];
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByDeveloperName().get('ACP_Accreditation').getRecordTypeId();  
        Form__c f1 = new Form__c();
        
            f1.RecordTypeId = acpRecordTypeId;
            f1.IDSM__c = IDSM.Id;
            f1.IDSR__c = IDSR.Id;
            f1.Date__c = system.today();
            f1.ACP_Topic__c = 'First Time Purchase';
            f1.Asks_for_the_Business__c = 'Exceeds (E)';
            f1.Call_Selling_Materials__c = 'Exceeds (E)';
            f1.Identify_Confirm_Customer_Needs__c = 'Exceeds (E)';
            f1.Opening_the_Call__c = 'Met Expectations (ME)';
            f1.Technical_Fluency__c = 'Exceeds (E)';
            f1.Status__c = 'New';
            f1.Copy_Comments__c = false;
            
            insert f1;
            
            f1.Status__c= 'Pending Rep\'s Comments';
            update f1; 
            
            
        
        system.runAs(IDSR)
        {
            f1.Rep_Comments__c = 'I am happy!!';
            update f1;
			ACP_StatusUpdateAndNotify.acpUpdStatusAndNotify(f1.Id);            
        }
       
        
        String result = [Select Status__c from Form__c where Id = :f1.Id][0].Status__c;
        System.assertEquals('Completed', result);
    }
    
}