/* Test class for ZTS_addrUpdateOnAccount */
@isTest
public class ZTS_addrUpdateOnAccount_Test 
{
    @testSetup
    public static void setup()
    {
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
    }
    
    @isTest
    public static void testUpdateAccOnPrimAddrCreationAndModification()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'usUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc.ZTS_EU_Market__c = 'United States';
            acc.BillingPostalCode = '00000';
            acc.BillingCity = 'testCity';
            acc.BillingState = 'testState';
            acc.BillingStreet = 'testStreet';
            insert acc;
            Address__c addr = [SELECT ZTS_US_Primary__c FROM Address__c WHERE ZTS_EU_Account__c = :acc.Id];
            addr.ZTS_US_Primary__c = false;
            update addr;
            Contact cont = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            cont.ZTS_EU_Market__c = 'United States';
            cont.AccountId = acc.Id;
            insert cont;
            
            
            
            ZTS_EU_Affiliations__c aff = [SELECT Id, ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c FROM ZTS_EU_Affiliations__c];
            acc.ZTS_EU_Primary_Address__c = aff.ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c;
            
            State_Country__c sc = new State_Country__c();
            sc.name = 'testName';
            sc.ZTS_EU_Country__c = 'testCountry';
            insert sc;
            
            Address__c primaryAddress = new Address__c(ZTS_EU_Account__c = acc.Id, ZTS_US_Primary__c = true, ZTS_Longitude__c = 10, ZTS_Latitude__c = 10, ZTS_EU_State_County__c = sc.Id, Zip_Postal_Code__c = '00000', ZTS_EU_Country__c = 'testCountry');
            insert primaryAddress;            
            
            update primaryAddress;
            update acc;
            
            List<Address__C> triggerNew = new List<Address__c>{primaryAddress};
            Map<Id,Address__C> addressNewMap = new Map<Id, Address__c>(triggerNew);
            
            ZTS_addrUpdateOnAccount.chkUpdate = true;
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(triggerNew, addressNewMap);
            
            //System.assertEquals(10, [SELECT Id, PIT_PrimaryLocation__longitude__s FROM Account WHERE Id = :acc.Id].PIT_PrimaryLocation__longitude__s);
            
            Map<Id,Address__C> addressOldMap = addressNewMap;            
            ZTS_addrUpdateOnAccount.chkUpdate = true;
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrModification(new List<Address__c>{new Address__c(Id = primaryAddress.Id, ZTS_EU_Account__c = acc.Id, ZTS_US_Primary__c = true, ZTS_EU_Primary__c = true, ZTS_Longitude__c = 12, ZTS_Latitude__c = 10)}, 
                                                                    addressOldMap, 
                                                                    new Map<Id, Address__c>(new List<Address__c>{new Address__c(Id = primaryAddress.Id, ZTS_EU_Account__c = acc.Id, ZTS_US_Primary__c = true, ZTS_Longitude__c = 12, ZTS_Latitude__c = 10)}));
            
            //System.assertEquals(12, [SELECT Id, PIT_PrimaryLocation__longitude__s FROM Account WHERE Id = :acc.Id].PIT_PrimaryLocation__longitude__s);
        }
    }
    
    @isTest
    public static void testUpdateAccOnPrimAddrCreationAndModification1()
    {
        User usr1 = new User();
        usr1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr1.FirstName = 'usUser1';
        usr1.zts_eu_market__c = 'United States';
        insert usr1;
        
        System.runAs(usr1)
        {
            Account acc1 = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            acc1.ZTS_EU_Market__c = 'United States';
            acc1.BillingPostalCode = '00001';
            acc1.BillingCity = 'testCity1';
            acc1.BillingState = 'testState1';
            acc1.BillingStreet = 'testStreet1';
            insert acc1;
            Address__c addr1 = [SELECT ZTS_US_Primary__c FROM Address__c WHERE ZTS_EU_Account__c = :acc1.Id];
            addr1.ZTS_US_Primary__c = false;
            update addr1;
            Contact cont1 = ZTS_EU_DataUtilityTest.createContactRecord(1)[0];
            cont1.ZTS_EU_Market__c = 'United States';
            cont1.AccountId = acc1.Id;
            insert cont1;
            
            
            
            ZTS_EU_Affiliations__c aff1 = [SELECT Id, ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c FROM ZTS_EU_Affiliations__c];
            acc1.ZTS_EU_Primary_Address__c = aff1.ZTS_EU_Contact__r.ZTS_EU_Primary_Address__c;
            
            State_Country__c sc1 = new State_Country__c();
            sc1.name = 'testName';
            sc1.ZTS_EU_Country__c = 'testCountry1';
            insert sc1;
            
            Address__c primaryAddress1 = new Address__c(ZTS_EU_Account__c = acc1.Id, ZTS_US_Primary__c = true, ZTS_US_Longitude__c = 10, ZTS_US_Latitude__c = 10, ZTS_EU_State_County__c = sc1.Id, Zip_Postal_Code__c = '00001', ZTS_EU_Country__c = 'testCountry1');
            insert primaryAddress1;            
            
            update primaryAddress1;
            update acc1;
            
            List<Address__C> triggerNew = new List<Address__c>{primaryAddress1};
            Map<Id,Address__C> addressNewMap = new Map<Id, Address__c>(triggerNew);
            
            ZTS_addrUpdateOnAccount.chkUpdate = true;
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(triggerNew, addressNewMap);
            
            //System.assertEquals(10, [SELECT Id, PIT_PrimaryLocation__longitude__s FROM Account WHERE Id = :acc.Id].PIT_PrimaryLocation__longitude__s);
            
            Map<Id,Address__C> addressOldMap = addressNewMap;            
            ZTS_addrUpdateOnAccount.chkUpdate = true;
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrModification(new List<Address__c>{new Address__c(Id = primaryAddress1.Id, ZTS_EU_Account__c = acc1.Id, ZTS_US_Primary__c = true, ZTS_US_Longitude__c = 12, ZTS_US_Latitude__c = 10)}, 
                                                                    addressOldMap, 
                                                                    new Map<Id, Address__c>(new List<Address__c>{new Address__c(Id = primaryAddress1.Id, ZTS_EU_Account__c = acc1.Id, ZTS_US_Primary__c = true, ZTS_US_Longitude__c = 12, ZTS_US_Latitude__c = 10)}));
            
            //System.assertEquals(12, [SELECT Id, PIT_PrimaryLocation__longitude__s FROM Account WHERE Id = :acc.Id].PIT_PrimaryLocation__longitude__s);
        }
    }
}