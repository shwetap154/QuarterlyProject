public with sharing class ZTS_EU_OrderCapturePerformanceController {

    public String market;
    public String Year {get;set;}
    public String userCurrency {get;set;}
    public Double conversionRate {get;set;}

    public class Period {
        public final String name {get;set;}
        public final Date startDate {get;set;}
        public final Date endDate {get;set;}

        public Period(String name, Date startDate, Date endDate) {
            this.name = name;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }

    public class Performance {
        public Period period {get;set;}
        public Decimal target {get;set;}
        public Decimal orderValue {get;set;}
        public Decimal value {get;set;}

        public Performance(Period p) {
            period = p;
            target = 0;
            orderValue = 0;
            value = 0;
        }
    }

    public class UserCapturePerformance implements Comparable{
        public final User user {get;set;}
        public final Map<String, Performance> performance {get;set;}
        public UserCapturePerformance(User u) {
            user = u;
            performance = new Map<String, Performance>();
        }

        public Integer compareTo(Object o) {
            UserCapturePerformance to = (UserCapturePerformance)o;

            return user.Name.compareTo(to.user.Name);
        }
    }

    public class CapturePerformanceException extends Exception {}
    
    public ZTS_EU_OrderCapturePerformanceController() {
        String id = UserInfo.getUserId();
        User u = [select ZTS_EU_Market__c from User where Id = :id AND ZTS_EU_Market__c != 'United States'];
        market = u.ZTS_EU_Market__c;
        if (Year == null) {     
            Date t = Date.today();
            List<ZTS_EU_Accounting_Period__c> ytdtmp = [select ZTS_EU_Fiscal_Year__c from ZTS_EU_Accounting_Period__c where ZTS_EU_AP_Start__c <= :t and ZTS_EU_AP_End__c >= :t and ZTS_EU_Market__c = :market];
            if(ytdtmp.size()>0){
            	Year = ytdtmp.get(0).ZTS_EU_Fiscal_Year__c;    
            }

        }
        
        userCurrency = UserInfo.getDefaultCurrency();
        conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode=:userCurrency LIMIT 1].conversionRate;
    }

    private Map<String, Period> getFiscalPeriods(String year) {
        Map<String, ZTS_EU_Accounting_Period__c> periods = new Map<String, ZTS_EU_Accounting_Period__c>();
        for (ZTS_EU_Accounting_Period__c p :    [select ZTS_EU_Fiscal_Year__c, ZTS_EU_Account_Period__c, ZTS_EU_AP_Start__c, ZTS_EU_AP_End__c from ZTS_EU_Accounting_Period__c 
                                                where ZTS_EU_Fiscal_Year__c = :year and ZTS_EU_Market__c = :market]) {
            periods.put(p.ZTS_EU_Account_Period__c, p);
        }
        System.debug('$$$ periods.size()  '+periods.size());
        if (periods.size()!=12) {
            throw new CapturePerformanceException('Number of accounting periods must be 12! Please check accouting period configuration.');
        }
        Map<String, Period> result = new Map<String, Period>();
        result.put('01', new Period('01', periods.get('01').ZTS_EU_AP_Start__c, periods.get('03').ZTS_EU_AP_End__c));
        result.put('02', new Period('02', periods.get('04').ZTS_EU_AP_Start__c, periods.get('06').ZTS_EU_AP_End__c));
        result.put('03', new Period('03', periods.get('07').ZTS_EU_AP_Start__c, periods.get('09').ZTS_EU_AP_End__c));
        result.put('04', new Period('04', periods.get('10').ZTS_EU_AP_Start__c, periods.get('12').ZTS_EU_AP_End__c));

        return result;
    }

    private UserCapturePerformance initUserCapturePerformance(User u, Map<String, Period> periods) {
        UserCapturePerformance ucp = new UserCapturePerformance(u);
        for (String p : periods.keySet()) {
            ucp.performance.put(p, new Performance(periods.get(p)));
        }
        ucp.performance.put('FY', new Performance(new Period('FY', periods.get('01').startDate, periods.get('04').endDate)));
        return ucp;
    }

    public List<UserCapturePerformance> getCapturePerformance() {
      
        Map<String, Period> periods = getFiscalPeriods(Year);
        Map<String, UserCapturePerformance> ucps = new Map<String, UserCapturePerformance>();
        
        List<User> userTgts = [Select u.Id, u.ZTS_EU_Market__c, u.Name, u.IsActive, 
                                (Select ZTS_EU_Period__c, CurrencyIsoCode, ZTS_EU_Sales_Target__c From User_Targets__r 
                                    where ZTS_EU_Year__c = :Year and ZTS_EU_Period_Type__c = 'Fiscal' and ZTS_EU_Period_Length__c = 'Quarter') 
                                From User u 
                                where u.IsActive = true and u.ZTS_EU_Market__c = :market];

        for (User u : userTgts) {
            UserCapturePerformance ucp = initUserCapturePerformance(u, periods);
            Decimal fytarget = 0;
            for (ZTS_EU_User_Target__c tgt : u.User_Targets__r) {
                ucp.performance.get(tgt.ZTS_EU_Period__c).target = tgt.ZTS_EU_Sales_Target__c;
                fytarget = fytarget + tgt.ZTS_EU_Sales_Target__c;
            }
            ucp.performance.get('FY').target = fytarget;
            ucps.put(u.Id, ucp);
        }

        List<Date> startDates = new List<Date>();
        List<Date> endDates = new List<Date>();

        for(Period p : periods.values()){
            startDates.add(p.startDate);
            endDates.add(p.endDate);
        }

        AggregateResult[] pvalues = [select CreatedBy.Id, sum(Total__c) total 
                                        from Orders__c 
                                        where ZTS_EU_Account__r.ZTS_EU_Market__c=:market 
                                        and ZTS_EU_Fulfillment_Date__c >= :startDates and ZTS_EU_Fulfillment_Date__c <= :endDates
                                        and RecordType.Name = 'Order' and ZTS_EU_Status__c in ('Completed', 'Sent')
                                        group by CreatedBy.Id];


        for (Period p : periods.values()) {
            for (AggregateResult pval : pvalues) {
                UserCapturePerformance ucp = ucps.get((String)pval.get('Id'));
                Performance fqp = ucp.performance.get(p.name);
                Performance fyp = ucp.performance.get('FY');

                fqp.orderValue = (Decimal)pval.get('total') * conversionrate;
                fyp.orderValue = fyp.orderValue + fqp.orderValue;
                if (fqp.orderValue != 0 && fqp.target != 0)
                    fqp.value = (fqp.orderValue / fqp.target) * 100;
                if (fyp.orderValue != 0 && fyp.target != 0)
                    fyp.value = (fyp.orderValue / fyp.target) * 100;
            }
        }

        List<UserCapturePerformance> result = ucps.values();
        result.sort();
        return result;
    
}
}