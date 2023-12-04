//Ilirjana Predojević 3-Feb-15
//Test class for testing MonthlyPlanning functionality
@isTest(seeAlldata=false)
public class ZTS_MonthlyPlanning_Test {
    
    @isTest
    static void ZTS_MonthlyPlanning_Unit_test(){
        
        string result;
        string TimeZoneVal= '+5:30';
        dateTime testDate = system.now()+3;
        string activityDate = testDate.month()+'/'+testDate.day()+'/'+testDate.year()+' '+testDate.hour()+':'+testDate.minute()+' PM';
        AbstractCalendar.generateDate(activityDate);
        
        pageReference pf = page.ZTS_MonthlyPlanning;
        Test.setCurrentPageReference(pf);
        ZTS_MonthlyPlanning mp = new ZTS_MonthlyPlanning();
        
        //Test displayed values
        system.assertNotEquals(mp.getRatingLabels(), null);
        system.assertNotEquals(mp.getAccTypes(), null);
        system.assertNotEquals(mp.getNextCallValues(), null);
        system.assertEquals(mp.getDisplayedCity(), null);
        system.assertNotEquals(mp.getDisplayRatingAndPotential(), null);
        system.assertNotEquals(mp.getDisplayNextCall(), null);
        system.assertNotEquals(mp.getFooterNumberOfAccounts(), null);
        system.assertNotEquals(mp.getLstHolidays(), null);
        
        //Test table navigation
        mp.hasNext = true;
        mp.hasPrevious = true;
        if (mp.hasNext)
            mp.next();
        if (mp.hasPrevious)
            mp.previous();
        
        mp.next();
        mp.previous();
        mp.last();
        mp.first();
        
        //Test filtering
        mp.selectedState = 'Test State';
        system.assertNotEquals(mp.getStates(), null);
        system.assertNotEquals(mp.getStates().size(), 0);
        system.assertNotEquals(mp.getListOfAccounts(), null);
        system.assertNotEquals(mp.getLstSetController(), null);
        
        mp.selectedCity = 'Test City';
        mp.selectedAccType = 'Farm';
        mp.selectedNextCall = ZTS_EU_GlobalConstants.YES;
        
        system.assertNotEquals(mp.getListOfAccounts(), null);
        
        mp.selectedNextCall = ZTS_EU_GlobalConstants.NO;
        system.assertNotEquals(mp.getListOfAccounts(), null);
        
        mp.reRenderTable();
        mp.clearFilters();
    }
    
    @isTest
    static void testRating(){
        
        ZTS_MonthlyPlanning mp = new ZTS_MonthlyPlanning();
        mp.selectedRatingValue = 'Test rating';
        
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.All;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CADPre;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CADTher;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CA;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CTBF;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CTDY;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.CTFL;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.EQ;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.PY;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.RU;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.SW;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        mp.selectedRatingLabel = ZTS_EU_GlobalConstants.VPS;
        system.assertNotEquals(mp.getRatingValues().size(),0);
        mp.getListOfAccounts();
        
        mp.AccountName = 'Test';
        mp.executeSearch();
        ZTS_MonthlyPlanning.stringToDateTime('04/28/2018 05:23 PM');
    }    
    
    @isTest
    static void testPosCallUpdate(){
        Id callId = SL_IdGenerator.generateMockIdForObjectType(Call__c.SObjectType);
        string TimeZoneVal= '+5:30';
        string activityDate = '10/23/2018 08:00 PM';
        string result = ZTS_MonthlyPlanning.updateCall('/'+callId,activityDate,TimeZoneVal);
        system.assertNotEquals(result, null);
    }   
    
    @isTest
    static void testNegCallUpdate(){
        string TimeZoneVal= '+5:30';
        string activityDate = '10/23/2018 08:00 PM';
        string result = ZTS_MonthlyPlanning.updateCall('/',activityDate,TimeZoneVal);
        system.assert(result.contains('Exception'));
    }
    
    @isTest
    static void testPosCallSave(){
        Id accountId = SL_IdGenerator.generateMockIdForObjectType(Account.SObjectType);
        string TimeZoneVal= '+5:30';
        string activityDate = '10/23/2018 08:00 PM';
        string result = ZTS_MonthlyPlanning.saveCall(accountId, activityDate,TimeZoneVal);
        system.assertNotEquals(result, null);
    }   
    
    @isTest
    static void testNegCallSave(){
        string TimeZoneVal= '+5:30';
        string activityDate = '10/23/2018 08:00 PM';
        string result = ZTS_MonthlyPlanning.saveCall('',activityDate,TimeZoneVal);
        system.assert(result.contains('Exception'));
    }
}