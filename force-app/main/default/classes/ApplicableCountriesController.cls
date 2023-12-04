public class ApplicableCountriesController {
    @AuraEnabled
    public static String getCountrySiteUrl()
    {
        String siteUrl = '';
        User userobj = [select id,Applicable_Countries__c from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States' limit 1];
        Map<String,Applicable_Countries_URL__c> allCodes = Applicable_Countries_URL__c.getAll();
        System.debug('userobj.Applicable_Countries__c==='+userobj.Applicable_Countries__c);
        if(!String.isBlank(userobj.Applicable_Countries__c))
        {
            List<String> lstAppCountries = userobj.Applicable_Countries__c.Split(';');
            System.debug('lstAppCountries==='+lstAppCountries);
            System.debug('allCodes.values()==='+allCodes.values());
            for(Applicable_Countries_URL__c appc : allCodes.values())
            {
                System.debug('appc.CountryCode__c==='+appc.CountryCode__c);
                if(appc.CountryCode__c == lstAppCountries[0])
                {
                    System.debug('appc.CountrySiteUrl__c==='+appc.CountrySiteUrl__c);
                    siteUrl = appc.CountrySiteUrl__c;
                }
            }
            if(String.IsBlank(siteUrl))
            {
                Applicable_Countries_URL__c appCountry= Applicable_Countries_URL__c.getValues('Nigeria');
                siteUrl = appCountry.CountrySiteUrl__c;
            }
        }
        return siteUrl;
    }
    @AuraEnabled
    public static String getLeanandGrowUrl()
    {
        String siteUrl = '';
        User userobj = [select id,Applicable_Countries__c from User where id =: UserInfo.getUserId() AND ZTS_EU_Market__c != 'United States' limit 1];
        Map<String,Learn_And_Grow__c> allCodes = Learn_And_Grow__c.getAll();
        System.debug('userobj.Applicable_Countries__c==='+userobj.Applicable_Countries__c);
        if(!String.isBlank(userobj.Applicable_Countries__c))
        {
            List<String> lstAppCountries = userobj.Applicable_Countries__c.Split(';');
            System.debug('lstAppCountries==='+lstAppCountries);
            System.debug('allCodes.values()==='+allCodes.values());
            for(Learn_And_Grow__c appc : allCodes.values())
            {
                System.debug('appc.CountryCode__c==='+appc.CountryCode__c);
                if(appc.CountryCode__c == lstAppCountries[0])
                {
                    System.debug('appc.CountrySiteUrl__c==='+appc.CountrySiteUrl__c);
                    siteUrl = appc.CountrySiteUrl__c;
                }
            }
            if(String.IsBlank(siteUrl))
            {
                Learn_And_Grow__c appCountry= Learn_And_Grow__c.getValues('Nigeria');
                siteUrl = appCountry.CountrySiteUrl__c;
            }
        }
        return siteUrl;
    }
    
}