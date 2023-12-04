/*
* @Name: ZTS_US_Contract_Utils
* @Desciption: Utils Class for the trigger on Contract.
*              1.Updates the Director field of the Contract with the Manager's Manager of the Contract Owner.
*              2.Used for making the Comment field of Approval Process mandatory when the record is rejected.
*              3.Used for conditional field update on Unanimous/Non-Unanimous Approval & Rejection.
*              4.Used to submit the Contract automatically to next level of Approval once the Contract is already Submitted manually(click on "Submit for Approval" button).
*              5.Calculates Diff between (Proposed Tier-Current Tier) & (Proposed Tier-Review Committe Proposed Tier) Custom setting values and updates the field on the Contract record.
*              6.Update Account Contract Tier whenever a contract is created/updated.
*              7.Stamps the Territory on the Contract
* @date Created:April 28, 2014
* @author Ketan Prakash Singh
* Update log:
*    Updated By                      Date                    Purpose/Reference
*    Abir Bhattacharya               08/02/2017              Changed for Enhancement Request(SC-002287)
*    Shiva Kudikilla                 05/07/2018              SC-002553 Update MZR BIOS Tier Field on Account with new Tier value extracted from Contract feed
*    Shiva Kudikilla                 11/12/2018              SC-002663 Updated to populate program owner
*    Ethan Hirsch @ Zoetis           04/13/2022              Remove updateAccTeam method. This logic has been moved to AccountPositionsService.
*	 Prasun Dubey @ Cognizant		 13/10/2023				 TPDEV-2041 Added listen logic for LVS and DX MZR contracts
*/
public class ZTS_US_Contract_Utils{

    public static boolean isSubmitted = true;
    public static boolean ApprovalSubmitted = true;
    public static boolean BeforeDML = true;
    @testVisible static final String APPROVAL_PROCESS_ERROR_ORIGIN = 'ZTS_US_Contract_Utils - submitForApproval(): Execute Approval Process';
    

    
    public static void UpdateDirector(List<Contract> lstContract){
        Set<Id> setConOwnId = new Set<Id>();
        List<User> lstUser = new List<User>();
        
        system.debug('@@@@@@@@@@@@@lstContract is: '+lstContract);
        if(lstContract != null && lstContract.size() > 0){
            for(Contract contr: lstContract){
                setConOwnId.add(contr.OwnerId);
            }
        }
        system.debug('@@@@@@@@@@@@@setConOwnId is: '+setConOwnId);
        
        lstUser = [Select u.Name, u.ManagerId, u.Id, u.Manager.ManagerId, u.Manager.Username From User u where u.Id in :setConOwnId AND ZTS_EU_Market__c = 'United States' ];
        system.debug('@@@@@@@@@@@@@lstUser is: '+lstUser);
        
        if(lstContract != null && lstContract.size() > 0){
            for(Contract contr: lstContract){
                if(lstUser != null && lstUser.size() > 0){
                    for(User objUser: lstUser){
                        if(contr.OwnerId == objUser.Id && lstUser.size() > 0){
                            BeforeDML = false;
                            contr.ZTS_US_Contract_Manager__c = objUser.Manager.ManagerId;
                        }
                    }
                }
            }
        }
         system.debug('@@@@@@@@@@@@@lstContract is: '+lstContract);
         //system.debug('@@@@@@@@@@@@@lstContract is: '+lstContract);
         system.debug('@@@@@@@@@@@@@BeforeDML is: '+BeforeDML);
    }  
    
    
    public static void RequireRejectionComment(List<Contract> lstContract,Map<ID,Contract> contractOldMap){
    
      Map<Id, Contract> rejectedStatements = new Map<Id, Contract>{}; 
      for(Contract objContr: lstContract)
      {
        /* 
          Get the old object record, and check if the approval status 
          field has been updated to rejected. If so, put it in a map 
          so we only have to use 1 SOQL query to do all checks.
        */
        Contract oldobjContr = contractOldMap.get(objContr.Id);
    
        if (oldobjContr.ZTS_US_Approval_Status__c != 'Rejected' 
         && objContr.ZTS_US_Approval_Status__c == 'Rejected')
        { 
          rejectedStatements.put(objContr.Id, objContr);  
        }
      }
       
      if (!rejectedStatements.isEmpty())  
      {
        // Get the most recent approval process instance for the object.
        // If there are some approvals to be reviewed for approval, then
        // get the most recent process instance for each object.
        List<Id> processInstanceIds = new List<Id>{};
        
        for (Contract objContr : [SELECT (SELECT ID
                                                  FROM ProcessInstances
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1)
                                          FROM Contract
                                          WHERE ID IN :rejectedStatements.keySet() 
                                          AND ZTS_EU_Market__c = 'United States'])
        {
            System.debug('$$$ objContr'+objContr);
            System.debug('$$$ Contract Id --'+rejectedStatements.keySet());
            processInstanceIds.add(objContr.ProcessInstances[0].Id);
        }
          
        // Now that we have the most recent process instances, we can check
        // the most recent process steps for comments.  
        for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                   FROM ProcessInstance
                                   WHERE Id IN :processInstanceIds
                                   ORDER BY CreatedDate DESC])   
        {                   
          if ((pi.Steps[0].Comments == null || 
               pi.Steps[0].Comments.trim().length() == 0))
          {
          system.debug('@@@@@@@ Rejection Error');
            rejectedStatements.get(pi.TargetObjectId).addError(
              'A comment is required for rejection!');
          }
        }  
      }
    }
    
    // 1. Updates the Status on Unanimous Approval or Unanimous Rejection from CustOps, Finance & Director
    // 2. Updates the Status on Non-Unanimous Approval or Non-Unanimous Rejection from CustOps, Finance & Director
    
    public static void statusUpdateOnUnanimousApprOrRejec(List<Contract> lstContract,Map<ID,Contract> contractOldMap){
        
        for(Contract objContr: lstContract){
        
       // Contract oldobjContr = contractOldMap.get(objContr.Id);
    /*
        if (objContr.ZTS_US_CustOps_Approval__c == 'Approved' && objContr.ZTS_US_Director_Approval__c == 'Approved'
             && objContr.ZTS_US_Finance_Approval__c == 'Approved')
            { 
            ApprovalSubmitted = false;
              objContr.Status = 'Proposal Approved';  
            }
        if (objContr.ZTS_US_CustOps_Approval__c == 'Rejected' && objContr.ZTS_US_Director_Approval__c == 'Rejected'
             && objContr.ZTS_US_Finance_Approval__c == 'Rejected')
            { 
            
              objContr.Status = 'TM Resubmit';  
            }
            */
        /*    
        if (!((objContr.ZTS_US_CustOps_Approval__c == 'Approved' && objContr.ZTS_US_Director_Approval__c == 'Approved'
             && objContr.ZTS_US_Finance_Approval__c == 'Approved') 
             || (objContr.ZTS_US_CustOps_Approval__c == 'Rejected' && objContr.ZTS_US_Director_Approval__c == 'Rejected'
             && objContr.ZTS_US_Finance_Approval__c == 'Rejected')) 
             && (objContr.ZTS_US_Director_Approval__c == 'Approved' || objContr.ZTS_US_Director_Approval__c == 'Rejected') 
             && (objContr.Status != 'Proposal Approved' && objContr.Status != 'TM Resubmit' && objContr.Status != 'Pending Approval'))
            { 
              system.debug('--- objContr.Status is:'+ objContr.Status );
              objContr.Status = 'Pending Approval';  
            }
            */
            system.debug('--- objContr.Status is:'+ objContr.Status );
            system.debug('--- objContr is:'+ objContr );
            system.debug('--- BeforeDML is:'+ BeforeDML);
        if (objContr.Status  == 'TM Resubmit')
            { 
              BeforeDML = false;
              objContr.ZTS_US_CustOps_Approval__c = '';  
              objContr.ZTS_US_Director_Approval__c = '';
              objContr.ZTS_US_Finance_Approval__c = '';
              objContr.ZTS_US_Review_Team_Approval__c = '';
              objContr.ZTS_US_ABM_Approval__c = '';
              objContr.ZTS_US_Second_Level_Approval__c = '';
              objContr.ZTS_US_Submitted_for_Approval__c = false;
              objContr.ZTS_US_Chk_Review_Team_Approval__c = false;
              
              system.debug('--- inside if objContr.Status is:'+ objContr.Status );
              system.debug('--- inside if objContr is:'+ objContr );
            }
            system.debug('--- outside if objContr.Status is:'+ objContr.Status );
            system.debug('--- outside if objContr is:'+ objContr );
            system.debug('--- outside if BeforeDML is:'+ BeforeDML );
      }
    }
    
    
    // This method will submit the Contract automatically

    public static void submitForApproval(List<Contract> lstContract,Map<ID,Contract> contractOldMap){
    
        try{
            // Create an approval request for the Contract 
            for(Contract objContr: lstContract){
            
                Contract oldobjContr = contractOldMap.get(objContr.Id);
                
                system.debug('entered For --- isSubmitted is:'+ isSubmitted );
                system.debug('entered For --- lstContract size is:'+ lstContract.size());
                system.debug('entered For --- lstContract is:'+ objContr.ZTS_US_Submitted_for_Approval__c);
                system.debug('entered For --- lstContract is:'+ objContr.id);
            
                //if(isSubmitted && objContr.ABM_New_Contract_Prop_Premier_Completion__c == true && oldobjContr.ABM_New_Contract_Prop_Premier_Completion__c != true){
                
                if(objContr.ZTS_US_Submitted_for_Approval__c != false && objContr.ZTS_US_Submitted_for_Approval__c == oldobjContr.ZTS_US_Submitted_for_Approval__c && ApprovalSubmitted && objContr.ZTS_US_Approval_Status__c != 'Pending' ){
                    system.debug('entered If'+ isSubmitted );
                    system.debug('entered If: '+ oldobjContr.ZTS_US_Chk_Review_Team_Approval__c );
                    system.debug('entered If: '+ objContr.ZTS_US_Chk_Review_Team_Approval__c );
                    
                    if(oldobjContr.ZTS_US_Chk_Review_Team_Approval__c != objContr.ZTS_US_Chk_Review_Team_Approval__c){
                        ApprovalSubmitted = false;
                    }

                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments('');
                    req1.setObjectId(objContr.id);
                    //isSubmitted = false;
                    
                    
                    // Submit the approval request for the Contract 
                    //if(isSubmitted){
                    //system.debug('entered If fro rec submission: '+ isSubmitted );
                    Approval.ProcessResult result = Approval.process(req1);
                    //isSubmitted = false;
                    //}
                    system.debug('entered If --- isSubmitted is:'+ isSubmitted );
                    
                    system.debug('entered If --- Approval result is:'+ result );
                    
                    // display if the reqeust was successful
                    System.debug('Submitted for approval successfully: '+result.isSuccess());
                }
                
            }
        }
        catch(DmlException dex)
        {
            String errorMessages = '';
            for (Integer i = 0; i < dex.getNumDml(); i++) {
                System.debug(APPROVAL_PROCESS_ERROR_ORIGIN);
                System.debug('DML Message: ' + dex.getDmlMessage(i));
                errorMessages += dex.getDmlMessage(i) + '\n';
            }
            errorMessages.removeEnd('\n');
            ZTS_EU_Logger.notify = true;
            ZTS_EU_Logger.error(errorMessages,null, APPROVAL_PROCESS_ERROR_ORIGIN);
        }
    }
    
    // Method for calculating:
    // 1. Diff between Proposed Tier & Current Tier Custom setting values and update the field on Contract record
    // 2. Diff between Proposed Tier & Review Committe Proposed Custom setting values and update the field on Contract record
    
    public static void diffCalc(List<Contract> lstContract){
        //ZTS_US_Contract_Tier_Numerical_Value__c conTierNumValue = new ZTS_US_Contract_Tier_Numerical_Value__c();
        List<ZTS_US_Contract_Tier_Numerical_Value__c> listConTierNumValue = ZTS_US_Contract_Tier_Numerical_Value__c.getall().values();
        
        for(Contract oContract : lstContract){
            system.debug('listConTierNumValue is: >>>>>>>>>>>>>'+ listConTierNumValue );
            Decimal currTierVal = 0;
            Decimal proposedTierVal = 0;
            Decimal revCommitteeProposedTierVal = 0;
            
            for(ZTS_US_Contract_Tier_Numerical_Value__c oConNumVal : listConTierNumValue){
                if(oContract.ZTS_US_Current_Tier__c == oConNumVal.ZTS_US_Tier__c){
                    currTierVal = oConNumVal.ZTS_US_Tier_Numerical_Value__c;
                    system.debug('currTierVal  is: >>>>>>>>>>>>>'+ currTierVal  );          
                }
                if(oContract.ZTS_US_Field_Proposed_Tier__c == oConNumVal.ZTS_US_Tier__c){
                    proposedTierVal = oConNumVal.ZTS_US_Tier_Numerical_Value__c;
                    system.debug('proposedTierVal is: >>>>>>>>>>>>>'+ proposedTierVal ); 
                }
                if(oContract.ZTS_US_Review_Committee_Proposed_Tier__c == oConNumVal.ZTS_US_Tier__c){
                    revCommitteeProposedTierVal = oConNumVal.ZTS_US_Tier_Numerical_Value__c;
                    system.debug('revCommitteeProposedTierVal is: >>>>>>>>>>>>>'+ revCommitteeProposedTierVal ); 
                }
            }
            BeforeDML = false;
            oContract.ZTS_US_Diff_Proposed_Current__c = proposedTierVal - currTierVal;
            system.debug('diff value >>>>>>>>>>>>>'+ oContract.ZTS_US_Diff_Proposed_Current__c);
      
            oContract.ZTS_US_Diff_Proposed_Review_Committee__c = proposedTierVal - revCommitteeProposedTierVal;
            system.debug('diff value >>>>>>>>>>>>>'+ oContract.ZTS_US_Diff_Proposed_Review_Committee__c);
            system.debug('diff value >>>>>>>>>>>>>'+ BeforeDML);
        }
        
    }
    
 
    /*****************************************************************
    * Method name  : updateAccountContractDetails
    * Description  : This will update contract details on Account. 
    * Parameters   : trigger parameters
    * Author       : Shiva kudikilla
    *****************************************************************/    
    public static void updateAccountContractDetails(List<Contract> triggerNew, Map<ID,Contract> contractOldMap){
        //System.debug('$$$ triggerNew.ZTS_US_Current_Tier__c: '+triggerNew[0].ZTS_US_Current_Tier__c);
        Set<Id> AccIdSet = new Set<ID>();
        Map<Id, Account> Acctobeupdated = new Map<Id, Account>();  
        for(Contract cont:triggerNew){
            if(cont.Status=='Active' && cont.ZTS_US_Leaders_Edge__c==true && !AccIdSet.contains(cont.AccountID)){
                Account ac = new Account(Id=cont.AccountId);
                ac.ZTS_US_Contract_Tier__c=cont.ZTS_US_Current_Tier__c;
                Acctobeupdated.put(cont.AccountId, ac);
                AccIdSet.add(cont.AccountId);
            }
            //SC--002553 Update MZR BIOS Tier Field on Account with new Tier value from Contract feed
            //SC--002725
            /*            
            if( (Test.isRunningTest() || cont.Profile_Name__c =='Integration profile')  
               && cont.Name != null && (cont.Name.containsIgnoreCase('MZR Bios Pricing') || cont.Name.containsIgnoreCase('PC MZR Paras')) 
               && cont.ZTS_US_Current_Tier__c != null && cont.ZTS_US_Current_Tier__c.contains('$')
               && (contractOldMap == null || (contractOldMap.get(cont.id).EndDate!=cont.EndDate && cont.EndDate > System.today()) )
              ){  
                  */
            /*System.debug('$$$ here');
            System.debug('$$$ Test.isRunningTest(): '+Test.isRunningTest());
            System.debug('$$$ cont.Profile_Name__c: '+cont.Profile_Name__c);
            System.debug('$$$ cont.name: '+cont.name);
            System.debug('$$$ cont.Name.containsIgnoreCase(MZR Bios Pricing): '+cont.Name.containsIgnoreCase('MZR Bios Pricing'));
            System.debug('$$$ cont.ZTS_US_Current_Tier__c: '+cont.ZTS_US_Current_Tier__c);
            System.debug('$$$ cont.ZTS_US_Current_Tier__c.contains($): '+cont.ZTS_US_Current_Tier__c.contains('$'));
            System.debug('$$$ contractOldMap: '+contractOldMap);
            System.debug('$$$ cont.EndDate: '+cont.EndDate);
            System.debug('$$$ (cont.EndDate > System.today()): '+(cont.EndDate > System.today()));*/
              if( (Test.isRunningTest() || cont.Profile_Name__c =='Integration profile')  
               && cont.Name != null && (cont.Name.containsIgnoreCase('MZR Bios Pricing') || cont.Name.containsIgnoreCase('PC MZR Paras') || cont.Name.containsIgnoreCase('PC MZR Theras')) 
               && cont.ZTS_US_Current_Tier__c != null && cont.ZTS_US_Current_Tier__c.contains('$')
               && (contractOldMap == null || (cont.EndDate > System.today()) )
              ){  
                  System.debug('$$$ not here?');
                String mzrTierValue = cont.ZTS_US_Current_Tier__c.substringAfter('$');
                mzrTierValue = mzrTierValue.toUpperCase();
                mzrTierValue = mzrTierValue.containsIgnoreCase('K') ? mzrTierValue.replace('K', '000') : mzrTierValue;                
                if(String.isNotBlank(mzrTierValue) && mzrTierValue.isNumeric()){
                    String formattedTierVal = doFormatting(Decimal.valueOf(mzrTierValue), 0); 
                    Account ac = new Account(Id=cont.AccountId);
                    if((Acctobeupdated.get(cont.AccountId)) != null){
                        ac = Acctobeupdated.get(cont.AccountId);
                    }  
                    if(cont.Name.containsIgnoreCase('MZR Bios Pricing')){
                        ac.ZTS_US_MVP_BIOS__c = '$'+ formattedTierVal;
                        ac.ZTS_US_MVP_Account__c = true;
                        Acctobeupdated.put(cont.AccountId, ac);
                        
                    }if (cont.Name.containsIgnoreCase('PC MZR Paras')){
                        ac.MZR_PARAs_Tier__c = '$'+ formattedTierVal;
                        ac.MZR_PARAs_Account__c = true;
                        Acctobeupdated.put(cont.AccountId, ac);
                    }if (cont.Name.containsIgnoreCase('PC MZR Theras')){
                        ac.ZTS_US_MZR_THERA_Tier__c = '$'+ formattedTierVal;
                        ac.ZTS_US_MZR_THERA_Account__c = true;
                        Acctobeupdated.put(cont.AccountId, ac);
                    }
                }
                  
              }
            
            // Added as a part of TPDEV-2041
            if(cont.Profile_Name__c =='Integration profile'){
                Account updatedAccount = new Account();
                if(Acctobeupdated.containsKey(cont.AccountId))
                    updatedAccount = Acctobeupdated.get(cont.AccountId);
                if(cont.name.containsIgnoreCase('LVS MZR')){
                    updatedAccount.Id = cont.AccountId;
                    if(cont.StartDate <= System.today() &&  cont.ZTS_US_End_Date_Interface__c > System.today()){
                        updatedAccount.LVS_MZR_Status__c = 'Active';
                        updatedAccount.LVS_MZR_Account__c = true;
                    }
                    updatedAccount.LVS_MZR_Enrollment_Date__c = cont.StartDate;
                    updatedAccount.LVS_MZR_Tier__c = cont.Name.containsIgnoreCase('Preferred') ? 'LVS Preferred': 'LVS';
                    Acctobeupdated.put(cont.AccountId,updatedAccount);
                }else if(cont.name.containsIgnoreCase('DX MZR')){
                    updatedAccount.Id = cont.AccountId;
                    if(cont.name.containsIgnoreCase('Lab'))
                    	updatedAccount.DX_MZR_Lab_Enrollment_Date__c = cont.StartDate;
                    else if(cont.name.containsIgnoreCase('POC'))
                    	updatedAccount.DX_MZR_POC_Enrollment_Date__c = cont.StartDate;
                    else if(cont.name.containsIgnoreCase('Imagyst'))
                    	updatedAccount.DX_MZR_Imagyst_Enrollment_Date__c = cont.StartDate;
                    
                    Acctobeupdated.put(cont.AccountId,updatedAccount);
                }
            } 
        }
        System.debug('$$$ Acctobeupdated: '+Acctobeupdated);
        if(Acctobeupdated!=null && Acctobeupdated.size()>0){
            //system.debug('---------BEFORE LIST UPDATE---------'+Acctobeupdated.size());
            update(Acctobeupdated.values());
        }
    }
    
    /***********
    * Method name  : populateTerritoryOnContract
    * Description  : This will update territory on contract.
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/  
    public static void populateTerritoryOnContract(List<Contract> lstContract){
    Set<Id> setConAccId = new Set<Id>();
    Set<Id> setConOwnerId = new Set<Id>();
    List<ZTS_EU_Account_Position__c> lstAccTeam = new List<ZTS_EU_Account_Position__c>();
    List<Contract> contrToUpdate = new List<Contract>();
    
        for(Contract contr:lstContract){
            setConAccId.add(contr.AccountId);
            setConOwnerId.add(contr.OwnerId);
        }
        system.debug('@@@@@@@@@@@@@setConAccId is: '+setConAccId);
        system.debug('@@@@@@@@@@@@@setConOwnerId is: '+setConOwnerId);
        
        lstAccTeam = [SELECT Id,ZTS_EU_Employee__c,ZTS_Employee_ID__c,ZTS_EU_Territory__c,ZTS_EU_Account__c from ZTS_EU_Account_Position__c where ZTS_EU_Account__c IN :setConAccId and ZTS_Employee_ID__c IN :setConOwnerId AND ZTS_EU_Market__c = 'United States'];
        system.debug('@@@@@@@@@@@@@lstAccTeam  is: '+lstAccTeam);
       
        for(Contract contr:lstContract){
            if(lstAccTeam != null && lstAccTeam.size() > 0){
                for(ZTS_EU_Account_Position__c accTeam:lstAccTeam){
                    if(contr.AccountId == accTeam.ZTS_EU_Account__c && contr.OwnerId == accTeam.ZTS_Employee_ID__c){
                        contr.ZTS_us_Territory__c = accTeam.ZTS_EU_Territory__c;
                        contrToUpdate.add(contr);
                    }
                }
            }
        }
        /*
        if(contrToUpdate!=null && contrToUpdate.size()>0){
            system.debug('---------BEFORE LIST UPDATE---------'+contrToUpdate.size());
            update(contrToUpdate);
        }
        */
        
    }
    
     /***********
    * Method name  : updateDeletedLocationSupplier
    * Description  : This method is used to update the location and supplier information
    * Return Type  : None.
    * Parameters   : trigger parameters.
    ***********/  
    public static void updateDeletedLocationSupplier(List<Contract> lstContract){
        
        if(lstContract != null && lstContract.size() == 1){
            Contract objContract = lstContract[0];
            //system.debug('##Contract: ' + objContract);
            String strSupLocInfo = '', seperator = ',', spacer = '    ';
            //Start Code to update the Deleted Location Info
            
            String deletedLocInfo = objContract.Deleted_Locations__c;   
            //system.debug('Location: ' + deletedLocInfo);
            if(deletedLocInfo != null && deletedLocInfo != ''){
                string[] delLocations = deletedLocInfo.split('-');
                List<Account> locationAccnts = [SELECT Id, Name, ZTS_US_NARC_ID__c, ZTS_US_Parent_NARC_ID__c, ZTS_EU_Account_Status__c, BillingStreet, BillingCity,BillingState, BillingPostalCode, BillingCountry 
                                                        FROM Account WHERE ZTS_US_Parent_NARC_ID__c =:objContract.ZTS_US_NARC_ID__c AND ZTS_EU_Market__c = 'United States' ORDER BY CreatedDate DESC];
                //system.debug('##locationAccnts : ' +  locationAccnts);                                        
                Integer counter =0;
                String concatLocaInfo ='';
                if(delLocations != null && delLocations.size() == locationAccnts.size()){
                    for(Account objAccount: locationAccnts){
                        if(delLocations[counter] == 'checked'){
                            concatLocaInfo = objAccount.Name + seperator + objAccount.ZTS_US_NARC_ID__c + seperator + objAccount.BillingStreet + seperator + objAccount.BillingCity + seperator + objAccount.BillingState + seperator + objAccount.BillingPostalCode + seperator  + objAccount.BillingCountry ;
                            strSupLocInfo += (strSupLocInfo == '')? concatLocaInfo : seperator + spacer + concatLocaInfo;
                        }
                        counter++;
                    }
                }
                //system.debug('##deleted Location : ' + strSupLocInfo);
                objContract.Deleted_Locations__c = strSupLocInfo;
            }
            
            //End Code
        
            //Start Code to update the Deleted Location Info           
            
            if(objContract.Deleted_Suppliers__c != '' || objContract.Deleted_Distributors__c != ''){
                List<ZTS_EU_Account_Affiliations__c> affAccs = [Select Id, ZTS_US_Role__c, ZTS_EU_Account__c, ZTS_EU_Affiliated_Account__r.Name, ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c 
                                                                    FROM ZTS_EU_Account_Affiliations__c WHERE ZTS_EU_Account__r.Id = :objContract.AccountId AND (ZTS_US_Role__c='Supplier' OR ZTS_US_Role__c = 'Distributor') AND ZTS_EU_Market_from_Primary_Account__c = 'United States' ORDER BY CreatedDate DESC ]; 
                Integer counter;
                
                List<ZTS_EU_Account_Affiliations__c> lstSuppliers =  new List<ZTS_EU_Account_Affiliations__c>();
                List<ZTS_EU_Account_Affiliations__c> lstDistributors = new List<ZTS_EU_Account_Affiliations__c>();
                
                for (ZTS_EU_Account_Affiliations__c objAffiliation : affAccs){
                    
                    if(objAffiliation.ZTS_US_Role__c == 'Supplier'){
                        lstSuppliers.add(objAffiliation);
                    }else{
                        lstDistributors.add(objAffiliation);
                    }
                }
                
                String deletedSupInfo = objContract.Deleted_Suppliers__c;   
                //system.debug('Supplier: ' + deletedSupInfo);
                if(deletedSupInfo != null && deletedSupInfo != ''){
                    string[] delSuppliers = deletedSupInfo.split('-');
                    
                    //Code to populate address details for Supplier                                        
                    counter =0;
                    strSupLocInfo = '';
                    String concatSupInfo = '';
                    
                    if(delSuppliers != null && delSuppliers.size() > 0 && lstSuppliers != null && lstSuppliers.size() > 0){
                        for(ZTS_EU_Account_Affiliations__c objAccAff: lstSuppliers){
                            if(objAccAff.ZTS_US_Role__c == 'Supplier' && delSuppliers.size() >= counter + 1  && delSuppliers[counter] == 'checked'){
                                concatSupInfo = objAccAff.ZTS_EU_Affiliated_Account__r.Name + seperator + objAccAff.ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c ;
                                strSupLocInfo += (strSupLocInfo == '')? concatSupInfo : seperator + spacer + concatSupInfo;
                                
                            }   
                            counter++;                         
                        }
                    }
                    
                    //system.debug('##deleted Supplier : ' + strSupLocInfo);
                    objContract.Deleted_Suppliers__c = strSupLocInfo;
                }
                
                String deletedDistInfo = objContract.Deleted_Distributors__c;   
                //system.debug('Supplier: ' + deletedDistInfo);
                if(deletedDistInfo != null && deletedDistInfo != ''){           
                    string[] delDistributors = deletedDistInfo.split('-');
                    
                    //Code to find address details for Distributors
                    counter =0;
                    strSupLocInfo = '';
                    String concatDistInfo = '';
                    if(delDistributors != null && delDistributors.size() > 0 && lstDistributors != null && lstDistributors.size() > 0){
                        for(ZTS_EU_Account_Affiliations__c objAccAff: lstDistributors){
                            if(objAccAff.ZTS_US_Role__c == 'Distributor' &&  delDistributors.size() >= counter + 1 && delDistributors[counter] == 'checked'){
                                concatDistInfo = objAccAff.ZTS_EU_Affiliated_Account__r.Name + seperator + objAccAff.ZTS_EU_Affiliated_Account__r.Billing_Address_Details__c ;
                                strSupLocInfo += (strSupLocInfo == '')? concatDistInfo : seperator + spacer + concatDistInfo;
                                
                            }   
                            counter++;                         
                        }
                    }
                    //system.debug('##Deleted Distributors : ' + strSupLocInfo);
                    objContract.Deleted_Distributors__c = strSupLocInfo;
                            
                }
                
                //End Code
            }
        }   
    }
     
    
    /***********
    * Method name  : doFormatting
    * Description  : This method is to format the given decimal E.g. input 1234567 and output will be 1,234,567
    * Return Type  : formatted String
    * Parameters   : val will be toBeFormatted decimal and dec will be consider how many decimal places
    * Author       : Shiva Kudikilla
    ***********/ 
    public static String doFormatting(Decimal val, Integer dec){ 
        String s;
        try{
            if(val != null){  
                String tSep = ',';
                String dSep = '.'; 
                String tmp;
                Integer i = 4 + dec;
                
                // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
                if(dec==0){
                    i--;
                }
                
                s = val.setScale(dec).toPlainString().replace(tSep, dSep);
                while(s.length() > i) {
                    tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
                    s = tmp;
                    i += 4;
                }
                
                // If the number is negative and has a number non-decimal digits divisible by 3, it prevents inserting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
                if (s.substring(0,1) == '-') {
                    if (s.substring(1,2) == tSep) {
                        s = '-' + s.substring(2);
                    }
                }
                //System.debug('formatted: ' + s);
                
            } 
            return s;
        }catch(Exception ex){
            System.debug(ex);
            return String.valueOf(val);
        }
    }
}