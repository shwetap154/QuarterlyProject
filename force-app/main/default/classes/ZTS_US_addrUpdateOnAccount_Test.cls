/*******************************************************************************************************************************************
* File Name     :  ZTS_US_addrUpdateOnAccount_Test
* Description   :           
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Sonali             Created the Class.
*****************************************************************************************************************************************/



@isTest
public class ZTS_US_addrUpdateOnAccount_Test 
{   
    public static testMethod void updateAccOnPrimAddrCreationTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            Account acc = ZTS_EU_DataUtilityTest.createAccountRecord(1)[0];
            insert acc;
            
            List<Address__c> addList = new List<Address__c>();
            
            State_Country__c sc = new State_Country__c();
            sc.Name = 'Sachsen';
            sc.ZTS_EU_Country__c = 'United States';
            insert sc;
            
            for(Integer i=0;i<1;i++) 
            {
                Address__C addr = new Address__C();
                addr.ZTS_US_Primary__c = true;
                addr.ZTS_Address_Line_1__c  = 'Test Street'+i;
                addr.Zip_Postal_Code__c ='12345';
                addr.ZTS_US_State_Province__c = 'New York';
                addr.ZTS_EU_Country__c ='United States';
                addr.ZTS_EU_City__c  = 'New York';
                addr.ZTS_EU_Address_Line_2__c ='Test Addr' + i;
                addr.ZTS_EU_Account__c = acc.id;
                addr.ZTS_EU_State_County__c = sc.Id;
                addList.add(addr);
            }
            
            insert addList;
            
            Map<Id,Address__C> addressMap = new Map<Id,Address__C>();
            for(Address__c a: addList){
                addressMap.put(a.Id, a);
            }
            test.startTest();
            ZTS_addrUpdateOnAccount.updateAccOnPrimAddrCreation(addList,addressMap);
            test.stopTest();
        }
    }   
    
	public static testMethod void updateAccOnPrimAddrModificationTest(){
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
    
        System.runAs(usr)
        {
            List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);   
			insert accList;
                
            List<Address__c> addList = new List<Address__c>();
            State_Country__c sc = new State_Country__c();
            sc.Name = 'Sachsen';
            sc.ZTS_EU_Country__c = 'United States';
            
            insert sc;
            
            for(Integer i=0;i<1;i++) {
                Address__C addr = new Address__C();
                addr.ZTS_US_Primary__c = true;
                addr.ZTS_Address_Line_1__c  = 'Test Street'+i;
                addr.Zip_Postal_Code__c ='12345';
                addr.ZTS_US_State_Province__c = 'New York';
                addr.ZTS_EU_Country__c ='United States';
                addr.ZTS_EU_City__c  = 'New York';
                addr.ZTS_EU_Address_Line_2__c ='Test Addr' + i;
                addr.ZTS_EU_Account__c = accList[i].id;
                addr.ZTS_EU_State_County__c = sc.Id;
                addList.add(addr);
			}
                    
			insert addList;
   
            //Create map to add old value
            Map<Id,Address__C> addressOldMap = new Map<Id,Address__C>();
            for(Address__c a: addList){
                addressOldMap.put(a.Id, a);
            }
            
            
            for (Address__c ad: addlist ){
                ad.Zip_Postal_Code__c ='67890';
            }
            System.debug('TestaddList' + addList);
            update addlist;

            Map<Id,Address__C> addressNewMap = new Map<Id,Address__C>();
            for(Address__c ad: addList){
                addressNewMap.put(ad.Id, ad);
            }
            test.startTest();
            //ZTS_addrUpdateOnAccount.updateAccOnPrimAddrModification(addList,addressOldMap,addressNewMap);
            test.stopTest();
		}
	}
}