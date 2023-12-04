@isTest
public class ZTS_EU_UserUtility_Test{
    public static String uk ='United Kingdom';
    public static String ind ='India';
    public static String lndn ='London';
        
    public static testMethod void stateIdPopulateTest(){
        List<User> userList=new List<User>();
        List<State_Country__c> stateCountry =new List<State_Country__c>();
        
        State_Country__c testState1 = ZTS_EU_DataUtilityTest.createStateCountryRecordPara(lndn,uk);
        State_Country__c testState2 = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('Delhi',ind);
        State_Country__c testState3 = ZTS_EU_DataUtilityTest.createStateCountryRecordPara('Aberdeen',uk);
        stateCountry.add(testState1);
        stateCountry.add(testState2);
        stateCountry.add(testState3);
        insert stateCountry;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = ZTS_EU_DataUtilityTest.createUtilityUser(true,uk,lndn,uk);
        
        // Assertion for successful insert with correct data
        userList = [Select Name, ZTS_EU_State_County_Id__c from User where Id = : u.Id AND ZTS_EU_Market__c != 'United States'];
        system.assertEquals(testState1.Id,userList[0].ZTS_EU_State_County_Id__c);
        
        // Assertion for successful update with correct data
        u.state ='Aberdeen';
        try{
            update u;
        }catch(Exception e){
            system.debug('error :' +e.getMessage());
        }
        List<User> updatedSuccessList =[Select Name, ZTS_EU_State_County_Id__c from User where Id = : u.Id AND ZTS_EU_Market__c != 'United States'];
        system.assertEquals(testState3.Id,updatedSuccessList[0].ZTS_EU_State_County_Id__c);
        
        //Assertion for update failure due to wrong data
        u.Default_Country__c =ind;
        try{
            update u;
        }catch(Exception e){
            system.debug('error :' +e.getMessage());
        }
        
        List<User> updatedUserList =[Select Name, ZTS_EU_State_County_Id__c from User where Id = : u.Id AND ZTS_EU_Market__c != 'United States'];
        system.assertEquals(testState3.Id,updatedUserList[0].ZTS_EU_State_County_Id__c);
        
        test.startTest();
        UserTriggerHandler userHandler = new UserTriggerHandler();
	    DispatchTriggerHandler.setRecursionContexts(userHandler);
        //Code for insert failure due to incorrect data
        User u2 = ZTS_EU_DataUtilityTest.createUtilityUser(false,ind,lndn,ind);
        try{
            
            insert   u2;
            System.debug('$$$ after insert u2: '+u2);
        }catch(Exception e){
            system.debug('Error:-'+e.getMessage());
        }
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean isErrorMessage = false;
        for(Apexpages.Message msg : msgs){
            if (msg.getDetail().contains(System.Label.ZTS_EU_Invalid_State) )
                isErrorMessage  = true;
        }
        system.assert(isErrorMessage);

        
        test.stopTest();
  }
    public static testMethod void TotCreate(){
        
        //Code for insert holiday
         Holiday__c h2 = ZTS_EU_DataUtilityTest.createHoliday('Taiwan',true);
         
       try{
            insert   h2;
        }catch(Exception e){
            system.debug('Error:-'+e.getMessage());
        } 
        
        //positive testing
        Integer randomNumber = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail = 'user' + String.valueOf(randomNumber) + '@testorg.com';
        System.debug('Random number for e-mail/username generation: ' + String.valueOf(randomNumber));
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='South East Asia Business Administrator']; 
        User user = new User(Alias = 'standt', Email=uniqueEmail, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof.Id, IsActive=True,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueEmail,
        CurrencyIsoCode='EUR', ZTS_EU_Market__c = 'Taiwan');
        
        insert user;
        
         Map <Id,String> userMap = new Map <Id,String>();
         userMap.put(user.id, 'Taiwan');
        
         User u1 = ZTS_EU_DataUtilityTest.createUserWithProfileAndMarket('System Administrator', 'Taiwan');
       //  u1.ZTS_EU_Market__c = 'Taiwan';
         //insert u1;
        System.runAs(u1){
           ZTS_EU_UserUtility.createTotforHoliday(userMap);    
        }
        
      
        //negative testing
        
        Integer randomNumber1 = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail1 = 'user1' + String.valueOf(randomNumber1) + '@testorg.com';
        System.debug('Random number for e-mail/username generation: ' + String.valueOf(randomNumber1));
        
        Profile prof2 = [SELECT Id FROM Profile WHERE Name='Chatter Free User']; 
        User user1 = new User(Alias = 'standt1', Email=uniqueEmail1, 
        EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof2.Id, IsActive=True,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueEmail1,
        CurrencyIsoCode='EUR', ZTS_EU_Market__c = 'Taiwan');
        
        insert user1;
        
        
    } 
    
    

    public static testMethod void fetchTotRecords(){
         //positive testing
        Integer randomNumber = Math.abs(Crypto.getRandomInteger());
        String uniqueEmail = 'user' + String.valueOf(randomNumber) + '@testorg.com';
        System.debug('Random number for e-mail/username generation: ' + String.valueOf(randomNumber));
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='South East Asia Business Administrator']; 
        User user = new User(Alias = 'standt', Email=uniqueEmail, 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = prof.Id, IsActive=True,
        TimeZoneSidKey='America/Los_Angeles', Username=uniqueEmail,
        CurrencyIsoCode='EUR', ZTS_EU_Market__c = 'Taiwan');
        insert user; 
        List<User> userList = new List<User>();
        userList.add(user);
         Holiday__c h2 = ZTS_EU_DataUtilityTest.createHoliday('Taiwan',true);
         
       try{
            insert   h2;
        }catch(Exception e){
            system.debug('Error:-'+e.getMessage());
        }
         User u1 = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
         u1.ZTS_EU_Market__c = 'Taiwan';
         insert u1;
        System.runAs(u1){
         
         Time_Out_of_Territory__c tot = new Time_Out_of_Territory__c();
                    tot.ZTS_EU_Type__c = 'Time Off';
                    tot.ZTS_EU_Reason__c = 'NW - Company holiday';
                    tot.ZTS_EU_Start_Date__c = h2.ZTS_EU_Holiday_Date__c;
                    tot.ZTS_EU_End_Date__c = h2.ZTS_EU_Holiday_Date__c;
                    tot.ZTS_EU_Duration__c = 'Full Day = 9 AM - 5 PM';
                    tot.OwnerId = user.id;
                    tot.ZTS_Market__c = h2.ZTS_EU_Market__c;
                    tot.ZTS_EU_Status__c = 'Submitted';
                    tot.ZTS_EU_Description__c = h2.Name;

       insert tot;
             ZTS_EU_UserUtility.fetchUserTotRecords(userList);
        }


} 
    
}