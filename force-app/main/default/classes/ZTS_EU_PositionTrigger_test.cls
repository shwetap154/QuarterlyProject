@isTest
public class ZTS_EU_PositionTrigger_test {
    
    public static testmethod void PositionInsertTest()
    {        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
            //Create Position with Territory and Account Territory
            ZTS_EU_Territory__c terr1 = new ZTS_EU_Territory__c(Name = 'IND-TER-CA-AM-TEST2',ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='India');
            insert terr1;
            List<ZTS_AccountTerritory__c> accTerrList = new List<ZTS_AccountTerritory__c>();	
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(30);
            for (Account a: accList)
            {
                a.ZTS_EU_Market__c = 'India';
                
            }
            insert accList;
            for(Account arec: accList)
            {
                ZTS_AccountTerritory__c at = new ZTS_AccountTerritory__c (ZTS_EU_Account__c = arec.Id,ZTS_EU_Territory__c = terr1.id, ZTS_EU_Market__c='India');
                accTerrList.add(at);
            }
            insert accTerrList;
            ZTS_EU_Position__c p2 = new ZTS_EU_Position__c();
            p2.ZTS_EU_Territory__c = terr1.id;
            // p2.Name = 'IND-POS-CA-AM-TEST1';
            p2.Market__c = 'India';
            p2.ZTS_EU_Is_Active__c = TRUE;
            
            Database.SaveResult sr1= Database.insert (p2);
            
            
            system.assertEquals(sr1.isSuccess(), true);
        }
    }
    
    public static testmethod void PositionUpdateTest()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;

        System.runAs(usr)
        {
 
            //Create Position with Territory and Account Territory
            ZTS_EU_Territory__c terr1 = new ZTS_EU_Territory__c(Name = 'IND-TER-CA-AM-TEST2',ZTS_EU_Is_Active__c=true,ZTS_EU_Market__c='India');
            insert terr1;
            List<ZTS_AccountTerritory__c> accTerrList = new List<ZTS_AccountTerritory__c>();	
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(30);
            for (Account a: accList)
            {
                a.ZTS_EU_Market__c = 'India';
                
            }
            insert accList;
            for(Account arec: accList)
            {
                ZTS_AccountTerritory__c at = new ZTS_AccountTerritory__c (ZTS_EU_Account__c = arec.Id,ZTS_EU_Territory__c = terr1.id, ZTS_EU_Market__c='India');
                accTerrList.add(at);
            }
            insert accTerrList;
            
            //Create Position without Territory
            ZTS_EU_Position__c p1 = new ZTS_EU_Position__c();
            p1.ZTS_EU_Territory__c  = terr1.Id;      
            p1.Market__c = 'India';
            p1.ZTS_EU_Is_Active__c = TRUE;
            test.startTest();
            Database.SaveResult sr= Database.insert (p1);
            
            test.stopTest();
            system.assertEquals(sr.isSuccess(), true);
        }
    }
}