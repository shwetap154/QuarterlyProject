/****************************************************************************************************************************************** 
* Class Name   : USOpportunityTriggerService
* Description  : Logic for all US Opportunity triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 26 June 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     06/26/2020          Created, Logic FROM all triggers moved to this class.
* Mila Imas               08/17/2021          update Acnt from Oprt
* Padma Nerella           06/17/2022          Update the Opportunity Trigger logic that copies "What PIMS Integration Wanted?" and "Carrier (UPS) / Courirer" from Opportunity to Account to also work for Zoetis Reference Lab Opportunities.TPBUILD-22
* Ethan Hirsch            06/22/2022          Change the mapping for setting Account.Other_Practice_Management_Software__c to be set to Opportunity.if_other_please_describe__c to make more logical sense TPBUILD-43
* Padma Nerella           08/2/2022           Accessing Custom metedate FieldForceSetting Stores Metadata related to Zoetis Field Force, including Name, and any other Field Force Specific Settings TPBuild-53
* Ethan Hirsch (Zoetis)   01/06/2023          Bypass the Account Trigger in the afterUpdate method to improve performance. (TPDEV-82)
*****************************************************************************************************************************************/
public class USOpportunityTriggerService 
{
    public static void beforeInsert(List<Opportunity> triggerNew) 
    {
        Id carystaRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CARYSTA_HVC').getRecordTypeId();
        Set<Id> accIds = new Set<Id>(); 

	for(Opportunity o : triggerNew)  
        {            
            if(o.RecordTypeId == carystaRecTypeId )
            {
                accIds.add(o.AccountId );  
            }
        }  

        Carysta_Default_Opportunity_Owner__c caryDefOwner = Carysta_Default_Opportunity_Owner__c.getInstance();
        User vacantUser = [SELECT Id,Name FROM User WHERE Name = 'Vacant Vacant' Limit 1 ];
        Map<Id, Id> accIdToEmpId = new Map<Id, Id>();
        Map<Id, Id> accIdToAreaEmpId = new Map<Id, Id>();

        for(List<Account> accs : [
            SELECT Id, 
                    (
                        SELECT Id, ZTS_Employee_ID__c, Territory_Type__c, ZTS_Field_Force_Name__c  
                        FROM Account_Positions__r 
                        WHERE  Territory_Type__c IN ('Territory','Area') 
                          AND ZTS_Field_Force_Name__c = :FieldForceSettingsService.FIELD_FORCE_DIAGNOSTICS 
                    ) 
            FROM Account WHERE Id in :accIds
        ])
        {
            for(Account acc: accs)
            {
                for(ZTS_EU_Account_Position__c aT : acc.Account_Positions__r)
                {
                    if(aT.Territory_Type__c == 'Area')
                    {
                        accIdToAreaEmpId.put(acc.Id, aT.ZTS_Employee_ID__c); 
                    }
                    else if(aT.Territory_Type__c == 'Territory')
                    {
                        accIdToEmpId.put(acc.Id, aT.ZTS_Employee_ID__c); 
                    } 
                }
            }
        }
   for(Opportunity o : triggerNew) 
        {
            if(o.RecordTypeId == carystaRecTypeId)
            {
                if((accIdToEmpId.size() > 0) 
                    && (accIdToEmpId.get(o.AccountId) != null)
                    && (vacantUser != null) 
                    && (accIdToEmpId.get(o.AccountId) != vacantUser.Id))
                {
                    o.OwnerId = accIdToEmpId.get(o.AccountId);
                }
                else if((accIdToAreaEmpId.size() > 0) 
                        && (accIdToAreaEmpId.get(o.AccountId) != null) 
                        && (vacantUser != null) 
                        && (accIdToAreaEmpId.get(o.AccountId) != vacantUser.Id))
                {
                    o.OwnerId = accIdToAreaEmpId.get(o.AccountId); 
                }
                else if(caryDefOwner.Default_Owner_Id__c != null)
                {
                    o.OwnerId = caryDefOwner.Default_Owner_Id__c;
                }
                if((accIdToAreaEmpId.size() > 0) && (accIdToAreaEmpId.get(o.AccountId) != null))
                {
                    o.Dx_ABM__c = accIdToAreaEmpId.get(o.AccountId);
                }
            }
        }

    }
    
    public static void afterInsert(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerNewMap)
    {
        List<Id> listOfIds = new List<Id>(); 
        List<OpportunityShare> opptyShrs  = new List<OpportunityShare>(); 
        List<Opportunity> carystaOpptys = new List<Opportunity>();
        List<Opportunity> opptys = new List<Opportunity>();
        
        for (Opportunity op : triggerNew) 
        { 
            listOfIds.add(op.Id);  
        }

        for(Opportunity opp : [
            SELECT Id, Name, Type, SAM__c, BSM__c, AccountId, CreatedById, RecordType.DeveloperName 
            FROM Opportunity 
            WHERE Id IN :listOfIds 
              AND RecordType.DeveloperName in ('People_First','Profit_Solver', 'CARYSTA_HVC') 
        ])

        {
            if(opp.Type != null && (opp.Type == 'CARYSTA HVC' || opp.Type == 'Diagnostics Equipment Lead'))
            {
                carystaOpptys.add(opp);
            }
            else
            {
                opptys.add(opp);
            }
        }

        if(!carystaOpptys.isEmpty())
        {
            for(Opportunity o : carystaOpptys)
            {
                OpportunityShare opptyShr  = new OpportunityShare();
                opptyShr.OpportunityId = o.Id;
                opptyShr.UserOrGroupId = o.CreatedById; 
                opptyShr.OpportunityAccessLevel = 'Edit';
                opptyShr.RowCause = Schema.OpportunityShare.RowCause.Manual;
                opptyShrs.add(opptyShr);                
            }
        }
    
        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
        Map< Id , Id > opportunityIdToAccountId = new Map< Id , Id >(); 
        List<Id> opptyCreatorIds = new List<Id>();

        for(Opportunity o : opptys)  
        {             
            opportunityIdToAccountId.put(o.Id, o.AccountId); 
            opptyCreatorIds.add(o.CreatedById);
        }

        Map<Id,String> FFNames = new Map<Id,String>();
        for(ZTS_EU_Position__c ut : [
            SELECT Id,ZTS_EU_Employee__r.Id,ZTS_EU_Territory__c,ZTS_EU_Territory__r.ZTS_Field_Force_Name__c 
            FROM ZTS_EU_Position__c 
            WHERE ZTS_EU_Employee__c != null 
              AND ZTS_EU_Employee__r.Id in : opptyCreatorIds
        ])
        {
            if(FFNames.get(ut.ZTS_EU_Employee__r.Id) == null)
            {
                FFNames.put(ut.ZTS_EU_Employee__r.Id, ut.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c);
            }
            else
            {
                String st = FFNames.get(ut.ZTS_EU_Employee__r.Id);
                FFNames.put(ut.ZTS_EU_Employee__r.Id, st + ',' + ut.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c);
            }  
        }

        String BSMrole = '';
        String SAMrole = '';
        
        List<Territory_Role_Matrix__c> trm = Territory_Role_Matrix__c.getall().values();  
        for(Territory_Role_Matrix__c role : trm)
        {
            if(role.Name == 'BSM')
            {
                BSMrole = role.Role_Value__c;
            }
            else if(role.Name == 'SAM')
            {
                SAMrole = role.Role_Value__c;
            }
        } 
        
        Map<Id, List<ZTS_EU_Account_Position__c>> accountIdToAccountTeamMembers = new Map<Id, List<ZTS_EU_Account_Position__c>>();
        for(ZTS_EU_Account_Position__c accountTeamMember : [
            SELECT a.ZTS_EU_Employee__c, a.ZTS_EU_Territory__c, a.ZTS_AccountTerritory__c, a.ZTS_EU_Position__r.ZTS_EU_Employee__c, 
                   a.Id, a.ZTS_EU_Account__r.Id, ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_TerritoryRole__c,
                   ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c
            FROM ZTS_EU_Account_Position__c a
            WHERE (a.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_TerritoryRole__c = :BSMrole 
                    OR a.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_TerritoryRole__c = :SAMrole) 
               AND a.ZTS_EU_Account__r.Id in :opportunityIdToAccountId.values() 
        ])   
        {  
            List<ZTS_EU_Account_Position__c > accountTeamMembers = ( 
                accountIdToAccountTeamMembers.get(accountTeamMember.ZTS_EU_Account__r.Id) == null) ?
                    new List<ZTS_EU_Account_Position__c >() :
                    accountIdToAccountTeamMembers.get(accountTeamMember.ZTS_EU_Account__r.Id); 

            accountTeamMembers.add(accountTeamMember);
            accountIdToAccountTeamMembers.put(accountTeamMember.ZTS_EU_Account__r.Id, accountTeamMembers);
        }
            
        //Below code is to derive BSM FROM related Account Team members and also create a sharing rule to the opportunity creator
        for(Opportunity o : opptys)
        {
            Id accountId  = opportunityIdToAccountId.get(o.Id);
            if(accountIdToAccountTeamMembers.get(accountId) != null)
            {
                for (ZTS_EU_Account_Position__c accountTeamMember : accountIdToAccountTeamMembers.get(accountId))  
                {
                    if(accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Employee__c != null)
                    {
                        if(accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_TerritoryRole__c == SAMrole)
                        {
                            if(o.SAM__c == null && FFNames.get(o.CreatedById) != null 
                               && accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c != null
                               && (((FFNames.get(o.CreatedById)).contains(accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c)) 
                                   || ((accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_Field_Force_Name__c).contains(FFNames.get(o.CreatedById))))
                              )
                              {
                                  o.SAM__c = accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Employee__c;
                              }  
                        }
                        else if((o.BSM__c == null) && (accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Territory__r.ZTS_TerritoryRole__c == BSMrole))
                        {
                            o.BSM__c = accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Employee__c;                         
                            o.OwnerId = accountTeamMember.ZTS_EU_Position__r.ZTS_EU_Employee__c;                        
                            OpportunityShare opptyShr  = new OpportunityShare();
                            opptyShr.OpportunityId = o.Id;
                            opptyShr.UserOrGroupId = o.CreatedById; 
                            opptyShr.OpportunityAccessLevel = 'Edit';
                            opptyShr.RowCause = Schema.OpportunityShare.RowCause.Manual;
                            opptyShrs.add(opptyShr);
                        } 
                    } 
                }
            }
        }
        
        update opptys;
         
        if(!opptyShrs.isEmpty()) Database.SaveResult[] result = Database.insert(opptyShrs,false); 
    }
//mi added below
    public static void afterUpdate(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerNewMap)
    {
        List<Id> listOfIds = new List<Id>(); 
        Map<Id,Opportunity> opptys = new Map<Id,Opportunity>();
        Map<id,string> optValue = new Map<id,string>();
        system.debug('USOpportunityTriggerService afterUpdate updating === >');
        Id reflabRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Non_Quoting').getRecordTypeId();
        Id zoetisReflabRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Zoetis_Reference_Labs_Opportunity').getRecordTypeId();
        //	This is to support Lead Forecasting probability to sale of new Diagnostic Equipment

        Set<Id> accIds = new Set<Id>(); 
        
        for(Opportunity o : triggerNew)  
        {      
            system.debug('USOpportunityTriggerService afterUpdate What_PIMS_integration_wanted__c value === >' + o.What_PIMS_integration_wanted__c );
            system.debug('o.StageName  ===> ' + o.StageName );
            system.debug('zoetisReflabRecTypeId  ===> ' + zoetisReflabRecTypeId );
            if (((o.StageName == 'Closed/Installed (100%)') || (o.StageName =='Closed/Lost') &&
             (o.RecordTypeId == reflabRecTypeId) &&
              (o.LeadSource =='Reference Lab Lead')) ||
              ((o.StageName == 'Closed/Installed (100%)') &&
             (o.RecordTypeId == zoetisReflabRecTypeId))){
                  system.debug('o.AccountId '+o.AccountId);
                if (o.What_PIMS_integration_wanted__c != '')
                {
                    system.debug('o.AccountId '+o.AccountId);
                    accIds.add(o.AccountId );  
                    opptys.put(o.AccountId,o);
                }
            }
        }  
        List<Account> updAcnts = new List<Account>();
        for (Account acnt :[select id,name,Practice_Management_Software__c, Other_Practice_Management_Software__c,Send_In_Courier__c from Account where id =: accIds] ) 
        { 
            if (acnt.Practice_Management_Software__c != opptys.get(acnt.id).What_PIMS_integration_wanted__c){
                acnt.Practice_Management_Software__c = opptys.get(acnt.id).What_PIMS_integration_wanted__c;
                if (opptys.get(acnt.id).What_PIMS_integration_wanted__c == 'Other'){
                    // Other_Practice_Management_Software__c has a smaller max length than if_other_please_describe__c.
                    // Truncate any extra text to prevent an error.
                    integer otherSoftwareMaxLength = Schema.SObjectType.Account.fields.Other_Practice_Management_Software__c.getLength();
                    String opportunityOtherSoftwareValue = opptys.get(acnt.id).if_other_please_describe__c;
                    if (String.isNotEmpty(opportunityOtherSoftwareValue) && opportunityOtherSoftwareValue.length() > otherSoftwareMaxLength) {
                        opportunityOtherSoftwareValue = opportunityOtherSoftwareValue.substring(0, otherSoftwareMaxLength);
                    }

                    acnt.Other_Practice_Management_Software__c = opportunityOtherSoftwareValue;
                }

                acnt.Send_In_Courier__c = opptys.get(acnt.id).Carrier_UPS_Courier__c;
                updAcnts.add(acnt);
            }       
        }
        if (updAcnts.size() > 0){
            // Bypass the Account Trigger. The updates made here do not kick off any other trigger logic
            DispatchTriggerHandler.bypass('AccountTriggerHandler');
            update updAcnts;
            DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        }
    }
}