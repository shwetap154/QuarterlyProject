/****************************************************************************************************************************************** 
* Trigger Name : FormTriggerService
* Description  : Service Class for "FormTriggerHandler" 
* Created By   : Aritra (Cognizant)
* Created Date : 28th Oct, 2021
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Aritra Chakraborty      10/28/2021          Created 
******************************************************************************************************************************************/
public class FormTriggerService  {
    static final String acp_RecType = System.label.ACPRecordType;
    static final String overhire_RecType = System.label.Overhire_Record_Type;
    static final String acp_Accredited = System.label.ACP_Accredited;
    static final String acp_Exceeds = System.label.ACP_Exceeds;
    static final String acp_Met_Expectations = System.label.ACP_Met_Expectation;
    static final String acp_Needs_Development = System.label.ACP_Needs_to_Develop;
    static final String acp_Saved = System.label.ACP_Saved;
    static final String acp_New = System.label.ACP_New;
    static final String acp_pendingRepsComments = System.label.ACP_Pending_Reps_Comment;
    static final String acp_completed = System.label.ACP_Completed;
    static final String acp_RepEmailTemplate = System.label.ACP_Rep_Email_Template;
    static final String acp_MgrEmailTemplate = System.label.ACP_Manager_Email_Template;
    static final String overhire_Pending_Status = System.label.Overhire_Pending_Status;
    
    public static void beforeUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, 
                                    List<SObject> triggerNew, Map<Id, SObject> triggerNewMap)
    {
        
        
        List <Form__Share> fshareList = new List<Form__Share>();
        
        /*ProcessInstanceStep[] stepRec = [SELECT SystemModstamp, StepStatus, StepNodeId, ProcessInstanceId, OriginalActorId, Id, CreatedDate, CreatedById, Comments, ActorId 
                                         FROM ProcessInstanceStep WHERE actorId = :userInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];*/
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(acp_RecType).getRecordTypeId();
        Id overHireRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(overhire_RecType).getRecordTypeId();        
        for(SObject s : triggerNew){
            SObject s_old = triggerOldMap.get(s.Id);
            Form__c f = (Form__c)s;
            Form__c f_old = (Form__c)s_old;
            if(f.recordtypeID == acpRecordTypeId){               
                //When the form record is sent to Rep for approval (Status changed to Pending Rep's Comments), Share records are created for the Rep
                //OWD for forms object is PRIVATE, The Rep needs to get edit access to the form as his comments in approval step needs to be updated on Reps Comments field.
                if(f.Status__c == acp_pendingRepsComments){
                    Form__Share fshare = new Form__Share();
                    fshare.ParentId = f.id;
                    fshare.UserOrGroupId = f.IDSR__c;
                    fshare.AccessLevel = 'edit';
                    fshare.RowCause = Schema.Form__Share.RowCause.Share_Form_Record_with_Rep__c;
                    fshareList.add(fshare);
                }
                //If Rep rejects the form, and manager corrects the skill fields, then the calculation should run again
                if((f.Asks_for_the_Business__c != f_old.Asks_for_the_Business__c)||(f.Call_Selling_Materials__c != f_old.Call_Selling_Materials__c)||(f.Identify_Confirm_Customer_Needs__c != f_old.Identify_Confirm_Customer_Needs__c)
                   ||(f.Opening_the_Call__c != f_old.Opening_the_Call__c)||(f.Technical_Fluency__c != f_old.Technical_Fluency__c))
                {
                    calculateAccreditionStatus(f);
                }
                
            }            
        }
        
        if(fshareList.size()>0){
            try{
                SharingUtil.create(fshareList);
            }
            catch(System.DmlException e)
            {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    System.debug(e.getDmlMessage(i)); 
                }
            }
            
        }
        
    }
    
    public static void afterInsert(List<Form__c> triggerNew, Map<Id, Form__c> triggerNewMap){
        
    }
    
    public static void beforeInsert(List<SObject> triggerNew){
        Id acpRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(acp_RecType).getRecordTypeId();
        Id overHireRecordTypeId = Schema.SObjectType.Form__c.getRecordTypeInfosByName().get(overhire_RecType).getRecordTypeId();
        for(SObject s1 : triggerNew){
            Form__c f1 = (Form__c)s1;
            if(f1.RecordTypeId == acpRecordTypeId){
                calculateAccreditionStatus((Form__c)s1);
            }

                f1.Status__c = acp_Saved;  
        }
    }
    
    public static void calculateAccreditionStatus(Form__c f1)
    {
        //For Record type ACP Accreditation, the Accreditation status field is populated based on the inputs in 5 skill field inputs
        //If total count of 'Met Expectations'/'Exceeds' in 5 skill fields is = 5 then Accreditation status field is set as "Accredited"
        if ((f1.Status__c == acp_New)||(f1.Status__c == acp_Saved))
        {
            Integer expectationMetCount = 0;
            if((f1.Asks_for_the_Business__c != null) && (f1.Call_Selling_Materials__c != null) && 
               (f1.Identify_Confirm_Customer_Needs__c != null) && (f1.Opening_the_Call__c != null) && 
               (f1.Technical_Fluency__c != null))
            {
                if((f1.Asks_for_the_Business__c == acp_Met_Expectations)||(f1.Asks_for_the_Business__c == acp_Exceeds))
                {
                    expectationMetCount ++;
                }
                if((f1.Call_Selling_Materials__c == acp_Met_Expectations)||(f1.Call_Selling_Materials__c == acp_Exceeds))
                {
                    expectationMetCount ++;
                }
                if((f1.Identify_Confirm_Customer_Needs__c == acp_Met_Expectations)||(f1.Identify_Confirm_Customer_Needs__c == acp_Exceeds))
                {
                    expectationMetCount ++;
                }
                if((f1.Opening_the_Call__c == acp_Met_Expectations)||(f1.Opening_the_Call__c == acp_Exceeds))
                {
                    expectationMetCount ++;
                }
                if((f1.Technical_Fluency__c == acp_Met_Expectations)||(f1.Technical_Fluency__c == acp_Exceeds))
                {
                    expectationMetCount ++;
                }
                
            }
            if(expectationMetCount == 5)
            {
                f1.Accreditation_Status__c = acp_Accredited;
            }
            else
            {
                f1.Accreditation_Status__c = acp_Needs_Development;
            }
        }
        
    }
    
    public static void beforeDelete(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap){
    }
    
    public static void afterUpdate(List<SObject> triggerOld, Map<Id, SObject> triggerOldMap, List<SObject> triggerNew, Map<Id, SObject> triggerNewMap){
    }
	
    
}