@isTest(SeeAllData=False)
public class AccountWrapperTest {

    @TestSetup
    private static void createAccountRecord(){
        
        List<Account> testAccts = ZTS_DataUtilityTest.createAccountRecord(1);
        Account testacc=testAccts[0];
        testacc.Name = 'TestAccount';
        testacc.ZTS_EU_Market__c = 'United States';
        testacc.Practice_Management_Software__c = 'Animana';
        testacc.Other_Practice_Management_Software__c = ''; 
        testacc.ZTS_EU_All_Potential__c = 57193.1022;
        testacc.ZTS_EU_CADPre_Potential__c = 57193.1022;
        testacc.ZTS_EU_CADTher_Potential__c = 57193.1022;
        testacc.ZTS_EU_CA_Potential__c = 57193.1022;
        testacc.ZTS_EU_CTBF_Potential__c = 57193.1022;
        testacc.ZTS_EU_CTDY_Potential__c = 57193.1022;
        testacc.ZTS_EU_CTFL_Potential__c = 57193.1022;
        testacc.ZTS_EU_EQ_Potential__c = 57193.1022;
        testacc.ZTS_EU_PY_Potential__c = 57193.1022;
        testacc.ZTS_EU_RU_Potential__c = 57193.1022;
        testacc.ZTS_EU_SW_Potential__c = 57193.1022;
        testacc.ZTS_EU_VPS_Potential__c = 57193.1022;
        testacc.ZTS_EU_All_Rating__c = 'A1';
        testacc.ZTS_EU_RAT_CADPre__c = 'A1';
        testacc.ZTS_EU_RAT_CADTher__c = 'A1';
        testacc.ZTS_EU_RAT_CA__c  = 'A1';
        testacc.ZTS_EU_RAT_CTBF__c  = 'A1';
        testacc.ZTS_EU_RAT_CTDY__c  = 'A1';
        testacc.ZTS_EU_RAT_CTFL__c  = 'A1';
        testacc.ZTS_EU_RAT_EQ__c  = 'A1';
        testacc.ZTS_EU_RAT_PY__c  = 'A1';
        testacc.ZTS_EU_RAT_RU__c  = 'A1';
        testacc.ZTS_EU_RAT_SW__c  = 'A1';
        testacc.ZTS_EU_RAT_VPS__c  = 'A1';
        Insert testacc;
    }

    static testMethod void accountWrapperTest1() {
        
        List<Account> testAccounts = [SELECT Id, Name FROM Account];
        
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel;
        
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(true, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is blank');
        System.assertEquals(true, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is blank');
    } 
    
    static testMethod void accountWrapperTest2() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_All_Rating__c, ZTS_EU_All_Potential__c FROM Account];
        
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel2='All';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel2,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_All_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest3() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CADPre_Potential__c, ZTS_EU_RAT_CADPre__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel3='CAD Pre';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel3,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CADPre_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest4() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CADTher_Potential__c, ZTS_EU_RAT_CADTher__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel4='CAD Ther';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel4,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CADTher_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest5() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CA_Potential__c, ZTS_EU_RAT_CA__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel5='CA';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel5,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CA_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest6() {
        
        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CTBF_Potential__c, ZTS_EU_RAT_CTBF__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel6='CTBF';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel6,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CTBF_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest7() {
        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CTDY_Potential__c, ZTS_EU_RAT_CTDY__c FROM Account];
        
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel7='CTDY';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel7,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CTDY_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest8() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_CTFL_Potential__c, ZTS_EU_RAT_CTFL__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel8='CTFL';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel8,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_CTFL_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest9() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_EQ_Potential__c, ZTS_EU_RAT_EQ__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel9='EQ';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel9,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_EQ_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest10() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_PY_Potential__c, ZTS_EU_RAT_PY__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel10='PY';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel10,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_PY_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest11() {

        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_RU_Potential__c, ZTS_EU_RAT_RU__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel11='RU';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel11,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_RU_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest12() {
        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_SW_Potential__c, ZTS_EU_RAT_SW__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel12='SW';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel12,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_SW_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
    
    static testMethod void accountWrapperTest13() {
        
        List<Account> testAccounts = [SELECT Id, Name, ZTS_EU_VPS_Potential__c, ZTS_EU_RAT_VPS__c FROM Account];
        String accowner;
        String noOfDaysSinceLastCall;
        String nextCall;
        String selectedRatingLabel13='VPS';
    
        AccountWrapper ref = new AccountWrapper(testAccounts[0],selectedRatingLabel13,noOfDaysSinceLastCall,accowner,nextCall);
        String potentialValue = ref.getPotentialValue();
        String ratingFromSegment = ref.getRatingFromSegment();

        System.assertEquals(false, String.isEmpty(potentialValue), 'The expected value from getPotentialValue() is NOT blank');
        System.assertEquals(String.valueOf(testAccounts[0].ZTS_EU_VPS_Potential__c), potentialValue, 'The expected value is 57193.10220');
        System.assertEquals(false, String.isEmpty(ratingFromSegment), 'The expected value from getRatingFromSegment() is NOT blank');
        System.assertEquals('A1', ratingFromSegment, 'The expected value is A1');
    } 
}