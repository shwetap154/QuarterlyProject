/**
Class Name	    : SelectUserForAllMarketBenchmarkCntrl
Description	    : Controller Class created as part of TPDEV-158 for the SelectUserForAllMarketBenchmark LWC. 
Created By		: Sibin Kuriakose
Created Date	: 05-27-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-27-2023	 Created methods to Select applicable Users and return the values to JS in LWC
*/
public class SelectUserForAllMarketBenchmarkCntrl {
    
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> search(String searchTerm, String inpulValue) {
        // Prepare query parameters
        List<Id> userId = new List<Id>();
        userId.add(UserInfo.getUserId());
        String str = searchTerm+'%';
        String iCoachCoachee = inpulValue;
        Set<String> setPermission = new Set<String>();
        String pername = 'iDevelop_Coachee';
        String iCoachPerSetname = 'iCoach_Coachee';
        if(iCoachCoachee.equals(iCoachPerSetname)){
            setPermission.add(iCoachCoachee);
        }else{
            setPermission.add(pername);
        }     
        Integer intlimit = 10;
        List<User> results = UsersSelector.selectUserDetailByName(str, setPermission, intlimit);
        List<LookupSearchResult> result = new List<LookupSearchResult>();
        String userIcon = 'standard:user';
        for(User temp : results){
            String title = temp.Name;
            String subtitle = '';
            Boolean addMarkCheck = false;
            Boolean checker = false;
            if(temp.Email != null){
                subtitle +=  temp.Email+', ';
            }
            if(temp.Title != null){
                subtitle +=  temp.Title+', ';
            }
            if(temp.ZTS_EU_Market__c != null){
                subtitle +=  temp.ZTS_EU_Market__c;
            }
            if(userId.contains(temp.Id) == false){
               result.add(new LookupSearchResult(temp.Id, 'User', userIcon, title, subtitle)); 
            }
        }
        return result;
    }
}