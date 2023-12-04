@isTest
private class AccountUtilityTest {
  
    @testSetup
    private static void setup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'Germany';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.ZTS_EU_Market__c = 'Germany';
            acc.Email__c = 'InternationUser@user.International.com';
            insert acc;

            Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            cont.ZTS_EU_Market__c = 'Germany';
            cont.AccountId = acc.Id;
            cont.Email = acc.Email__c;
            insert cont;
        }
    }

    @isTest
    private static  void syncOptOutFieldTestCountryUpdateTrue() {
       
        User usr = [SELECT Id FROM User WHERE FirstName = 'intlUser' AND zts_eu_market__c = 'Germany']; 
        System.runAs(usr)
        {
            List<string> emailList = new List<string>();
            List<Account> accntsToUpdate = new List<Account>();
            Set<Id> accountIDs = new Set<Id>();
            Map<string,boolean> emailMap = new Map<string,boolean>();
            
            List<Account> accnt = [SELECT Id,Name,Email__c,ZTS_EU_Country__c,ZTS_EU_Market__c,ZTS_EU_Opt_Out_Email__c 
                                    FROM Account 
                                    WHERE (ZTS_EU_Country__c = 'Germany' OR ZTS_EU_Market__c = 'Germany') 
                                    AND Email__c != '' 
                                    LIMIT 1];
           
            Test.startTest();
            for(Account a : accnt){
                accountIDs.add(a.Id);
                emailList.add(a.Email__c);
                a.ZTS_EU_Opt_Out_Email__c = true;
                emailMap.put(a.Email__c, true);

                accntsToUpdate.add(a);
            }

            try {
                update accntsToUpdate;
            } catch (DmlException e) {
                // Process exception here
                system.debug('Failed to update Account in AccountUtilityTEST.syncOptOutFieldTestCountryUpdateFalse');
                system.debug(e.getMessage());
            }
            
            //Test True scenario
            //AccountUtility.syncOptOutField(emailList,accountIDs,emailMap);
            Test.stopTest();

            //Get our contacts
            List<Contact> contactList = [SELECT Id,AccountId,Email,ZTS_EU_Opt_Out_Email__c 
                                            FROM Contact 
                                            WHERE (ZTS_EU_Country__c = 'Germany' OR ZTS_EU_Market__c = 'Germany') 
                                            AND AccountId IN :accnt 
                                            AND Email IN:emailList];      
            for(Contact c:contactList){
                //assert that all the contacts have opt out set to true
            System.assertEquals(true,c.ZTS_EU_Opt_Out_Email__c,'The expected value of ZTS_EU_Opt_Out_Email__c is True');
            }
        }
    }
    
    @isTest
    private static void syncOptOutFieldTestCountryUpdateFalse() {

        User usr = [SELECT Id FROM User WHERE FirstName = 'intlUser' AND zts_eu_market__c = 'Germany']; 
        System.runAs(usr)
        {
            List<string> emailList = new List<string>();
            List<Account> accntsToUpdate = new List<Account>();
            Set<Id> accountIDs = new Set<Id>();
            Map<string,boolean> emailMap = new Map<string,boolean>();
            
            List<Account> accnt = [SELECT Id,Name,Email__c,ZTS_EU_Country__c,ZTS_EU_Market__c,ZTS_EU_Opt_Out_Email__c 
                                    FROM Account 
                                    WHERE (ZTS_EU_Country__c = 'Germany' OR ZTS_EU_Market__c = 'Germany') 
                                    AND Email__c != '' 
                                    LIMIT 1];
            
            Test.startTest();
            for(Account a : accnt){
                accountIDs.add(a.Id);
                emailList.add(a.Email__c);
                a.ZTS_EU_Opt_Out_Email__c = false;
                emailMap.put(a.Email__c, false);

                accntsToUpdate.add(a);
            }

            try {
                update accntsToUpdate;
            } catch (DmlException e) {
                // Process exception here
                system.debug('Failed to update Account in AccountUtilityTEST.syncOptOutFieldTestCountryUpdateFalse');
                system.debug(e.getMessage());
            }
            
            //Test False scenario
            //AccountUtility.syncOptOutField(emailList,accountIDs,emailMap);
            Test.stopTest();

            //Get our contacts
            List<Contact> contactList = [SELECT Id,AccountId,Email,ZTS_EU_Opt_Out_Email__c 
                                            FROM Contact 
                                            WHERE (ZTS_EU_Country__c = 'Germany' OR ZTS_EU_Market__c = 'Germany') 
                                            AND AccountId IN :accnt 
                                            AND Email IN:emailList];    
                                            
            for(Contact c:contactList){
                //assert that all the contacts have opt out set to False
                System.assertEquals(false,c.ZTS_EU_Opt_Out_Email__c,'The expected value of ZTS_EU_Opt_Out_Email__c is False');
            }
        }
    }
    
}