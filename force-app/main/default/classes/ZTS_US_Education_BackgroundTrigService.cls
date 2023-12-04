public with sharing class ZTS_US_Education_BackgroundTrigService {

    public static void beforeInsert(List<ZTS_US_Education_Background__c> triggerNew){
        if(triggerNew.isEmpty())
            return;
        
        String errorMsg = 'The Education record of DVM type already exists on the Selected Contact.';
        List<String> contactname = new List<String>();
        List<String> newContactList = new List<String>();
        
        for(ZTS_US_Education_Background__c edubck : triggerNew){
            newContactList.add(edubck.ZTS_US_Contact__c);
        	System.debug('$$$ newContactList in loop'+newContactList);
        }
        
        System.debug('$$$ newContactList'+newContactList);

        List<ZTS_US_Education_Background__c> EBRecords = [SELECT ZTS_US_Contact__c,ZTS_US_Type__c FROM ZTS_US_Education_Background__c WHERE ZTS_US_Contact__c IN: newContactList];
        System.debug('$$$ EBRecords'+EBRecords);
        //Checks if DVM record already exists on the contact . If yes, then show the error message.
        for (ZTS_US_Education_Background__c ExistingRec: EBRecords)
        {
            for(ZTS_US_Education_Background__c newRec : triggerNew)
            {
                if(ExistingRec.id!=newRec.Id && ExistingRec.ZTS_US_Contact__c == newRec.ZTS_US_Contact__c && ExistingRec.ZTS_US_Type__c == 'DVM' && newRec.ZTS_US_Type__c == 'DVM')
                {
                    newRec.addError(errorMsg);
                }
            }         
        }
    }

    public static void afterInsert(List<ZTS_US_Education_Background__c> triggerNew, Map<Id,ZTS_US_Education_Background__c> triggerNewMap){
        ZTS_US_EduUpdateOnContact.updateConOnEduCreation(triggerNew, triggerNewMap);
    }

    public static void afterUpdate(List<ZTS_US_Education_Background__c> triggerNew, Map<Id,ZTS_US_Education_Background__c> triggerNewMap, Map<Id,ZTS_US_Education_Background__c> triggerOldMap){
        ZTS_US_EduUpdateOnContact.updateConOnEduModification(triggerNew,triggerOldMap,triggerNewMap);
    }

    public static void beforeDelete(List<ZTS_US_Education_Background__c> triggerOld, Map<Id,ZTS_US_Education_Background__c> triggerOldMap){
        ZTS_US_EduUpdateOnContact.updateConOnEduDeletion(triggerOld, triggerOldMap);
    }
}