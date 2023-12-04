/***************************************************************************** 
* Class Name     : updateHistoricalCallsBatch_Test
* Description    : This is the testclass for updateHistoricalCallsBatch class
*                
*      
* Created By   : Oeeshi Roy Choudhury(Cognizant Technology Solutions)
* Created Date : 14th Feb, 2017.
*
* Modification Log: 
* ----------------------------------------------------------------------------
* Developer                		Date               Description 
* ----------------------------------------------------------------------------
* Tanmoy Bardhan (Cognizant)	24th Feb 2017		
******************************************************************************/

@isTest
public class updateHistoricalCallsBatch_Test {
    
    static void testCreate()
    {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'intlUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
        Account acc=new Account(
                    Name='AccTest',
                    Type='Community', 
                    ZTS_EU_Market__c = 'Ecuador', 
                    Practice_Management_Software__c = 'Animana',
                    ZTS_EU_Zip_Postal_Code__c = '12345',
                    BillingPostalCode = '12345',
                    BillingCity = 'Boca Raton',
                    BillingState = 'Florida',
                    BillingStreet = 'Elm Lane'
                    );
        insert acc;

        //Call__c c1=new Call__c(ZTS_EU_Account__c=acc.Id);
        //insert c1;
        
        list<call__c> calllst= ZTS_EU_DataUtilityTest1.createCallRecord(1);
        calllst[0].ZTS_EU_Account__c = acc.Id;
        calllst[0].ZTS_EU_Duration__c = '1 hour';
        insert calllst;
        } 
    }
    
    static testmethod void testBatc()
    {
        testCreate();
        test.startTest();
        updateHistoricalCallsBatch obj=new updateHistoricalCallsBatch();
        Database.executeBatch(obj);
        test.stopTest();
    }
    
}