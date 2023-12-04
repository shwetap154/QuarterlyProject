/**
* @ClassName    : SL_UserTriggerHandler_Test 
* @JIRATicket   : LIGHTNI-1736
* @CreatedOn    : 19th Nov 2019.
* @CreatedBy    : Akshay Agrawal
* @ModifiedBy   : Mohamed
* @ModifiedOn    : 8/27/2020
* @Description  : Test class for user trigger handler.
*/ 
@isTest
public class SL_UserTriggerHandler_Test 
{
    
    @isTest
    public static void testUserTriggerhandler() 
    {
        
        List<User> lstUsers = new List<User>();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        String markets = 'Albania;ALPHA;Argentina;Australia;Austria;Baltics;Belgium;Bolivia;Bosnia and Herzegovina;Brazil;Bulgaria;'+
            'Canada;CeLA;Central America;Chile;China;Colombia;Costa Rica;Croatia;Czech Republic;Dominican Republic;Ecuador;'+
            'Egypt;El Salvador;Ethiopia;Finland;France;Germany;Global BioDevices;Greece;Guatemala;Honduras;Hungary;India;Indonesia;'+
            'Ireland;Israel;Italy;Japan;Korea;Kosovo;Macedonia;Mexico;Middle East;Netherlands;New Zealand;Nicaragua;Nigeria;Norway;Maghreb;'+
            'Panama;Paraguay;Peru;Pharmaq;Philippines;Poland;Portugal;Romania;Russia;Serbia;Singapore;Slovakia;Slovenia;SoLA;'+
            'South Africa;Spain;Switzerland;Taiwan;Thailand;Turkey;Uganda;Ukraine;United Kingdom;Uruguay;Venezuela;Vietnam;Zoetis';
        for(Integer i=0; i<100; i++) {
            lstUsers.add(new User(ProfileId = profileId,
                                  LastName = 'last'+i,
                                  Email = 'puser000@amamama.com',
                                  Username = UserInfo.getOrganizationId() + System.now().millisecond() + i + '@testorg.com',
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'ali'+i,
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  ZTS_EU_Market__c = 'Brazil',
                                  Additional_Markets__c = markets,
                                  LocaleSidKey = 'en_US'));
        }
        Test.startTest();
        insert lstUsers;
        Test.stopTest();
        User usr = [SELECT Additional_Markets_Text_1__c, Additional_Markets_Text_2__c, Additional_Markets_Text_3__c 
                    FROM User
                    WHERE Id = :lstUsers[0].Id LIMIT 1];
        String marketVal = 	usr.Additional_Markets_Text_1__c + ' ' +
            usr.Additional_Markets_Text_2__c + ' ' +
            usr.Additional_Markets_Text_3__c;
        System.assertEquals(markets.length(), marketVal.length() );
        
        usr.Additional_Markets__c = markets.substring(0, 232);
        update usr;
        User user_extracted = [SELECT Additional_Markets_Text_1__c, Additional_Markets_Text_2__c, Additional_Markets_Text_3__c 
                    FROM User
                    WHERE Id = :usr.Id LIMIT 1];
        System.assertEquals(232, user_extracted.Additional_Markets_Text_1__c.length() );
        
        usr.Additional_Markets__c = markets.substring(0, 372);
        update usr;
    }
    
    @isTest
    public static void testUSUserTriggerhandler() 
    {
        
        List<User> lstUsers = new List<User>();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        String markets = 'Albania;ALPHA;Argentina;Australia;Austria;Baltics;Belgium;Bolivia;Bosnia and Herzegovina;Brazil;Bulgaria;'+
            'Canada;CeLA;Central America;Chile;China;Colombia;Costa Rica;Croatia;Czech Republic;Dominican Republic;Ecuador;'+
            'Egypt;El Salvador;Ethiopia;Finland;France;Germany;Global BioDevices;Greece;Guatemala;Honduras;Hungary;India;Indonesia;'+
            'Ireland;Israel;Italy;Japan;Korea;Kosovo;Macedonia;Mexico;Middle East;Netherlands;New Zealand;Nicaragua;Nigeria;Norway;Maghreb;'+
            'Panama;Paraguay;Peru;Pharmaq;Philippines;Poland;Portugal;Romania;Russia;Serbia;Singapore;Slovakia;Slovenia;SoLA;'+
            'South Africa;Spain;Switzerland;Taiwan;Thailand;Turkey;Uganda;Ukraine;United Kingdom;Uruguay;Venezuela;Vietnam;Zoetis';
        for(Integer i=0; i<100; i++) {
            lstUsers.add(new User(ProfileId = profileId,
                                  LastName = 'last'+i,
                                  Email = 'puser000@amamama.com',
                                  Username = UserInfo.getOrganizationId() + System.now().millisecond() + i + '@testorg.com',
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'ali'+i,
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  ZTS_EU_Market__c = 'United States',
                                  Additional_Markets__c = markets,
                                  LocaleSidKey = 'en_US'));
        }
        Test.startTest();
        insert lstUsers;
        Test.stopTest();
        User usr = [SELECT Additional_Markets_Text_1__c, Additional_Markets_Text_2__c, Additional_Markets_Text_3__c 
                    FROM User
                    WHERE Id = :lstUsers[0].Id LIMIT 1];
        String marketVal = 	usr.Additional_Markets_Text_1__c + ' ' +
            usr.Additional_Markets_Text_2__c + ' ' +
            usr.Additional_Markets_Text_3__c;
        System.assertEquals(markets.length(), marketVal.length() );
        
        usr.Additional_Markets__c = markets.substring(0, 232);
        update usr;
        User user_extracted = [SELECT Additional_Markets_Text_1__c, Additional_Markets_Text_2__c, Additional_Markets_Text_3__c 
                    FROM User
                    WHERE Id = :usr.Id LIMIT 1];
        System.assertEquals(232, user_extracted.Additional_Markets_Text_1__c.length() );
        
        usr.Additional_Markets__c = markets.substring(0, 372);
        update usr;

    }
    
    
    @isTest
    public static void testUSUserTriggerhandlerAfterUpdate() 
    {
        String profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        List<Role_2_Species_Mapping__mdt> roleToSpeciesList = new List<Role_2_Species_Mapping__mdt>();
        roleToSpeciesList = [Select Role__c,FieldForce__c From Role_2_Species_Mapping__mdt Where Market__c = 'United States'];
        Map<String,String> fieldForceToRoleMap = new Map<String,String>();
        for(Role_2_Species_Mapping__mdt r2s:roleToSpeciesList){
            fieldForceToRoleMap.put(r2s.FieldForce__c,r2s.Role__c);
        }
        
        List<UserRole> userRoleList = [SELECT Id,Name FROM UserRole WHERE Name In: fieldForceToRoleMap.values()];
        
        Map<String,Id> roleToIdMap = new Map<String,Id>();
        for(UserRole ur:userRoleList){
            roleToIdMap.put(ur.Name,ur.Id);
        }
        
        User u = new User(ProfileId = profileId,
                                  LastName = 'last',
                                  Email = 'puser000@amamama.com',
                                  Username = UserInfo.getOrganizationId() + System.now().millisecond() + '@testorg.com',
                                  CompanyName = 'TEST',
                                  Title = 'title',
                                  Alias = 'ali08087',
                                  UserRoleId = roleToIdMap.get(fieldForceToRoleMap.get('Equine')),
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  EmailEncodingKey = 'UTF-8',
                                  LanguageLocaleKey = 'en_US',
                                  ZTS_EU_Market__c = 'United States',
                                  LocaleSidKey = 'en_US');
        
        Test.startTest();
        insert u;
        
        System.runAs(u){
            List<String> recordTypes = new List<String>();
            for(RecordTypeInfo info: ZTS_Events__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if(info.isAvailable()) {
                    recordTypes.add(info.getName());
                }
            }
            System.assert(recordTypes.contains('Equine')); 
        }
        
        u.UserRoleId = roleToIdMap.get(fieldForceToRoleMap.get('Pork'));
        update u;
        
        u.UserRoleId = roleToIdMap.get(fieldForceToRoleMap.get('All'));
        update u;
        Test.stopTest();

    }
    
    static testMethod void Testpublicgroups(){
        
        List<User> newtestuserlist = new List<User>();
        List<User> testuserlist = new List<User>();
        User testUser =  ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser.FirstName = 'testUserFirstName';
        testUser.zts_eu_market__c = 'United States';
        testUser.Sharing_Business_Unit__c = 'Petcare';
        
        testuserlist.add(testUser);
        
        User testUser2 =  ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        testUser2.FirstName = 'testUserFirstName2';
        testUser2.zts_eu_market__c = 'United States';
        testUser2.Sharing_Business_Unit__c = 'Poultry';
        
       
        testuserlist.add(testUser2);
        
        insert testuserlist;
        
        testUser.Sharing_Business_Unit__c = 'Poultry';
        
        update testUser;
        
        newtestuserlist.add(testUser);
        
        SL_UserTriggerHandler handler = new SL_UserTriggerHandler();
        handler.addUser(testuserlist);
        handler.updateUser(testuserlist,newtestuserlist );
    }
}