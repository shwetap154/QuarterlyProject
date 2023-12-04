/*******************************************************************************************************************************************
* File Name     :  ZTS_US_AddressUpdateOnAccount_Test
* Description   :   Test class for trigger      
* @author       :  Deloitte consulting
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     7/14         Sonali             Created the Class.
*****************************************************************************************************************************************/



@isTest
public class ZTS_US_AddressUpdateOnAccount_Test 
{   
     public static testMethod void updateAccOnPrimAddrCreationTriggerTest(){
     
         List<Account> accList = ZTS_EU_DataUtilityTest.createAccountRecord(1);   
         for (Account a : accList)
         {
                a.ZTS_EU_Market__c = 'United States';
                a.BillingPostalCode = '12345';
                a.BillingCity = 'Boca Raton';
                a.BillingState = 'Florida';
                a.BillingStreet = 'Elm Lane';
         }
         insert accList;
            
            
        List<Address__c> addList = new List<Address__c>();
        
        State_Country__c sc = new State_Country__c();
        sc.Name = 'Sachsen';
        sc.ZTS_EU_Country__c = 'United States';
        insert sc;
        
        for(Integer i=0;i<1;i++) {
            Address__C addr = new Address__C();
            addr.ZTS_US_Primary__c = false;
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
         
         ZTS_EU_updatePrimaryAddonAccount.updatePrimaryaddress(addList[0].Id);
         for (Address__c ad: addlist ){
             
             ad.Zip_Postal_Code__c ='67890';
         }
         System.debug('TestaddList' + addList);
         update addlist;
            
	}
}