@isTest
public class PIT_Coaching_GuideTriggerHandler_test {
    
     static testmethod void createGuideINTL()
    {
        User coach = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        coach.ZTS_EU_Market__c = 'United Kingdom';
        coach.Default_Country__c ='United Kingdom';
        insert coach;
        User colleague = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        colleague.ZTS_EU_Market__c = 'United Kingdom';
        colleague.Default_Country__c ='United Kingdom';
        insert colleague;
        
        List<PIT_Coaching_Guide__c> lstCg = new List<PIT_Coaching_Guide__c>();
            PIT_Coaching_Guide__c cg1 = new PIT_Coaching_Guide__c();
            cg1.PIT_Coach__c = coach.Id;
            cg1.PIT_Colleague__c = colleague.Id;
            cg1.ZTS_EU_Market__c = 'United Kingdom';
            cg1.PIT_Coaching_Status__c ='Completed';
        
            PIT_Coaching_Guide__c cg2 = new PIT_Coaching_Guide__c();    
            cg2.PIT_Coach__c = coach.Id;
            cg2.PIT_Colleague__c = colleague.Id;
            cg2.ZTS_EU_Market__c = 'United Kingdom';
            cg2.PIT_Coaching_Status__c ='Completed';
        lstCg.add(cg1);
        lstCg.add(cg2);

        insert lstCg;
        
        PIT_Coaching_Guide__c cgINT1 = new PIT_Coaching_Guide__c();
        cgINT1.PIT_Coach__c = coach.Id;
        cgINT1.PIT_Coaching_Status__c = 'Pending Colleague Comments';
        cgINT1.PIT_Colleague__c = colleague.Id;
        cgINT1.ZTS_EU_Market__c = 'United Kingdom';
        cgINT1.PIT_Copy_Comments__c = false;
        insert cgINT1;
        system.debug('INT:After insert'+cgINT1);
        
        cgINT1.PIT_Coaching_Status__c = 'Completed';
        cgINT1.PIT_Copy_Comments__c = true;
        update cgINT1;
        system.debug('INT:After 1st update'+cgINT1);
    }
    
    static testmethod void createGuideINTL2()
    {
        
        User coach = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        coach.ZTS_EU_Market__c = 'United Kingdom';
        coach.Default_Country__c ='United Kingdom';
        insert coach;
        User colleague = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        colleague.ZTS_EU_Market__c = 'United Kingdom';
        colleague.Default_Country__c ='United Kingdom';
        insert colleague;
        
        PIT_Coaching_Guide__c cgINT2 = new PIT_Coaching_Guide__c();
        cgINT2.PIT_Coach__c = coach.Id;
        cgINT2.PIT_Coaching_Status__c = 'New';
        cgINT2.PIT_Colleague__c = colleague.Id;
        cgINT2.ZTS_EU_Market__c = 'United Kingdom';
        cgINT2.PIT_Copy_Comments__c = false;
        insert cgINT2;
        system.debug('INT:After insert'+cgINT2);
        
        cgINT2.PIT_Coaching_Status__c = 'Pending Colleague Comments';
        cgINT2.PIT_Copy_Comments__c = true;
        update cgINT2;
        system.debug('INT:After 1st update'+cgINT2);
        
    }
    
    
    
    static testmethod void createGuideUS()
    {  
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
        usr.ZTS_EU_Market__c = 'United Kingdom';
        insert usr; 
        
        System.runAs(usr){
        User coach = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        coach.ZTS_EU_Market__c = 'United States';
        coach.Default_Country__c ='United States';
        insert coach;
        User colleague = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        colleague.ZTS_EU_Market__c = 'United States';
        colleague.Default_Country__c ='United States';
        insert colleague;
        
        List<PIT_Coaching_Guide__c> lstCg = new List<PIT_Coaching_Guide__c>();
            PIT_Coaching_Guide__c cg1 = new PIT_Coaching_Guide__c();
            cg1.PIT_Coach__c = coach.Id;
            cg1.PIT_Colleague__c = colleague.Id;
            cg1.ZTS_EU_Market__c = 'United States';
            cg1.PIT_Coaching_Status__c ='Completed';
        
            PIT_Coaching_Guide__c cg2 = new PIT_Coaching_Guide__c();    
            cg2.PIT_Coach__c = coach.Id;
            cg2.PIT_Colleague__c = colleague.Id;
            cg2.ZTS_EU_Market__c = 'United States';
            cg2.PIT_Coaching_Status__c ='Completed';
        lstCg.add(cg1);
        lstCg.add(cg2);
        
        insert lstCg;
        
        PIT_Coaching_Guide__c cgUS1 = new PIT_Coaching_Guide__c();
        cgUS1.PIT_Coach__c = coach.Id;
        cgUS1.PIT_Coaching_Status__c = 'Pending Colleague Comments';
        cgUS1.PIT_Colleague__c = colleague.Id;
        cgUS1.ZTS_EU_Market__c = 'United States';
        cgUS1.PIT_Copy_Comments__c = false;
        insert cgUS1;
        system.debug('After insert'+cgUS1);
        
        cgUS1.PIT_Coaching_Status__c = 'Completed';
        cgUS1.PIT_Copy_Comments__c = true;
       update cgUS1;
        system.debug('After 1st update'+cgUS1);
        }       
    }
    
    static testmethod void createGuideUS2()
    {
                 Id adminProfileId = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1].Id; 
        
        User usr = CPQ_TestDataFactory.createUser(
            'TestUser',
            'Create',
            'Cory.bartholomew4@atginfo.com',
            'cory.bartholomew4@atginfo.com.testing',
            'testUser1',
            'clfctest',
            adminProfileId,
            null,
            false
        );
        usr.ZTS_EU_Market__c = 'United Kingdom';
        insert usr; 
        
        System.runAs(usr){
        
        User coach = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        coach.ZTS_EU_Market__c = 'United States';
        coach.Default_Country__c ='United States';
        insert coach;
        User colleague = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator',false);
        colleague.ZTS_EU_Market__c = 'United States';
        colleague.Default_Country__c ='United States';
        insert colleague;
        
        PIT_Coaching_Guide__c cgUS2 = new PIT_Coaching_Guide__c();
        cgUS2.PIT_Coach__c = coach.Id;
        cgUS2.PIT_Coaching_Status__c = 'New';
        cgUS2.PIT_Colleague__c = colleague.Id;
        cgUS2.ZTS_EU_Market__c = 'United States';
        cgUS2.PIT_Copy_Comments__c = false;
        insert cgUS2;
        system.debug('After insert'+cgUS2);
        
        cgUS2.PIT_Coaching_Status__c = 'Pending Colleague Comments';
        cgUS2.PIT_Copy_Comments__c = true;
       update cgUS2;
        system.debug('After 1st update'+cgUS2);
        }
    }
    
    static testMethod void deleteGuide(){

        PIT_Coaching_Guide__c cgInt = new PIT_Coaching_Guide__c();
        cgInt.PIT_Coach__c = Userinfo.getUserId();
        cgInt.PIT_Coaching_Status__c = 'New';
        cgInt.PIT_Colleague__c = Userinfo.getUserId();
        cgInt.PIT_Colleague_Comments__c = 'comments123';
        cgInt.ZTS_EU_Market__c = 'United Kingdom';
        insert cgInt;
        delete cgInt;


        PIT_Coaching_Guide__c cgUS = new PIT_Coaching_Guide__c();
        cgUS.PIT_Coach__c = Userinfo.getUserId();
        cgUS.PIT_Coaching_Status__c = 'New';
        cgUS.PIT_Colleague__c = Userinfo.getUserId();
        cgUS.PIT_Colleague_Comments__c = 'comments123';
        cgUS.ZTS_EU_Market__c = 'United States';
        insert cgUS;
        delete cgUS;

    }
}