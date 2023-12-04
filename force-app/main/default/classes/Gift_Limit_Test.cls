/**
 * @description       : Contains Unit Tests for ZTS_EU_GiftUtility.checkLimitsForExpensiveAndCheapGifts and provides some coverage for:
 *                      ZTS_EU_GiftTrigger, ZTS_EU_GiftTriggerHandler, and ZTS_EU_GiftTriggerService.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   06-21-2014   Unknown                     Initial Version
 * 1.1   03-21-2022   Ethan Hirsch @ Zoetis Inc   Fix Unit Test errors due to Market issues.
**/
@IsTest
public class Gift_Limit_Test 
{
    private final static string testMarket = 'United Kingdom';

    static Account testAcct;
    static Account getTestAcct() {
        if(testAcct == null){
            testAcct = new Account(
                Name = 'ApexTest Account', 
                Type='Farm', 
                ZTS_EU_Address_Line_1__c='test address',
                ZTS_EU_Main_Phone__c='9876789876',
                ZTS_EU_City__c='new delhi',
                CurrencyIsoCode='EUR', 
                ZTS_EU_Market__c = testMarket, 
                Practice_Management_Software__c = 'Animana',
                ZTS_EU_Zip_Postal_Code__c = '12345',
                BillingPostalCode = '12345',
                BillingCity = 'Boca Raton',
                BillingState = 'Florida',
                BillingStreet = 'Elm Lane'
            );
            insert testAcct;
        }

        return testAcct;
    }

    static Contact testCon;
    static Contact getTestCon() {
        if(testCon == null){
            testCon = new Contact(
                LastName = 'ApexTest_1',
                FirstName = 'Lakshmi', 
                AccountId = getTestAcct().Id, 
                Phone = '123456789', 
                MobilePhone = '9876454321', 
                Is_Government_Official__c = 'Yes'
            );
            insert testCon;
        }

        return testCon;
    }

    @IsTest
    public static void checkLimitsForExpensiveAndCheapGifts_negativeTest()
    {
        User testUser = ZTS_EU_DataUtilityTest.createUserWithProfileAndMarket('System Administrator', testMarket);
        insert testUser;

        system.runAs(testUser) {
            List<ZTS_EU_Gift__c> gifts = new List<ZTS_EU_Gift__c>{
                new ZTS_EU_Gift__c( ZTS_EU_Contact__c = getTestCon().Id )
            };

            Boolean giftError = false;
            Test.startTest();
                try{
                    insert gifts;
                } catch (Exception e) {
                    giftError = true;
                }
            Test.stopTest();

            System.assert(giftError);
        }
    }
}