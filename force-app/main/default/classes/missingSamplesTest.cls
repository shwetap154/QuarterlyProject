@isTest
public class missingSamplesTest
{
    static testMethod void TestmissingSamples()
    {
        ZTS_EU_Species_Product__c p3 = new ZTS_EU_Species_Product__c(Name = 'Test', ZTS_EU_Market__c = 'Italy', ZTS_EU_Type__c = 'Therapeutic Group',CurrencyIsoCode = 'EUR');
        insert p3;
        ZTS_EU_Species_Product__c p2 = new ZTS_EU_Species_Product__c(Name = 'Test', ZTS_EU_Market__c = 'Italy', ZTS_EU_Parent_Species_Product__c = p3.id, ZTS_EU_Type__c = 'Brand',CurrencyIsoCode = 'EUR');
        insert p2;
        ZTS_EU_Species_Product__c p1 = new ZTS_EU_Species_Product__c(Name = 'Test', ZTS_EU_Market__c = 'Italy', ZTS_EU_Type__c = 'MPG', ZTS_EU_Parent_Species_Product__c = p2.id, CurrencyIsoCode = 'EUR');
        insert p1;
        ZTS_EU_Species_Product__c product = new ZTS_EU_Species_Product__c(Name = 'Test', ZTS_EU_Market__c = 'Italy', ZTS_EU_Type__c = 'SKU', ZTS_EU_Parent_Species_Product__c = p1.id,CurrencyIsoCode = 'EUR');
        insert product;
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'eltonUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        Account acc = new Account(Name = 'Test Account', Type = 'Farm', ZTS_EU_Market__c='United Kingdom',
                Practice_Management_Software__c = 'Other',ZTS_EU_Zip_Postal_Code__c = '00000',
                Other_Practice_Management_Software__c = 'Sample Practice Management Software');
        System.runAs(usr)
        {
            insert acc;
        }
        ZTS_DataUtilityTest.createPrimaryContactInactiveProfileCustomSetting();
        Contact con = new Contact(LastName = 'contact', FirstName = 'Test',ZTS_EU_Market__c = 'Italy',ZTS_EU_Contact_type__c = 'Veterinarian',ZTS_EU_Species_Specialty__c = 'Beef', Is_Government_Official__c='No',ZTS_EU_District__c = 'XXX', AccountId = acc.id);
        System.runAs(usr)
        {
            insert con;
        }
        
        Database.BatchableContext batch ;
        List<ZTS_EU_Sample__c> sampleList = new List<ZTS_EU_Sample__c>();
        ZTS_EU_Sample__c sample = new ZTS_EU_Sample__c(ZTS_EU_Contact__c = con.id,ZTS_EU_Product__c = product.id);
        sampleList.add(sample);      
        insert sampleList;
        test.startTest();
        missingSamples  ap = new missingSamples ();
        Database.executeBatch(ap);
        ap.execute(batch,sampleList);
        test.stopTest();
    }

    static List<ZTS_EU_Sample__c> getSampleList() {
        return new List<ZTS_EU_Sample__c>();
    }
  
    static Map<Id, ZTS_EU_Sample__c> getSampleMap() {
        return new Map<Id, ZTS_EU_Sample__c>();
    }

    @IsTest
    static void beforeInsert_test() {
        EUSampleTriggerHandler.beforeInsert( getSampleList() );
    }

    @IsTest
    static void beforeUpdate_test() {
        EUSampleTriggerHandler.beforeUpdate( getSampleList(), getSampleMap(), getSampleList(), getSampleMap() );
    }

    @IsTest
    static void beforeDelete_test() {
        EUSampleTriggerHandler.beforeDelete( getSampleList(), getSampleMap() );
    }

    @IsTest
    static void afterInsert_test() {
        EUSampleTriggerHandler.afterInsert( getSampleList(), getSampleMap() );
    }

    @IsTest
    static void afterDelete_test() {
        EUSampleTriggerHandler.afterDelete( getSampleList(), getSampleMap() );
    }

    @IsTest
    static void afterUndelete_test() {
        EUSampleTriggerHandler.afterUndelete( getSampleList(), getSampleMap() );
    }

    @IsTest
    static void setBypassField_test() {
        EUSampleTriggerHandler.setBypassField( ZTS_EU_Sample__c.Market__c.getDescribe().getSObjectField() );
    }
}