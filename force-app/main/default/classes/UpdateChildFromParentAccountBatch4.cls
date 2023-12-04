global class UpdateChildFromParentAccountBatch4 implements Database.Batchable<SObject>,Database.Stateful {
    global List<Account> accsToUpdate = new List<Account>();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //list of accounts with children morethan 400 each
        /***
         * Taylor Poppell 01/08/2020
         * Updated to remove hardcoded Account Ids
         * Makes use of custom metadata type to house Account Ids for accounts with many children
         */
        List<Accounts_with_more_than_400_Children__mdt> accountsWithManyChildren = [SELECT Id, AccountId__c FROM Accounts_with_more_than_400_Children__mdt];
        List<Id> manyChildAccIds = new List<Id>();
        for(Accounts_with_more_than_400_Children__mdt accountWithManyChildren : accountsWithManyChildren) {
            manyChildAccIds.add(accountWithManyChildren.AccountId__c);
        }
            if(Test.isRunningTest()){
                return Database.getQueryLocator([SELECT id,parentid,name,ZTS_EU_Account_Status__c,MZR_Account__c,MZR_Status__c,ZTS_US_MVP_Account__c,
                                             ZTS_US_MVP_BIOS__c, MZR_PARAs_Account__c,MZR_PARAs_Tier__c,
                                             MZR_Enrollment_Start_Date__c,MZR_Enrollment_Date__c,MZR_BIOS_Enrollment_Date__c, MZR_PARAs_Enrollment_Date__c,
                                             MZR_Accepted_Declined_Date__c,MZR_Account_data_change__c,MZR_BIOS_Accepted_T_C_Date__c,
                                             MZR_Decline_Additional_Notes__c,MZR_End_Date__c,MZR_Enrollment_Experience__c,MZR_PARAs_Accepted_T_C_Date__c,
                                             MZR_Reason_for_Not_Enrolling__c,MZR_Feedback__c,MZR_Derm_Rebate__c,MZR_Tier__c
                                             FROM account WHERE parentid=null AND ZTS_EU_Account_Status__c = 'Active' AND ZTS_EU_Market__c = 'United States' ]);
            }
            return Database.getQueryLocator([SELECT id,parentid,name,ZTS_EU_Account_Status__c,MZR_Account__c,MZR_Status__c,ZTS_US_MVP_Account__c,
                                             ZTS_US_MVP_BIOS__c, MZR_PARAs_Account__c,MZR_PARAs_Tier__c,
                                             MZR_Enrollment_Start_Date__c,MZR_Enrollment_Date__c,MZR_BIOS_Enrollment_Date__c, MZR_PARAs_Enrollment_Date__c,
                                             MZR_Accepted_Declined_Date__c,MZR_Account_data_change__c,MZR_BIOS_Accepted_T_C_Date__c,
                                             MZR_Decline_Additional_Notes__c,MZR_End_Date__c,MZR_Enrollment_Experience__c,MZR_PARAs_Accepted_T_C_Date__c,
                                             MZR_Reason_for_Not_Enrolling__c,MZR_Feedback__c,MZR_Derm_Rebate__c,MZR_Tier__c
                                             FROM account WHERE parentid=null AND ZTS_EU_Account_Status__c = 'Active' AND id IN :manyChildAccIds AND ZTS_EU_Market__c = 'United States' ]);

    }

    global void execute(Database.BatchableContext BC, List<Account> parentAccs) {
        Set<Id> parentAccIds = new Set<Id>();
        Map<Id, Account> pMap = new Map<Id, Account>();
        for(Account a: parentAccs){
            parentAccIds.add(a.Id);
            pMap.put(a.Id, a);
        }

        for(Account c : [SELECT id,parentid,name,ZTS_EU_Account_Status__c,MZR_Account__c,MZR_Status__c,ZTS_US_MVP_Account__c,
                         ZTS_US_MVP_BIOS__c, MZR_PARAs_Account__c,MZR_PARAs_Tier__c,
                         MZR_Enrollment_Start_Date__c,MZR_Enrollment_Date__c,MZR_BIOS_Enrollment_Date__c, MZR_PARAs_Enrollment_Date__c,
                         MZR_Accepted_Declined_Date__c,MZR_Account_data_change__c,MZR_BIOS_Accepted_T_C_Date__c,
                         MZR_Decline_Additional_Notes__c,MZR_End_Date__c,MZR_Enrollment_Experience__c,MZR_PARAs_Accepted_T_C_Date__c,
                         MZR_Reason_for_Not_Enrolling__c,MZR_Feedback__c,MZR_Derm_Rebate__c,MZR_Tier__c
                         FROM Account WHERE parentid in :parentAccIds AND ZTS_EU_Market__c = 'United States'] ){
                             boolean updFlag = false;
                             //copy MZR fields
                             if(c.MZR_Account__c != pMap.get(c.ParentId).MZR_Account__c){
                                 c.MZR_Account__c = pMap.get(c.ParentId).MZR_Account__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Status__c != pMap.get(c.ParentId).MZR_Status__c){
                                 c.MZR_Status__c = pMap.get(c.ParentId).MZR_Status__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Enrollment_Start_Date__c != pMap.get(c.ParentId).MZR_Enrollment_Start_Date__c){
                                 c.MZR_Enrollment_Start_Date__c = pMap.get(c.ParentId).MZR_Enrollment_Start_Date__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Enrollment_Date__c != pMap.get(c.ParentId).MZR_Enrollment_Date__c){
                                 c.MZR_Enrollment_Date__c = pMap.get(c.ParentId).MZR_Enrollment_Date__c;
                                 updFlag = true;
                             }
                             //copy Bios fields
                             if(c.ZTS_US_MVP_Account__c != pMap.get(c.ParentId).ZTS_US_MVP_Account__c){
                                 c.ZTS_US_MVP_Account__c = pMap.get(c.ParentId).ZTS_US_MVP_Account__c;
                                 updFlag = true;
                             }
                             if(c.ZTS_US_MVP_BIOS__c != pMap.get(c.ParentId).ZTS_US_MVP_BIOS__c){
                                 c.ZTS_US_MVP_BIOS__c = pMap.get(c.ParentId).ZTS_US_MVP_BIOS__c;
                                 updFlag = true;
                             }
                             if(c.MZR_BIOS_Enrollment_Date__c != pMap.get(c.ParentId).MZR_BIOS_Enrollment_Date__c){
                                 c.MZR_BIOS_Enrollment_Date__c = pMap.get(c.ParentId).MZR_BIOS_Enrollment_Date__c;
                                 updFlag = true;
                             }
                             //copy Paras fields
                             if(c.MZR_PARAs_Account__c != pMap.get(c.ParentId).MZR_PARAs_Account__c){
                                 c.MZR_PARAs_Account__c = pMap.get(c.ParentId).MZR_PARAs_Account__c;
                                 updFlag = true;
                             }
                             if(c.MZR_PARAs_Tier__c != pMap.get(c.ParentId).MZR_PARAs_Tier__c){
                                 c.MZR_PARAs_Tier__c = pMap.get(c.ParentId).MZR_PARAs_Tier__c;
                                 updFlag = true;
                             }
                             if(c.MZR_PARAs_Enrollment_Date__c != pMap.get(c.ParentId).MZR_PARAs_Enrollment_Date__c){
                                 c.MZR_PARAs_Enrollment_Date__c = pMap.get(c.ParentId).MZR_PARAs_Enrollment_Date__c;
                                 updFlag = true;
                             }

                             if(c.MZR_Accepted_Declined_Date__c != pMap.get(c.ParentId).MZR_Accepted_Declined_Date__c){
                                 c.MZR_Accepted_Declined_Date__c = pMap.get(c.ParentId).MZR_Accepted_Declined_Date__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Account_data_change__c != pMap.get(c.ParentId).MZR_Account_data_change__c){
                                 c.MZR_Account_data_change__c = pMap.get(c.ParentId).MZR_Account_data_change__c;
                                 updFlag = true;
                             }
                             if(c.MZR_BIOS_Accepted_T_C_Date__c != pMap.get(c.ParentId).MZR_BIOS_Accepted_T_C_Date__c){
                                 c.MZR_BIOS_Accepted_T_C_Date__c = pMap.get(c.ParentId).MZR_BIOS_Accepted_T_C_Date__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Decline_Additional_Notes__c != pMap.get(c.ParentId).MZR_Decline_Additional_Notes__c){
                                 c.MZR_Decline_Additional_Notes__c = pMap.get(c.ParentId).MZR_Decline_Additional_Notes__c;
                                 updFlag = true;
                             }
                             if(c.MZR_End_Date__c != pMap.get(c.ParentId).MZR_End_Date__c){
                                 c.MZR_End_Date__c = pMap.get(c.ParentId).MZR_End_Date__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Enrollment_Experience__c != pMap.get(c.ParentId).MZR_Enrollment_Experience__c){
                                 c.MZR_Enrollment_Experience__c = pMap.get(c.ParentId).MZR_Enrollment_Experience__c;
                                 updFlag = true;
                             }
                             if(c.MZR_PARAs_Accepted_T_C_Date__c != pMap.get(c.ParentId).MZR_PARAs_Accepted_T_C_Date__c){
                                 c.MZR_PARAs_Accepted_T_C_Date__c = pMap.get(c.ParentId).MZR_PARAs_Accepted_T_C_Date__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Reason_for_Not_Enrolling__c != pMap.get(c.ParentId).MZR_Reason_for_Not_Enrolling__c){
                                 c.MZR_Reason_for_Not_Enrolling__c = pMap.get(c.ParentId).MZR_Reason_for_Not_Enrolling__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Feedback__c != pMap.get(c.ParentId).MZR_Feedback__c){
                                 c.MZR_Feedback__c = pMap.get(c.ParentId).MZR_Feedback__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Derm_Rebate__c != pMap.get(c.ParentId).MZR_Derm_Rebate__c){
                                 c.MZR_Derm_Rebate__c = pMap.get(c.ParentId).MZR_Derm_Rebate__c;
                                 updFlag = true;
                             }
                             if(c.MZR_Tier__c != pMap.get(c.ParentId).MZR_Tier__c){
                                 c.MZR_Tier__c = pMap.get(c.ParentId).MZR_Tier__c;
                                 updFlag = true;
                             }


                             if(updFlag){
                                 accsToUpdate.add(c);
                             }
                         }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('Shiva Final List------------' + accsToUpdate.size());

        Database.SaveResult [] updateResult = Database.update(accsToUpdate, false);
        for (Database.SaveResult r : updateResult) {
            if (!r.isSuccess()) {
                for (Database.Error e : r.getErrors()) {
                    System.debug('Shiva Final Errors: '+ e.getMessage());
                }
            }
        }

    }
}