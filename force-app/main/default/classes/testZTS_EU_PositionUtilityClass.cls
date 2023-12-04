/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest /*(seealldata = true)*/
private class testZTS_EU_PositionUtilityClass{
    
    static testMethod void PositionUtilityClass() {
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidsUser';
        usr.zts_eu_market__c = 'United Kingdom';
        insert usr;
        
        System.runAs(usr)
        {
            test.starttest();
            
            Account acc = new Account();  
            acc.name = 'testAccount';
            acc.ZTS_EU_TSF_PBC__c = 'terrName';
            acc.ZTS_EU_Market__c = 'Germany';
            acc.Practice_Management_Software__c = 'Animana';
            acc.BillingStreet = '123 fake street';
            acc.BillingCity = 'Berlin';
            acc.BillingState = 'Murica';
            acc.BillingCountry = 'Germany';
            acc.BillingPostalCode = '12345';
            acc.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert acc;
            
            User thisUser = [ select Id from User where Id = :UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States' ];
            List<ETM_Required_Ids__mdt> mdtETMRequiredIds = [SELECT DeveloperName,ETM_Model_ID__c,ETM_Type_Id__c FROM ETM_Required_Ids__mdt Where DeveloperName = 'Default_Values' Limit 1];
            Territory2 t = new Territory2();
            System.runAs (thisUser) {           
                t.name = 'terrName';
                t.DeveloperName = 'terrName';
                t.Territory2ModelId=mdtETMRequiredIds[0].ETM_Model_ID__c;
                t.Territory2TypeId=mdtETMRequiredIds[0].ETM_Type_Id__c;
                insert t;
            }
            
            ObjectTerritory2Association obj = new ObjectTerritory2Association(ObjectId = acc.Id, 
                                                                              Territory2Id = t.Id, 
                                                                              AssociationCause='Territory2Manual' );
            insert obj;
            
            ZTS_EU_Territory__c terr = new ZTS_EU_Territory__c();
            terr.name = 'terrName';
            terr.ZTS_EU_Terr_SFID__c = t.id;
            terr.ZTS_EU_Market__c = 'Poland';
            insert terr;
            
            list<ZTS_EU_Position__c> posList = new list<ZTS_EU_Position__c>();
            ZTS_EU_Position__c pos = new ZTS_EU_Position__c();
            pos.ZTS_EU_Territory__c = terr.id;
            posList.add(pos);
            insert posList;
            
            List<Account> accList = new List<Account>();
            Account acc1 = new Account();  
            acc1.name = 'testAccountdeactivation';
            acc1.ZTS_EU_TSF_PBC__c = 'terrName'; 
            acc1.ZTS_EU_Market__c='United Kingdom';
            acc1.Practice_Management_Software__c = 'Other';
            acc1.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            acc1.ZTS_EU_Zip_Postal_Code__c = '12345';
            accList.add(acc1);
            insert accList;
            
            Map<Id,ZTS_EU_Position__c> posMap = new Map<Id,ZTS_EU_Position__c>();
            for(ZTS_EU_Position__c ps : posList)
                posMap.put(ps.Id, ps);
            
            
            ZTS_EU_PositionUtilityClass.InsertAccountPosition(posList);	
            
            
            ZTS_EU_PositionUtilityClass.checkForChildRecords (posList, posMap);
            
            //Code Added by CloudSense:Parvez for defect T-13955/DEF-000122
            
            ZTS_EU_Position__c testpos1 = new ZTS_EU_Position__c();
            testpos1.ZTS_EU_Territory__c = terr.id;
            testpos1.ZTS_EU_Is_Active__c = true;
            testpos1.ZTS_EU_Employee__c = thisUser.Id;
            insert testpos1;
            
            ZTS_EU_Position__c testpos2 = new ZTS_EU_Position__c();
            testpos2.ZTS_EU_Territory__c = terr.id;
            insert testpos2;    
            
            Account testacc = new Account();  
            testacc.name = 'Test Account for T-13955';
            testacc.type = 'Customer';
            testacc.ZTS_EU_Market__c='United Kingdom';
            testacc.Practice_Management_Software__c = 'Other';
            testacc.Other_Practice_Management_Software__c = 'Sample Practice Management Software';
            testacc.ZTS_EU_Zip_Postal_Code__c = '12345';
            insert testacc;
            
            ZTS_EU_Account_Position__c testaccpos = new ZTS_EU_Account_Position__c();
            testaccpos.ZTS_EU_Position__c = testpos1.Id;
            testaccpos.ZTS_EU_Account__c = acc1.id; 
            testaccpos.ZTS_EU_Call_Target__c = 1;
            insert testaccpos;
            
            /*ZTS_EU_Account_Position__c testaccpos2 = new ZTS_EU_Account_Position__c();
            testaccpos2.ZTS_EU_Position__c = testpos1.Id;
            testaccpos2.ZTS_EU_Account__c = testacc.id; 
            testaccpos2.ZTS_EU_Call_Target__c = 1;
            insert testaccpos2;*/
            
            ZTS_EU_PositionUtilityClass.deActivateOrphanAccPos(new List<Account>{acc1,testacc});
            ZTS_EU_PositionUtilityClass.InsertAccountPositionForAccount(accList);
            
            try{
                delete testpos1;  
            }   
            catch(DMLException e)
            {
                system.debug('This is exception');  
            }
            delete testpos2;
            
            //EOC added by CloudSense:Parvez        
            test.stoptest();
        }
    }
}