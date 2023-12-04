/**
 * @description       : Logic for all US Contract triggers housed here.
 * @author            : David Stern @ Slalom
 * @group             : 
 * @last modified on  : 04-13-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   02-10-2020   David Stern @ Slalom        Created, Logic from all triggers moved to this class.
 * 1.1   04-13-2022   Ethan Hirsch @ Zoetis Inc   Change usage of ZTS_Utility.updateAccTeams to AccountService.setLeProgramOwnerToPrimaryForContractOwner
 * 1.2 	 05/24/2022	  Prasun @ Zoetis Inc	      Added space after LE as a part of SC-009560
 * 1.3   06/06/2023   Pooja @Cognizant            Added Logic for Account>>Contract Detail Tab>>LE Section fields based on latest Contract records
 * 1.4   10/17/2023	  Prasun @Cognizant			  TODEV-2041 Updated listening logic for MZR contract to EQ MZR 
**/
public class USContractTriggerService 
{
    public static void beforeInsert(List<Contract> triggerNew) 
    {
        if(ZTS_US_Contract_Utils.BeforeDML)
        {
            ZTS_US_Contract_Utils.UpdateDirector(triggerNew);
        }
        ZTS_US_Contract_Utils.diffCalc(triggerNew);
        ZTS_US_Contract_Utils.populateTerritoryOnContract(triggerNew);
        
        for (Contract con : triggerNew) 
        {
            if(con.ZTS_US_End_Date_Interface__c != null)
            {
                //con.Enddate = con.ZTS_US_End_Date_Interface__c; not writeable in INTL
            } 
        } 
    }
    
    public static void beforeUpdate(List<Contract> triggerOld, Map<Id, Contract> triggerOldMap, List<Contract> triggerNew, Map<Id, Contract> triggerNewMap) 
    {
        if(ZTS_US_Contract_Utils.BeforeDML)
        {
            ZTS_US_Contract_Utils.UpdateDirector(triggerNew);
        }
        ZTS_US_Contract_Utils.diffCalc(triggerNew);
        ZTS_US_Contract_Utils.populateTerritoryOnContract(triggerNew);
        
        if(ZTS_US_checkTriggerRun.runOnce())
        {
            ZTS_US_Contract_Utils.updateDeletedLocationSupplier(triggerNew);
        }
        ZTS_US_Contract_Utils.RequireRejectionComment(triggerNew, triggerOldMap);
        ZTS_US_Contract_Utils.statusUpdateOnUnanimousApprOrRejec(triggerNew, triggerOldMap);
        
        for (Contract con : triggerNew) 
        {
            if(con.ZTS_US_End_Date_Interface__c != null)
            {
                //con.Enddate = con.ZTS_US_End_Date_Interface__c; not writeable in INTL
            } 
        } 
    }
    
    public static void beforeDelete(List<Contract> triggerOld, Map<Id, Contract> triggerOldMap) 
    {
        if(ZTS_US_Contract_Utils.BeforeDML)
        {
            // empty list, as this is what would be sent to this method in a beforeDelete context (trigger New)
            ZTS_US_Contract_Utils.UpdateDirector(new List<Contract>());
        }
        // empty list, as this is what would be sent to this method in a beforeDelete context (trigger New)b 
        ZTS_US_Contract_Utils.diffCalc(new List<Contract>());
        ZTS_US_Contract_Utils.populateTerritoryOnContract(new List<Contract>());
    }
    public static void afterInsert(List<Contract> triggerNew, Map<Id, Contract> triggerNewMap) 
    {
        Map<ID, Account> parentOpps = new Map<ID, Account>();
        List<ID> listIds = new List<ID>();
        Set<Account> accts = new Set<Account>();
        Map<Id, Account> sobMap = new Map<Id, Account>();
        List<Id> quoteOwnersId = new List<Id>(); //TPDEV-482 Pooja R
        Map<Id, User> quoteOwners = new Map<Id, User>(); //TPDEV-482 Pooja R

        for (Contract childObj : triggerNew) 
        {
            listIds.add(childObj.AccountId);
            quoteOwnersId.add(childObj.OwnerId);//TPDEV-482 Pooja R
        }
        parentOpps = new Map<Id, Account>(
            [
                SELECT Id, ZTS_US_Contract_Tier__c, ZTS_US_MVP_Account__c, ZTS_US_MVP_BIOS__c,
                       ZTS_US_VGP_Enrollment_Status__c, MZR_PARAs_Account__c, MZR_PARAs_Enrollment_Date__c,
                       VGP_Enrollment_Date__c, MZR_Status__c, MZR_Enrollment_Date__c, LE_Enrollment_Date__c, 
                       LE_Effective_Pricing_Date__c, ZTS_US_LE_Account__c, ZTS_US_MZR_THERA_Enrollment_Date__c, 
                       ZTS_US_MZR_THERA_Account__c, ZTS_US_MZR_THERA_Tier__c, ZTS_US_MZR_THERA_Status__c, ZTS_US_MZR_PARAs_Status__c, ZTS_US_MZR_BIOS_Status__c,
                	   LE_Program_Owner__c, LE_Program_Owner_Email__c,
                       (SELECT Id, Name, ZTS_US_Current_Tier__c 
                        FROM Contracts) 
                FROM Account 
                WHERE Id IN :listIds
                  AND ZTS_EU_Market__c = 'United States'
            ]
        );
        
        quoteOwners = new Map<Id, User>(
            [SELECT Id, Name, Email 
             FROM User
             WHERE Id IN : quoteOwnersId]
        );
        
        for (Contract quote: triggerNew)
        {            
            if(quote.Profile_Name__c == 'Integration profile')
            {
                Account myParentOpp = parentOpps.get(quote.AccountID);
                User quoteOwner = quoteOwners.get(quote.OwnerId);
                //added space after LE as a part of SC-009560
                if(quote.name.contains('LE'))
                {
                    if(myParentOpp.ZTS_US_Contract_Tier__c != quote.ZTS_US_Current_Tier__c)
                    {
                        myParentOpp.ZTS_US_Contract_Tier__c = quote.ZTS_US_Current_Tier__c;
                        myParentOpp.LE_End_Date__c = quote.ZTS_US_End_Date_Interface__c; //TPDEV-482 Pooja R
                    } 
                    myParentOpp.LE_Enrollment_Date__c = quote.StartDate;
                    myParentOpp.LE_Effective_Pricing_Date__c = quote.StartDate; 
                    //TPDEV-482 Pooja R
                    if(quote.StartDate < System.today() && quote.ZTS_US_End_Date_Interface__c >= System.today() && quote.ZTS_US_Contract_Type__c =='Pricing Commitments')
                    	myParentOpp.ZTS_US_LE_Account__c = true;
                    if(quote.Contract_Type__c == 'Proposal'){
                    	myParentOpp.LE_Program_Owner__c = quoteOwner.Name;
                    	myParentOpp.LE_Program_Owner_Email__c = quoteOwner.Email; 
                    }                    
                }  
                
                //added MZR before Bios as a part of SC-010033
                else if(quote.name.containsIgnoreCase('MZR Bios'))
                {
                    myParentOpp.ZTS_US_MVP_Account__c = true;
                    myParentOpp.MZR_BIOS_Enrollment_Date__c = quote.StartDate;
                    myParentOpp.BIOS_End_Date__c = quote.EndDate;
                    myParentOpp.ZTS_US_MVP_BIOS__c = 'On Contract';
                    myParentOpp.ZTS_US_MZR_BIOS_Status__c = 'Active';

                } 
                else if(quote.name.containsIgnoreCase('VGP PETCARE STRATEGIC (REBATE)'))
                {
                    if(myParentOpp.VGP_Enrollment_Date__c == null)
                    {
                    myParentOpp.VGP_Enrollment_Date__c = quote.StartDate;
                    }
                    myParentOpp.ZTS_US_VGP_Enrollment_Status__c = 'VGP Enrolled';
                    myParentOpp.VGP_End_Date__c = quote.EndDate;
                    
                }
                else if(quote.name.containsIgnoreCase('PC MZR Paras'))
                {
                    myParentOpp.MZR_PARAs_Account__c = true;
                    myParentOpp.MZR_PARAs_Enrollment_Date__c = quote.StartDate; 
                    myParentOpp.ZTS_US_MZR_PARAs_Status__c= 'Active';
                 } 
                else if(quote.name.containsIgnoreCase('PC MZR Theras'))
                {
                    myParentOpp.ZTS_US_MZR_THERA_Account__c= true;
                    myParentOpp.ZTS_US_MZR_THERA_Enrollment_Date__c= quote.StartDate;  
                    myParentOpp.ZTS_US_MZR_THERA_Status__c = 'Active';
                } 

                else if(quote.name.containsIgnoreCase('EQ MZR Pricing')) //TODEV-2041 Updated listening logic for MZR contract to EQ MZR 
                {
                    myParentOpp.MZR_Status__c = 'Active';
                    myParentOpp.MZR_Enrollment_Date__c = quote.StartDate;
                    myParentOpp.MZR_End_Date__c = quote.EndDate;
                    myParentOpp.MZR_Account__c = true;
                }  
				//added space after LE as a part of SC-009560
                if(quote.name.containsIgnoreCase('LE ') && !quote.name.containsIgnoreCase('Strategic') && myParentOpp.MZR_Status__c == null && quote.EndDate > System.today())
                {
                    myParentOpp.MZR_Status__c = 'Eligible';
                    myParentOpp.MZR_Tier__c = null;
                    
                }
                else if(quote.EndDate > System.today()
                        && (myParentOpp.MZR_Status__c == null || myParentOpp.MZR_Status__c == 'Eligible') 
                        && (quote.name.containsIgnoreCase('Strategic') || 
                            (
                                myParentOpp.ZTS_US_VGP_Enrollment_Status__c  != null 
                                && (
                                    myParentOpp.ZTS_US_VGP_Enrollment_Status__c == 'VGP Enrolled' || myParentOpp.ZTS_US_VGP_Enrollment_Status__c.containsIgnoreCase('Accepted T&C')
                                   )
                            )
                           )
                       )
                {
                            myParentOpp.MZR_Status__c = 'Not Eligible';
                            myParentOpp.MZR_Tier__c = null;
                            myParentOpp.MZR_Accepted_Declined_Date__c = null;
                            myParentOpp.MZR_Enrollment_Start_Date__c = null;
                            myParentOpp.MZR_Enrollment_Date__c = null;
                } 
                sobMap.put(myParentOpp.id,myParentOpp);
            }
        }
        if(sobMap.Values().size() > 0)
        {
            update sobMap.Values();
        }
        ZTS_US_Contract_Utils.updateAccountContractDetails(triggerNew, null);
    }
    public static void afterUpdate(List<Contract> triggerOld, Map<Id, Contract> triggerOldMap, List<Contract> triggerNew, Map<Id, Contract> triggerNewMap) 
    {        
        Map<ID, Account> parentOpps = new Map<ID, Account>();
        List<ID> listIds = new List<ID>();
        Set<Account> accts = new Set<Account>();
        Map<Id, Account> sobMap = new Map<Id, Account>();
        for (Contract childObj : triggerNew) 
        {
            listIds.add(childObj.AccountId);
        }
        
        parentOpps = new Map<Id, Account>(
            [
                SELECT Id, ZTS_US_Contract_Tier__c, ZTS_US_MVP_Account__c, ZTS_US_MVP_BIOS__c,
                       ZTS_US_VGP_Enrollment_Status__c, MZR_PARAs_Account__c, MZR_PARAs_Enrollment_Date__c,
                       VGP_Enrollment_Date__c, MZR_Status__c, MZR_Enrollment_Date__c, LE_Enrollment_Date__c, LE_Effective_Pricing_Date__c, ZTS_US_MZR_THERA_Account__c, ZTS_US_LE_Account__c, ZTS_US_MZR_THERA_Enrollment_Date__c, ZTS_US_MZR_THERA_Tier__c,
                       (SELECT Id, Name, ZTS_US_Current_Tier__c 
                        FROM Contracts) 
                FROM Account 
                WHERE Id IN :listIds
                  AND ZTS_EU_Market__c = 'United States'
            ]
        );
        
        List<Contract> proposalApprovedProposalReadOnlyContracts = new List<Contract>(); 
        Id newProposalRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('New_Contract').getRecordTypeId();
        Id contrReadOnlyRecTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Contract_Read_Only').getRecordTypeId();
        for (Contract quote: triggerNew)
        {
            if((quote.RecordTypeId == newProposalRecTypeId || quote.RecordTypeId == contrReadOnlyRecTypeId) 
               && quote.status == 'Proposal Approved')
            {                                
                proposalApprovedProposalReadOnlyContracts.add(quote);
            }
            if(quote.Profile_Name__c == 'Integration profile')
            {
                Account myParentOpp = parentOpps.get(quote.AccountID);
                boolean accUpdateFlag = false;
                //added space after LE as a part of SC-009560
                if(quote.name.contains('LE ') && triggerOldMap.get(quote.id).StartDate != quote.StartDate)
                {
                    myParentOpp.LE_Effective_Pricing_Date__c = quote.StartDate;
                    accUpdateFlag = true;
                }
                
                if(!quote.name.containsIgnoreCase('PC MZR Paras') && quote.name.containsIgnoreCase('EQ MZR Pricing')) //TODEV-2041 Updated listening logic for MZR contract to EQ MZR 
                {
                    myParentOpp.MZR_End_Date__c = quote.EndDate;
                    accUpdateFlag = true;
                    if(quote.EndDate > System.today())
                    {
                        myParentOpp.MZR_Status__c = 'Active';
                        myParentOpp.MZR_Tier__c = quote.ZTS_US_Current_Tier__c ;
                        
                    }  
                } 
                
                if(triggerOldMap.get(quote.id).EndDate!=quote.EndDate)
                {    
                    if(myParentOpp.ZTS_US_Contract_Tier__c == quote.ZTS_US_Current_Tier__c && quote.name.containsIgnoreCase('LE'))
                    {
                        myParentOpp.LE_End_Date__c = quote.EndDate;
                        accUpdateFlag = true;
                    }    
                    //added MZR before Bios as a part of SC-010033
                     else if(quote.name.containsIgnoreCase('MZR Bios'))
                    {
                        myParentOpp.BIOS_End_Date__c = quote.EndDate;  
                        accUpdateFlag = true;
                    } 
                    else if(quote.name.containsIgnoreCase('VGP PETCARE STRATEGIC (REBATE)'))
                    {
                        myParentOpp.VGP_End_Date__c = quote.EndDate;
                        accUpdateFlag = true;
                    }
                    else if(!quote.name.containsIgnoreCase('PC MZR Paras') && quote.name.containsIgnoreCase('EQ MZR Pricing')) //TODEV-2041 Updated listening logic for MZR contract to EQ MZR 
                    {
                        myParentOpp.MZR_End_Date__c = quote.EndDate;
                        accUpdateFlag = true;
                        if(quote.EndDate < System.today())
                        {
                            myParentOpp.MZR_Accepted_Declined_Date__c = null;
                            myParentOpp.MZR_Enrollment_Start_Date__c = null;
                            myParentOpp.MZR_Enrollment_Date__c = null;
                            myParentOpp.MZR_Account__c = false;
                        } 
                    } 
                    if( quote.EndDate < System.Today() && quote.name.containsIgnoreCase('Strategic'))
                    {
                        myParentOpp.ZTS_US_VGP_Enrollment_Status__c = 'Un-enrolled in VGP';  
                        accUpdateFlag = true;
                    } 
                    if(quote.EndDate < System.Today() 
                       && (
                           quote.name.containsIgnoreCase('Strategic') 
                           || (myParentOpp.ZTS_US_VGP_Enrollment_Status__c != null && myParentOpp.ZTS_US_VGP_Enrollment_Status__c == 'Un-enrolled in VGP')
                          )
                      )
                    {
                        myParentOpp.MZR_Status__c = 'Eligible';
                        myParentOpp.MZR_Tier__c = null;
                        accUpdateFlag = true;
                    }  
                }
                if(accUpdateFlag)
                {
                    sobMap.put(myParentOpp.id,myParentOpp);     
                }                 
            }          
        }
        
        if (proposalApprovedProposalReadOnlyContracts.size() > 0) {
            AccountPositionsService.setLeProgramOwnerToPrimaryForContractOwner(proposalApprovedProposalReadOnlyContracts);
        }
        if(sobMap.Values().size() > 0)
        {
            update sobMap.Values();
        }
        
        ZTS_US_Contract_Utils.submitForApproval(triggerNew, triggerOldMap);
        ZTS_US_Contract_Utils.updateAccountContractDetails(triggerNew, triggerOldMap);
    }
}