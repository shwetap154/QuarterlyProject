/**********************************************************************
@author Alex Carstairs
@date 30 May 2019
@description This an extension for trigger handlers
**********************************************************************/

public virtual class TriggerHandlerExtension {
    
    static final String FILTER_VALUE = 'United States';
    /* Always gets Sys Admin regardless of language */
    static final Id SYS_ADMIN_PROFILE_ID = [
    SELECT Id 
    FROM Profile 
    WHERE (UserType = 'Standard' 
    AND PermissionsCustomizeApplication = true) 
    ORDER BY CreatedDate ASC 
    LIMIT 1
    ].Id;
    
    // To allow for other triggers to manually disable this trigger
    public static Boolean triggerDisabled = false;
    public static Schema.SObjectField bypassField = null;
    
    public Boolean disableTrigger {
        get;
        set {triggerDisabled = value;}
    }
    
    public Schema.SObjectField setBypass {
        get;
        set {bypassField = value;}
    }
    
    public virtual void setBypassField(Schema.SObjectField bypassField) {
        setBypass = bypassField;
    }
    public virtual Boolean isDisabled() {
        
        List<Bypass_Triggers__mdt> bypassTriggerMetadata;
        if(!String.isBlank(String.valueOf(bypassField))) {
            // bypassField = 'Account_Bypass__c';
            // 'SELECT Id, ' + handlerName + '
            String bypassRecordQuery = '';
            bypassRecordQuery += 'SELECT Id, ' + String.valueOf(bypassField);
            bypassRecordQuery += ' FROM Bypass_Triggers__mdt';
            bypassTriggerMetadata = Database.query(bypassRecordQuery);
            
            if(!bypassTriggerMetadata.isEmpty()) {
                if((Boolean)bypassTriggerMetadata[0].get(bypassField)) {
                    if(UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID) {
                        triggerDisabled = true;
                    }
                }
            }
        }
        return triggerDisabled;
    }
    
    public static List<SObject> filter(List<SObject> listToFilter, Schema.SObjectField filterField, Boolean isEqual) {
        
        List<SObject> recordsToBeProcessed =  new List<SObject>();
        
        for(SObject eachRecord : listToFilter){
            if(eachRecord.get(filterField) == null) continue;
            if(isEqual){
                //This is the case for US Market Accounts
                if (eachRecord.get(filterField) == FILTER_VALUE && isEqual) {
                    recordsToBeProcessed.add(eachRecord);
                }
            }
            else{
                //INTL Market Accounts
                // two FALSE do not make a TRUE hence !isEqual
                if (eachRecord.get(filterField) != FILTER_VALUE && !isEqual) {
                    recordsToBeProcessed.add(eachRecord);
                }
            }
        }
        
        return recordsToBeProcessed;
    }
    
    public static List<SObject> filter(List<SObject> listToFilter, Schema.SObjectField filterField, Schema.SObjectField parentField, List<SObject> parentObjects, Boolean isEqual) 
    {
        List<SObject> recordsToBeProcessed =  new List<SObject>();
        Map<Id, SObject> parentObjectsMap = new Map<Id, SObject>(parentObjects);
        
        for(SObject eachRecord : listToFilter)
        {
            if(isEqual)
            {
                
                //This is the case for US Market Accounts
                if ((parentObjectsMap.get((Id)eachRecord.get(parentField))) != null && (parentObjectsMap.get((Id)eachRecord.get(parentField))).get(filterField) != null && (parentObjectsMap.get((Id)eachRecord.get(parentField))).get(filterField) == FILTER_VALUE && isEqual ) 
                {
                    recordsToBeProcessed.add(eachRecord);
                }
            }
            else
            {
                //INTL Market Accounts
                // two FALSE do not make a TRUE hence !isEqual
                if ((parentObjectsMap.get((Id)eachRecord.get(parentField))) != null && (parentObjectsMap.get((Id)eachRecord.get(parentField))).get(filterField) != FILTER_VALUE && !isEqual) 
                {
                    recordsToBeProcessed.add(eachRecord);
                }
            }
        }
        return recordsToBeProcessed;
    }
    
    // Avoid recursion
    @TestVisible
    private static Boolean isFirstTime = true;
    
    // List of trigger contexts to allow recursion
    public static List<String> triggerContextsForRecursion = new List<String>();
    
    public List<String> setTriggerRecursionContexts {
        get;
        set {triggerContextsForRecursion = value;}
    }
    
    
    
    
    // Checks if the trigger has been fired once
    public virtual Boolean isFirstTime() {
        if(isFirstTime) {
            isFirstTime = false;
            return true;
        }
        else {
            return isFirstTime;
        }
    }
    
    // Allow users to allow recursion for certain contexts
    public virtual List<String> getTriggerContextsForRecursion() {
        return triggerContextsForRecursion;
    }
    
    
}