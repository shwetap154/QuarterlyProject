/*
    @@ Puropose: Wrapper for records displayed on ZTS_MonthlyPlanning page. 
    @@ Author: Ilirjana Predojević
*/
public class AccountWrapper {
    public Account account { get; set; }
    public string accountOwner  { get; set; }
    public string numberOfDaysSinceLastCall { get; set; }
    public string nextCallOn { get; set; }
    public boolean hasCallInNext30Days { get; set; }
    string selectedRatingLabel;
    
    public AccountWrapper(Account acc, string selectedRatingLabel, string numberOfDaysSinceLastCall, string accountOwner, string nextCallOn){
        this.account = acc;
        this.selectedRatingLabel = selectedRatingLabel;
        this.numberOfDaysSinceLastCall = numberOfDaysSinceLastCall;
        this.accountOwner = accountOwner;
        
        this.nextCallOn = nextCallOn;
        if (nextCallOn == null || nextCallOn == '')
            hasCallInNext30Days = false;
        else
            hasCallInNext30Days = true;
    }
    
    //get potential value dependent of what is selected for rating
    public string getPotentialValue(){
        if (selectedRatingLabel == ZTS_EU_GlobalConstants.All)
            return string.valueOf(account.ZTS_EU_All_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADPre)
            return string.valueOf(account.ZTS_EU_CADPre_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADTher)
            return string.valueOf(account.ZTS_EU_CADTher_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CA)
            return string.valueOf(account.ZTS_EU_CA_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTBF)
            return string.valueOf(account.ZTS_EU_CTBF_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTDY)
            return string.valueOf(account.ZTS_EU_CTDY_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTFL)
            return string.valueOf(account.ZTS_EU_CTFL_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.EQ)
            return string.valueOf(account.ZTS_EU_EQ_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.PY)
            return string.valueOf(account.ZTS_EU_PY_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.RU)
            return string.valueOf(account.ZTS_EU_RU_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.SW)
            return string.valueOf(account.ZTS_EU_SW_Potential__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.VPS)
            return string.valueOf(account.ZTS_EU_VPS_Potential__c);
        
        return '';
    }
    
    //get potential value dependent of what is selected for rating
    public string getRatingFromSegment(){
        if (selectedRatingLabel == ZTS_EU_GlobalConstants.All)
            return string.valueOf(account.ZTS_EU_All_Rating__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADPre)
            return string.valueOf(account.ZTS_EU_RAT_CADPre__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CADTher)
            return string.valueOf(account.ZTS_EU_RAT_CADTher__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CA)
            return string.valueOf(account.ZTS_EU_RAT_CA__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTBF)
            return string.valueOf(account.ZTS_EU_RAT_CTBF__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTDY)
            return string.valueOf(account.ZTS_EU_RAT_CTDY__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.CTFL)
            return string.valueOf(account.ZTS_EU_RAT_CTFL__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.EQ)
            return string.valueOf(account.ZTS_EU_RAT_EQ__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.PY)
            return string.valueOf(account.ZTS_EU_RAT_PY__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.RU)
            return string.valueOf(account.ZTS_EU_RAT_RU__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.SW)
            return string.valueOf(account.ZTS_EU_RAT_SW__c);
        else if (selectedRatingLabel == ZTS_EU_GlobalConstants.VPS)
            return string.valueOf(account.ZTS_EU_RAT_VPS__c);
        
        return '';
    }
}