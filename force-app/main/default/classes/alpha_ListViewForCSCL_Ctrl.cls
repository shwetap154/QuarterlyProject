public with sharing class alpha_ListViewForCSCL_Ctrl {
 @AuraEnabled //get Account Industry Picklist Values
    public static Map<String, String> getIndustry(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            if(p.getValue() != 'Activated')
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
@AuraEnabled (cacheable=true)//get Account Industry Picklist Values
    public static Map<string, string> getMonth(){
        Map<string, string> options = new Map<string, string>();
        //get Account Industry Field Describe
        //Schema.DescribeFieldResult fieldResult = Account.Industry.getDescribe();
        //get Account Industry Picklist Values
        //List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        string str='';
        for (integer i = 1; i<13;i++) {
            //Put Picklist Value & Label in Map
            if(i==1){
                str = 'January';
            }
            if(i==2){
                str = 'February';
            }

            if(i==3){
                str = 'March';
            }

            if(i==4){
                str = 'April';
            }

            if(i==5){
                str = 'May';
            }

            if(i==6){
                str = 'June';
            }

            if(i==7){
                str = 'July';
            }

            if(i==8){
                str = 'August';
            }
            if(i==9){
                str = 'September';
            }
            if(i==10){
                str = 'October';
            }
            if(i==11){
                str = 'November';
            }
            if(i==12){
                str = 'December';
            }

            options.put(string.valueof(i), str);
        }
        return options;
    } 
    
    @AuraEnabled(cacheable=true) //get Account Industry Picklist Values
    public static Map<string, string> getYear(){
        Map<string, string> options = new Map<string, string>();
        //get Account Industry Field Describe
        //Schema.DescribeFieldResult fieldResult = Account.Industry.getDescribe();
        //get Account Industry Picklist Values
        //List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (integer i = 2020; i<2035;i++) {
            //Put Picklist Value & Label in Map
            options.put(string.valueof(i), string.valueof(i));
        }
        return options;
    } 
    
    
    @AuraEnabled(cacheable=true)
    public static List < Order > filterOrds(string mnth,string yr,string selectRecordId,string picklst) {
        system.debug(String.isNotblank(mnth));
        //Account acc = (Account)accountList[0];
        
        List<sobject> accountList = UtilityController.returnObjList();
       
        system.debug(String.isNotblank(yr));
        system.debug(mnth);
        system.debug(yr);
        Date dt = System.today(); //current date
        Integer day = dt.Day(); //get day
        Integer month = dt.Month(); //get month
        Integer year = dt.Year(); //get year
        string soql = '';
       // soql += 'SELECT Id,AccountId, OrderNumber,status,owner.Name,alpha_Attachments_yes_no__c,EffectiveDate FROM Order  where Created_Month__c=:mnth  ';
       
        system.debug(selectRecordId);
      soql += 'Select OrderReferenceNumber ,createdby.name,Id,PoDate,OrderNumber,PoNumber,Account_Name__c ,status,owner.Name,alpha_Attachments_yes_no__c,EffectiveDate from order where Created_Month__c=:mnth and Created_Year__c=:yr   ';
        if(selectRecordId != null && selectRecordId !=''){
            soql += ' and accountid=: selectRecordId ';
        }
        system.debug('picklst'+picklst);
        if(picklst != null && picklst !=''){
            soql += ' and status=: picklst ';
        }
        soql += ' order  by createddate DESC';
        system.debug(soql);
        List<Order> objectList = Database.query(soql);
        system.debug(objectList);
        return objectList;
    }
    
    
    
     @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        system.debug(ObjectName);
        system.debug(fieldName);
        system.debug(value);
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE  '+fieldName+' LIKE \'%' + value + '%\' LIMIT 15')) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
    

    @AuraEnabled (cacheable=true)
    public static String getbaseURL(){
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return (baseUrl);
    }

}