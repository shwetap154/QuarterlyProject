@isTest
public class UpdateBUPriTerronAccBatch_test {
    @testsetup
    static void setup(){
        DispatchTriggerHandler.bypass('ZTS_EU_Account_PositionTriggerHandler');
        DispatchTriggerHandler.bypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.bypass('AccountTriggerHandler');
        DispatchTriggerHandler.bypass('UserTriggerHandler');
        
        List<Account> accList = new List<Account>();
        
        Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id; 
        
        User usr = CPQ_TestDataFactory.createUser(
            'TestUser',
            'Create',
            'Cory.bartholomew@atginfo.com',
            'cory.bartholomew@atginfo.com.testing',
            'testUser1',
            'clfctest',
            adminProfileId,
            null,
            false
        );
        usr.ZTS_EU_Market__c = 'Brazil';
        insert usr; 
        
        User ffUser = CPQ_TestDataFactory.createUser(
            'salesrep',
            'Create1',
            'Cory.bartholomewtest1@atginfo.com',
            'cory.bartholomewtest1@atginfo.com.testing',
            'salsUser1',
            'sales1',
            adminProfileId,
            null,
            false
        );
        ffUser.ZTS_EU_Market__c = 'Brazil';
        insert ffUser; 
        
        
        Id standardProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1].Id; 
        
        User standardUsr1 = CPQ_TestDataFactory.createUser(
            'TestUserStandard',
            'Create',
            'Cory.bartholomew@atginfo.comstandard',
            'cory.bartholomew@atginfo.com.testingstandard',
            'standard1',
            'stnff',
            standardProfileId,
            null,
            false
        );
        standardUsr1.ZTS_EU_Market__c = 'Brazil';
        insert standardUsr1;
        
        
        system.runAs(usr){
            //Created 7 accounts;
            for(Integer i = 0 ; i < 7; i++){
                Account acct = CPQ_TestDataFactory.createAccount(false);
                acct.Name = 'Test account'+i;
                acct.BillingStreet = 'Hornsey Rd';
                acct.BillingCity = 'London';
                acct.BillingPostalCode = 'N7 7AJ';
                acct.BillingCountry = 'Brazil';
                acct.ZTS_EU_Market__c = 'Brazil';
                acct.ZTS_EU_Zip_Postal_Code__c = '00001';
                acct.ZTS_EU_Main_Phone__c = '1234';
                accList.add(acct);
            }
            insert accList;     
            
            //Create List of Territories 
            List<ZTS_EU_Territory__c>territoryList = new List<ZTS_EU_Territory__c>();
            ZTS_EU_Territory__c territory1 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test1','Territory', true); 
            territory1.name = 'BRA-TER-RU-AM-CT-841010';
            territoryList.add(territory1);
            
            ZTS_EU_Territory__c territory2 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test2','Territory', true); 
            territory2.name = 'BRA-TER-CA-AM-CT-841010';
            territoryList.add(territory2);  
            
            ZTS_EU_Territory__c territory3 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test3','Territory', true); 
            territory3.name = 'BRA-TER-EQ-AM-CT-841010';
            territoryList.add(territory3);  
            
            ZTS_EU_Territory__c territory4 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test4','Territory', true); 
            territory4.name = 'BRA-TER-PY-AM-CT-841010';
            territoryList.add(territory4);  
            
            ZTS_EU_Territory__c territory5 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test5','Territory', true); 
            territory5.name = 'BRA-TER-SW-AM-CT-841010';
            territoryList.add(territory5);   
            
            ZTS_EU_Territory__c territory6 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test6','Territory', true); 
            territory6.name = 'BRA-TER-AQ-AM-CT-841010';
            territoryList.add(territory6);
            
            ZTS_EU_Territory__c territory7 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test7','Territory', true); 
            territory7.name = 'BRA-TER-VX-AM-CT-841010';
            territoryList.add(territory7);
            
             /*  ZTS_EU_Territory__c territory8 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test1','Territory', true); 
            territory8.name = 'BRA-TER-RU-AM-CT-841011';
            territoryList.add(territory8);  
            //update territoryList;
            
            ZTS_EU_Territory__c territory9 = CPQ_TestDataFactory.createTerritory('Brazil',null, 'Mariama Barbosa Test1','Territory', true); 
            territory9.name = 'BRA-TER-RU-AM-CT-841012';
            territoryList.add(territory9);  */
            update territoryList;
            
            //Created List of Positions
            List<ZTS_EU_Position__c> posList = new List<ZTS_EU_Position__c>();
            ZTS_EU_Position__c position1 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory1, true);
            position1.name = 'BRA-POS-RU-AM-CT-841010';
            position1.ZTS_PrimaryUser__c = true; 
            posList.add(position1);
            
            ZTS_EU_Position__c position2 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory2, true);
            position2.name = 'BRA-POS-CA-AM-CT-841010';
            position2.ZTS_PrimaryUser__c = true; 
            posList.add(position2);
            
            ZTS_EU_Position__c position3 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory3, true);
            position3.name = 'BRA-POS-EQ-AM-CT-841010';
            position3.ZTS_PrimaryUser__c = true; 
            posList.add(position3);
            
            ZTS_EU_Position__c position4 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory4, true);
            position4.name = 'BRA-POS-PY-AM-CT-841010';
            position4.ZTS_PrimaryUser__c = true;   
            posList.add(position4);
            
            ZTS_EU_Position__c position5 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory5, true);
            position5.name = 'BRA-POS-SW-AM-CT-841010';
            position5.ZTS_PrimaryUser__c = true;
            posList.add(position5);
            
            ZTS_EU_Position__c position6 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory6, true);
            position6.name = 'BRA-POS-AQ-AM-CT-841010';
            position6.ZTS_PrimaryUser__c = true;       
            posList.add(position6);
            
            ZTS_EU_Position__c position7 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory7, true);
            position7.name = 'BRA-POS-VX-AM-CT-841010';
            position7.ZTS_PrimaryUser__c = true;  
            posList.add(position7);
            
            /*ZTS_EU_Position__c position8 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory8, true);
            position8.name = 'BRA-POS-RU-AM-CT-841011';
            position8.ZTS_PrimaryUser__c = true;  
            posList.add(position8);
            
            ZTS_EU_Position__c position9 = CPQ_TestDataFactory.createZoetisPosition(ffUser, territory9, true);
            position9.name = 'BRA-POS-RU-AM-CT-841012';
            position9.ZTS_PrimaryUser__c = true;  
            posList.add(position9);
            */
            update posList;
            
            //Created List of Account Territories
            List<ZTS_AccountTerritory__c> accTerrList = new List<ZTS_AccountTerritory__c>();
            for(Integer i = 0; i < territoryList.size(); i++){
                accTerrList.add(CPQ_TestDataFactory.createAccountTerritory(accList.get(0),territoryList.get(i), true, false));
            }
            insert accTerrList;
 
            //Created List of Account Positions
            List<ZTS_EU_Account_Position__c> accPosList = new List<ZTS_EU_Account_Position__c>();
            for(Integer i = 0; i < territoryList.size() ; i++){
                accPosList.add(CPQ_TestDataFactory.createAccountPosition(accList.get(0), posList.get(i), accTerrList.get(i), false));
            }
            insert accPosList;
            
            //updated call target for one AP
            accPosList.get(0).ZTS_EU_Call_Target__c = 10;
            update accPosList.get(0);
            
            //Adding different Type of positions to all Accounts
            //List of Account territory for differnt Accounts
            List<ZTS_AccountTerritory__c> listOfAccTerr =  new List<ZTS_AccountTerritory__c>();
            for(Integer i = 0; i< accList.size(); i++ ){
                listOfAccTerr.add(CPQ_TestDataFactory.createAccountTerritory(accList.get(i) ,territoryList.get(i), true, false));
            }
            insert listOfAccTerr;
            
            //List of Account Positions for differnt Accounts
            List<ZTS_EU_Account_Position__c> listOfAccPos =  new List<ZTS_EU_Account_Position__c>();
            for(Integer i = 0; i< accList.size(); i++ ){
                listOfAccPos.add(CPQ_TestDataFactory.createAccountPosition(accList.get(i),posList.get(i), listOfAccTerr.get(i), false));       
            }
            insert listOfAccPos;
            
           	listOfAccPos.get(4).ZTS_EU_Call_Target__c = 22;
            update listOfAccPos.get(4);
            
        }
        DispatchTriggerHandler.clearBypass('ZTS_EU_Account_PositionTriggerHandler');
        DispatchTriggerHandler.clearBypass('ZTS_EU_PositionTriggerHandler');
        DispatchTriggerHandler.clearBypass('AccountTriggerHandler');
        DispatchTriggerHandler.clearBypass('UserTriggerHandler');
    }
    @isTest
    static void test1(){
        test.startTest();
        User U = [SELECT Id,IsActive FROM User WHERE firstName='TestUser' LIMIT 1];
        system.runAs(U){
            database.executeBatch(new UpdateBUPriTerrOnAccBatch());
          
        }


        User U2 =[SELECT Id FROM User WHERE FirstName='TestUser' LIMIT 1];
        system.runAs(U2){
           
            UpdateBUPriTerrOnAccBatch sh1 = new UpdateBUPriTerrOnAccBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('UpdateBUPriTerrOnAccBatchUnitTest', sch, sh1); 
             
        }

     test.stopTest();    
        
                
        List<Account> accId1 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account1' limit 1 ];

        String caPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%CA%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true and  ZTS_EU_Account__c in : accId1][0].ZTS_EU_Position__r.Name;

        system.debug('caPosName' +caPosName);
        system.debug('AccName' +accId1[0].ZTS_CLAR_CA_Primary_Territory__c);

        System.assertEquals(caPosName,accId1[0].ZTS_CLAR_CA_Primary_Territory__c );  
      
      
  		List<Account> accId2 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c, ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account4' limit 1 ];

        String primaryPosName  =  [SELECT Id,ZTS_EU_Position__r.Name FROM ZTS_EU_Account_Position__c 
                                    WHERE Exclude_Sales__c = false 
                                    AND ZTS_EU_Active__c = true 
                                    AND ZTS_EU_Call_Target__c!=null AND  ZTS_EU_Account__c  in : accId2 Order By ZTS_EU_Call_Target__c DESC LIMIT 1][0].ZTS_EU_Position__r.Name;
   
        System.assertEquals(primaryPosName,accId2[0].ZTS_CLAR_Zoetis_Primary_Territory__c);   

        String swPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%SW%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true  and  ZTS_EU_Account__c in : accId2][0].ZTS_EU_Position__r.Name;
        System.assertEquals(swPosName,accId2[0].ZTS_CLAR_SW_Primary_Territory__c );   
        
        List<Account> accId3 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_AQ_Primary_Territory__c, ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account5' limit 1 ];

        String aqPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%AQ%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true and  ZTS_EU_Account__c in : accId3][0].ZTS_EU_Position__r.Name;
        System.assertEquals(aqPosName,accId3[0].ZTS_CLAR_AQ_Primary_Territory__c); 
        
        List<Account> accId4 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_AQ_Primary_Territory__c,ZTS_CLAR_RU_Primary_Territory__c, ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account0' limit 1 ];
        
        String ruPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%RU%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true  and  ZTS_EU_Account__c in : accId4][0].ZTS_EU_Position__r.Name;
       
        System.assertEquals(ruPosName,accId4[0].ZTS_CLAR_RU_Primary_Territory__c); 
        
        List<Account> accId5 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_AQ_Primary_Territory__c,ZTS_CLAR_RU_Primary_Territory__c,ZTS_CLAR_PY_Primary_Territory__c, ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account3' limit 1 ];
        
        String pyPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%PY%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true  and  ZTS_EU_Account__c in : accId5][0].ZTS_EU_Position__r.Name;
       
        System.assertEquals(pyPosName,accId5[0].ZTS_CLAR_PY_Primary_Territory__c); 
        
        List<Account> accId6 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_AQ_Primary_Territory__c,ZTS_CLAR_RU_Primary_Territory__c,ZTS_CLAR_PY_Primary_Territory__c,ZTS_CLAR_EQ_Primary_Territory__c ,ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account2' limit 1 ];
        
        String eqPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%EQ%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true  and  ZTS_EU_Account__c in : accId6][0].ZTS_EU_Position__r.Name;
       
        System.assertEquals(eqPosName,accId6[0].ZTS_CLAR_EQ_Primary_Territory__c);         
                
        List<Account> accId7 = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c,ZTS_CLAR_VX_Primary_Territory__c,ZTS_CLAR_SW_Primary_Territory__c,ZTS_CLAR_EQ_Primary_Territory__c,ZTS_CLAR_AQ_Primary_Territory__c,ZTS_CLAR_RU_Primary_Territory__c,ZTS_CLAR_PY_Primary_Territory__c, ZTS_CLAR_Zoetis_Primary_Territory__c from Account where name = 'Test account6' limit 1 ];
        
        String vxPosName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%VX%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true  and  ZTS_EU_Account__c in : accId7][0].ZTS_EU_Position__r.Name;
       
        System.assertEquals(vxPosName,accId7[0].ZTS_CLAR_VX_Primary_Territory__c); 
     
    }
    
    
    @isTest
    static void test2(){
          test.startTest();
        User U3 =[SELECT Id FROM User WHERE FirstName='TestUserStandard'];
        system.runAs(U3){
            database.executeBatch(new UpdateBUPriTerrOnAccBatch());
         
        }
        List<Account> accId = [SELECT id, name,ZTS_CLAR_CA_Primary_Territory__c from Account where name = 'Test account0' limit 1 ];
        
        String posName  =  [SELECT id,  ZTS_EU_Account__c, ZTS_EU_Position__r.Name  
                            from ZTS_EU_Account_Position__c  
                            where ZTS_EU_Position__r.name like '%CA%' and Exclude_Sales__c = false 
                            and ZTS_EU_Active__c = true and ZTS_EU_Position__r.ZTS_PrimaryUser__c = true and  ZTS_EU_Account__c in : accId][0].ZTS_EU_Position__r.Name;
        
        System.assertEquals(null,accId[0].ZTS_CLAR_CA_Primary_Territory__c ); 
  test.stopTest();
    }
    
}