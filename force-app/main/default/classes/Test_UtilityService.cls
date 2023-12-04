@istest(seeAllData=false)
public class Test_UtilityService{

  public static testMethod void Test_UtilityFunction(){
        test.starttest();
       Id recordTypeId = UtilityService.recordTypeId ('Address__c','ZTS_EU_Account_Address');
       map<string,Schema.RecordTypeInfo> getRecordtypeInfosbyName = UtilityService.getRecordtypeInfosbyName ('Address__c');
       map<Id,Schema.RecordTypeInfo> getRecordtypeInfosbyId = UtilityService.getRecordtypeInfosbyId ('Address__c');
       Id recordTypeIdNull = UtilityService.recordTypeId ('','');
       Boolean Accountrun = UtilityService.isaccountAffRun();
       UtilityService.setaccountAffRun();
       Boolean KolRun = UtilityService.iskolRun();
       UtilityService.setkolRunFalse();
       Boolean Accounttrigger = UtilityService.isaccountTriggerRun();
       UtilityService.setAccountTriggerRunFalse();
       Boolean  Contacttriggerrun = UtilityService.iscontactTriggerRun();
       UtilityService.setContactTriggerRunFalse();
       Boolean paprun  = UtilityService.ispapRun();
       UtilityService.setpapRunFalse();
       Boolean terrRun = UtilityService.iscTerritoryRun();
       UtilityService.setcTerritoryRun();
       Boolean  Zipupdate = UtilityService.isZipUpdateRun();
       UtilityService.setisZipUpdateRun();
       Boolean isrevdelAffRun= UtilityService.isrevdelAffRun();
       Boolean isrevinsAffRun= UtilityService.isrevinsAffRun();
       Boolean isrevupdAffRun= UtilityService.isrevupdAffRun();
       Boolean isAffInsertRun= UtilityService.isAffInsertRun();
       Boolean isAffUpdateRun= UtilityService.isAffUpdateRun();
       Boolean isAffbefInsertRun= UtilityService.isAffbefInsertRun();
       Boolean isAffbefUpdateRun= UtilityService.isAffbefUpdateRun();
       Boolean isAffDeleteRun= UtilityService.isAffDeleteRun();
       
       
       
        test.stoptest();
    
    }

    public static testMethod void Test_PhoneNumberUpdate() {
        Map<Integer,String> testNumbers = new Map<Integer,String>();
        Map<Integer,String> noChangeNumbers = new Map<Integer,String>();
        testNumbers.put(1,'7738947894');
        testNumbers.put(2,'17738947894');
        testNumbers.put(3,'+17738947894');
        testNumbers.put(4,'(773)894-7894');
        testNumbers.put(5,'(773) 894-7894 ext. 1234');
        testNumbers.put(6,'+1 (773) 894-7894 ext. 1234');
        testNumbers.put(7,'+07738947894');
        noChangeNumbers.put(7,'+07738947894');
        testNumbers.put(8,'xxx-xxx-xxxx');
        noChangeNumbers.put(8,'xxx-xxx-xxxx');
        testNumbers.put(9,'test@test.com');
        noChangeNumbers.put(9,'test@test.com');
        testNumbers.put(10,null);
        noChangeNumbers.put(10,null);

        Test.startTest();
          for (Integer keyInt : testNumbers.keySet()) {
             String phoneResult = UtilityService.getE164FormattedPhoneNumber(testNumbers.get(keyInt),'1',10,'US');
             testNumbers.put(keyInt,phoneResult);
            
          }
        Test.stopTest();

        for (Integer keyInt : testNumbers.keySet()) {
          if (keyInt <= 4) {
            System.assertEquals('+17738947894',testNumbers.get(keyInt));
          } else if (keyInt == 5 || keyInt == 6) {
            System.assertEquals('+17738947894x1234',testNumbers.get(keyInt));
          } else {
            System.assertEquals(noChangeNumbers.get(keyInt),testNumbers.get(keyInt));
          }
        }

      
    }
    public static testMethod void Test_PhoneNumberUpdateINTL() {
        Map<Integer,String> testNumbers = new Map<Integer,String>();
        Map<Integer,String> noChangeNumbers = new Map<Integer,String>();
        testNumbers.put(1,'7738947894');
        testNumbers.put(2,'+917738947894');
        testNumbers.put(3,'07738947894');
        testNumbers.put(4,'773894789412');
        testNumbers.put(5,'+91773894789412');
         testNumbers.put(6,'+07738947894');
        testNumbers.put(7,null);
        noChangeNumbers.put(7,null);

        Test.startTest();
          for (Integer keyInt : testNumbers.keySet()) {
             String phoneResult = UtilityService.getE164FormattedPhoneNumber(testNumbers.get(keyInt),'91',10,'INTL');
             testNumbers.put(keyInt,phoneResult);
    
  }        Test.stopTest();

        for (Integer keyInt : testNumbers.keySet()) {
          if (keyInt < 4) {
            System.assertEquals('+917738947894',testNumbers.get(keyInt));
          } else if (keyInt == 5 || keyInt == 4) {
            System.assertEquals('+91773894789412',testNumbers.get(keyInt));
          }else if( keyInt == 6){
              System.assertEquals('+917738947894',testNumbers.get(2));
          } else {
            System.assertEquals(noChangeNumbers.get(keyInt),testNumbers.get(keyInt));
          }
        }

      
    }
  }