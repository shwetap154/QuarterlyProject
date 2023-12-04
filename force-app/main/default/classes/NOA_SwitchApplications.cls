//TBD - history
global class NOA_SwitchApplications {
    
    public NOA_SwitchApplications(ApexPages.StandardController controller){
        
    }
    
    webservice static String convertVetToRepro(Id leadId){        
        Id vetRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Licensed_Vet').getRecordTypeId();
        Id reprodRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Online_Account_Diagnostic_or_Reproduction').getRecordTypeId();
           
        
        //Online Account - Licensed Vet    Online Account - Diagnostic or Reproduction
        Lead lead = fetchLeadDetails(leadId);
        
        if(lead != null && lead.RecordTypeId == vetRecTypeId){
            
            lead.RecordTypeId = reprodRecTypeId;  
            lead.Existing_account_with_Zoetis_at_this_Loc__c = null;
            lead.Existing_account_with_Zoetis__c = null;
            lead.Existing_Account_Name__c = null;
            lead.Zoetis_Account__c = null;
            lead.Total_number_of_practitioners__c = null;
            lead.Eggs__c = null;
            lead.Poultry__c = null;
            lead.Turkey__c = null;
            lead.Broiler__c = null;
            lead.Authorization_Email__c = null;
            /*
            lead.Business_Permit_or_License_Number__c = null;
            lead.Ownership_Type__c = null;
            lead.SP_Name__c = null;
            lead.SP_Telephone__c = null;
            lead.SP_Email__c = null;
            lead.SP_Fax__c = null;
            lead.SP_Address__c = null;
            lead.SP_County__c = null;
            lead.SP_City__c = null;
            lead.SP_State__c = null;
            lead.SP_Zip__c = null;
            lead.Partership_Name__c = null;
            lead.Partnership_Title_or_Officer_Info_1__c = null;
            lead.Partership_City__c = null;
            lead.Partership_Address__c = null;
            lead.Partership_County__c = null;
            lead.Partership_State__c = null;
            lead.Partership_Zip__c = null;
            lead.Partership_Telephone__c = null;
            lead.Partership_Email__c = null;
            lead.Partership_Fax__c = null;
            lead.Partership_Name_2__c = null;
            lead.Partnership_Title_or_Officer_Info_2__c = null;
            lead.Partership_City_2__c = null;
            lead.Partership_Address_2__c = null;
            lead.Partership_County_2__c = null;
            lead.Partership_State_2__c = null;
            lead.Partership_Zip_2__c = null;
            lead.CLG_Name__c = null;
            lead.CLG_Company__c = null;
            lead.CLG_Address__c = null;
            lead.CLG_City__c = null;
            lead.CLG_County__c = null;
            lead.CLG_State__c = null;
            lead.CLG_Zip__c = null;
            lead.CLG_Telephone__c = null;
            lead.CLG_Fax__c = null;
            lead.CLG_Email__c = null;
            lead.Buyer_Name__c = null;
            lead.Buyer_Phone__c = null;
            lead.Years_in_Business__c = null;
            lead.Controller_Name__c = null;
            lead.Controller_Phone__c = null;
            lead.Accounts_Payable_Contact_Name__c = null;
            lead.Accounts_Payable_Contacts_Phone__c = null;
            lead.Has_your_company_filed_bankruptcy__c = null;
            lead.Type_of_bankruptcy__c = null;
            lead.Bankrupt_File_Date__c = null;
*/
            lead.Step_Number__c = 1;
            lead.Signature_Status__c = null;
            lead.Status = 'Open';
            
            List<Veterinarian_Information__c> vetList = [SELECT Id FROM  Veterinarian_Information__c WHERE Lead__c = :leadId]; 
            if(vetList != null && vetList.size() > 0){
                try{
                    delete vetList;
                }catch(Exception ex){
                    System.debug('Error deleting veterinarian records for lead: ' + leadId);
                    return 'Error: Unable to delete veterinarian records for the lead';
                }
            }
            
        }else if(lead != null && lead.RecordTypeId == reprodRecTypeId){             
            lead.RecordTypeId = vetRecTypeId;  
            lead.Type_of_Business__c = null;
            lead.Business_Other__c = null;
            lead.Step_Number__c = 1;
            lead.Signature_Status__c = null;
            lead.Status = 'Open';
            
        }else{
            System.debug('Error: This lead record cannot be converted. Lead Id: ' + leadId);
            return 'Error: This lead record cannot be converted';
        }
        
        try{
            update lead;
            
        }catch(Exception ex){
            System.debug('Error: Unable to convert lead application. Lead Id: ' + leadId + ' :: ' + ex);
            return 'Error: Unable to convert lead application. \n' + ex;    
        }  
        
        return 'Application converted successfully';
        
    }
    
    private static Lead fetchLeadDetails(Id id){
        Lead l = [SELECT Id,Name,Salutation,FirstName,LastName,NOA_Application_Number__c, Step_Number__c,Email,  Phone,  Company,Business_Name__c,
                  Small_Animal__c, Equine__c,  Beef__c,  Dairy__c,  Swine__c,  Feed__c,  Poultry__c,  Eggs__c,  Turkey__c,  Broiler__c,  
                  Shipping_Street_1__c,  Shipping_Street_2__c,  Shipping_County__c,  Shipping_City__c,  Shipping_State__c,  
                  Shipping_Zip_Code__c,  Shipping_Phone__c,  Shipping_Fax__c,Shipping_Email__c,  Billing_Street_1__c,  
                  Billing_Street_2__c,  Billing_County__c,  Billing_City__c,  Billing_State__c,  Billing_Zip_Code__c,  
                  Billing_Phone__c,  Billing_Fax__c,  Billing_Email__c,Applicant_Role__c,Existing_account_with_Zoetis_at_this_Loc__c,
                  Ownership_Change__c,  Date_of_Ownership_Change__c,  Existing_account_with_Zoetis__c,  Existing_Account_Name__c,  
                  Zoetis_Account__c,  Sales_Tax_Status__c,  Tax_Permit__c,  Business_Permit_or_License_Number__c,  Ownership_Type__c,  
                  SP_Name__c,  SP_Address__c,  SP_City__c,  SP_County__c,  SP_State__c,  SP_Zip__c,  SP_Telephone__c,  SP_Fax__c,  SP_Email__c, Status,
                  Partership_Name__c,  Partnership_Title_or_Officer_Info_1__c,  Partership_Address__c,  Partership_City__c,  Partership_County__c,  Partership_State__c,  
                  Partership_Zip__c,  Partership_Name_2__c,  Partnership_Title_or_Officer_Info_2__c,  Partership_Address_2__c,  Partership_City_2__c,  Partership_County_2__c,  
                  Partership_State_2__c,  Partership_Zip_2__c,  Partership_Telephone__c,  Partership_Fax__c,  Partership_Email__c,CLG_Name__c,  
                  CLG_Company__c ,  CLG_Address__c,  CLG_City__c,  CLG_County__c,  CLG_State__c,  CLG_Zip__c,  CLG_Telephone__c,  CLG_Fax__c,  CLG_Email__c,
                  Buyer_Name__c,  Buyer_Phone__c,  Years_in_Business__c,  Controller_Name__c,  Controller_Phone__c,  Accounts_Payable_Contact_Name__c,  
                  Accounts_Payable_Contacts_Phone__c,  Has_your_company_filed_bankruptcy__c,  Type_of_bankruptcy__c,  Bankrupt_File_Date__c,
                  Principal_Bank_Name__c,Principal_Bank_Phone__c,Trade_Reference_1_Company_Name__c,
                  Trade_Reference_1_Company_Phone__c,Trade_Reference_2_Company_Name__c,Trade_Reference_2_Company_Phone__c,Trade_Reference_3_Company_Name__c,Type_of_Business__c,
                  Trade_Reference_3_Company_Phone__c,Contact_Preference__c,RecordTypeId,Total_number_of_practitioners__c,Signature_Status__c,Adobe_eSigned_PDF__c,Business_Other__c,
                  additional_comments__c
                  FROM Lead where Id = :id AND Market__c = 'United States' LIMIT 1][0];
        return l;
    }
}