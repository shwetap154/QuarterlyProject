@isTest(seeAllData = False)
public class ZTS_EU_HQRating_Update_Test {
    @isTest static void testCreate()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.startTest();
            Account acc=new Account(Name='TestAccountZoetis123',Type='Community',ZTS_EU_EQ_HQ_Penetration_Rating__c='EQ-H',
                                    ZTS_EU_Market__c='United Kingdom',
                                    Practice_Management_Software__c = 'Other',
                                    Other_Practice_Management_Software__c = 'Sample Practice Management Software',
                                    ZTS_EU_RAT_EQ_HQ__c = 'E2',
                                    ZTS_EU_Zip_Postal_Code__c = '12345');
            Insert acc;
            
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            Account acc1=new Account(Name='TestAccountZoetis234',Type='Community',ZTS_EU_Parent_Id__c=acc.Id,ZTS_EU_EQ_HQ_Penetration_Rating__c='EQ-H',
                                     ZTS_EU_RAT_EQ_HQ__c = 'E2',ZTS_EU_Market__c='United Kingdom', ZTS_EU_Zip_Postal_Code__c = '12345');
            //ZTS_EU_EQ_HQ_Penetration_Rating__c='EQ-H',ZTS_EU_RAT_CA_HQ__c='C2');
            insert acc1;
            
            
            /* acc.ZTS_EU_EQ_HQ_Penetration_Rating__c='EQ-M';
acc.ZTS_EU_RAT_EQ_HQ__c='E1';
List<Account> accList = new List<Account>();
accList.add(acc);
update accList;
*/
            
            
            List<Account> oldlist = new List<Account>([Select id,Name,ZTS_EU_Parent_Id__c,ZTS_EU_EQ_HQ_Penetration_Rating__c,ZTS_EU_RAT_EQ_HQ__c from Account where Id =:acc.id AND ZTS_EU_Market__c != 'United States']);
            
            Map<Id, Account> OldmapFromList = new Map<Id, Account>(oldlist);
            System.debug('<<<OldmapFromList>>>>'+OldmapFromList);
            List<Account> newlist = new List<Account>();
            for(Account Accitt : oldlist){
                Accitt.ZTS_EU_Parent_Id__c = oldlist[0].id;
                Accitt.ZTS_EU_EQ_HQ_Penetration_Rating__c = 'EQ-M';
                Accitt.ZTS_EU_RAT_EQ_HQ__c= 'E1';
                newlist.add(Accitt);
            }
            DispatchTriggerHandler.firstTimeTracker = new Set<String>();
            update newlist;
            
            Map<Id, Account> NewmapFromList = new Map<Id, Account>(newlist);
            System.debug('<<<NewmapFromList>>>>'+NewmapFromList);
            
            
            ZTS_EU_HQRating_Update.HQRating_Update(NewmapFromList,OldmapFromList);
        }  
    }
}