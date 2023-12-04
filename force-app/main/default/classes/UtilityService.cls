/*************************************************************************************************************************
  Class Name     : UtilityService
  Description    : This is an utility class to provide common services.
  Created By     : Deloitte Consulting/Fayas Mansoor
  Created On     : 01/16/2014
                                                           
  Modification Log    :
   -----------------------------------------------------------------------------------------------------------------------
  Developer                             Date                    Description
  ---------                             ----                    -----------
  Deloitte Constulting/Fayas Mansoor    01/16/2014              Created
  Sathiya SB							02/14/2023 				Modified getE164FormattedPhoneNumber() method for INTL phone number formatting
***************************************************************************************************************************/

public class UtilityService {

    public static boolean kolRun = true;
    public static boolean papRun = true;
    public static boolean cTerritoryRun = true;
    public static boolean stopUpdateTSFonAccount=false;
    public static boolean stopUpdateZip=false;
    public static boolean accountTriggerRun = true;
    public static boolean addressTriggerRun = true;
    public static boolean contactTriggerRun = true;
    public static boolean reverseDelAffRun = true;    
    public static boolean reverseInsAffRun = true;
    public static boolean reverseUpdAffRun = true;
    public static boolean befAffInsertRun = true;
    public static boolean befAffUpdateRun = true;            
    public static boolean AffInsertRun = true;        
    public static boolean AffUpdateRun = true;
    public static boolean AffDeleteRun = true;
    public static boolean AccAffInsertRun = true;        
    public static boolean accountAffRun = true; 
    public static boolean updateBuyingGroup= true;  
    public static boolean vetSaveRun    = true;    
    
    public static string getRecordTypeName(string sObjectName, string recordTypeId){
        map<Id,Schema.RecordTypeInfo> recordTypeId_InfoMap = getRecordtypeInfosbyId(sObjectName);
        string recordTypeName = '';
        if(recordTypeId_InfoMap.containsKey(recordTypeId)){
            recordTypeName = recordTypeId_InfoMap.get(recordTypeId).getName();
        }
        return recordTypeName;
    }
    
    public static map<Id,Schema.RecordTypeInfo> getRecordtypeInfosbyId(string sObjectName){
        map<Id,Schema.RecordTypeInfo> recordTypeId_InfoMap = schema.getGlobalDescribe().get(sObjectName).getdescribe().getRecordTypeInfosById();
        return recordTypeId_InfoMap;
    }
    
    public static map<string,Schema.RecordTypeInfo> getRecordtypeInfosbyName(string sObjectName){
        map<string,Schema.RecordTypeInfo> recordTypeName_InfoMap = schema.getGlobalDescribe().get(sObjectName).getdescribe().getRecordTypeInfosByDeveloperName();
        return recordTypeName_InfoMap;
    }
    
    public static boolean isupdateBuyingGroupRun() {
        return updateBuyingGroup;
    }
    public static void setupdateBuyingGroup(){
        updateBuyingGroup= false;
    }
    public static boolean isaccountAffRun() {
        return accountAffRun;
    }
    public static void setaccountAffRun(){
        accountAffRun = false;
    }
    public static boolean iskolRun() {
        return kolRun;
    }
    public static void setkolRunFalse(){
        kolRun = false;
    }
    public static boolean isaccountTriggerRun() {
        return accountTriggerRun;
    }
    public static void setAccountTriggerRunFalse(){
        accountTriggerRun = false;
    }
    public static boolean iscontactTriggerRun() {
        return contactTriggerRun;
    }
    public static void setContactTriggerRunFalse(){
        contactTriggerRun = false;
    }
    public static boolean ispapRun() {
        return papRun;
    }
    public static void setpapRunFalse(){
        papRun = false;
    }
    public static boolean iscTerritoryRun() {
        return cTerritoryRun;
    }
    public static void setcTerritoryRun(){
        cTerritoryRun = false;
    }
    public static boolean isZipUpdateRun() {
        return cTerritoryRun;
    }
    public static void setisZipUpdateRun(){
        cTerritoryRun = false;
    }
    
     public static boolean isrevdelAffRun() {
        return reverseDelAffRun ;
    }
     public static boolean isrevinsAffRun() {
        return reverseInsAffRun ;
    }
     public static boolean isrevupdAffRun() {
        return reverseUpdAffRun ;
    }
    public static boolean isAffInsertRun() {
        return AffInsertRun ;
    }
        public static boolean isAffUpdateRun() {
        return AffUpdateRun ;
    }
    public static boolean isAffbefInsertRun() {
        return befAffInsertRun ;
    }
        public static boolean isAffbefUpdateRun() {
        return befAffUpdateRun ;
    }
        public static boolean isAffDeleteRun() {
        return AffDeleteRun ;
    }
    public static boolean isAccAffinsUpdateRun() {
        return AccAffInsertRun ;
    }
    public static boolean isAddressTriggerRun() {
        return addressTriggerRun;
    }
    public static void setAddressTriggerRunFalse(){
        addressTriggerRun = false;
    }
     public static boolean isVetsaveRun() {
        return vetSaveRun;
    }
    public static void setVetSaveRunFalse(){
        vetSaveRun = false;
    }
    //Get recordtype id based on object name and record type.
    
    public static ID recordTypeId(String objectName, String recordTypeName) {  
       
     Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);  
     // check the sObject is available in the system   
     if (sObj != null) {  
       Schema.DescribeSObjectResult sObjReslt = sObj.getDescribe();  
       // check the sObject result is not null  
       if (sObjReslt != null) {  
         Map<String,Schema.recordTypeInfo> mapRecordsType = new Map<String,Schema.recordTypeInfo>();  
         mapRecordsType = sObjReslt.getRecordTypeInfosByDeveloperName();  
           
         // pass the recordtype  
         return mapRecordsType.get(recordTypeName).getRecordTypeId();  
       }  
     }  
     return null;  
   }  

   public static String getE164FormattedPhoneNumber(String thisPhone, String countryCode,Integer numDigitsInNumber, String market) {
        String nondigits = '[^0-9]';
        system.debug('countrycode' +countrycode );
        system.debug( 'digitinNum' +numDigitsInNumber);
    
        if (thisPhone == null) {
            return thisPhone;
        }
        String phoneDigits;
        String extraDigits;
    
        // remove all non numeric
        phoneDigits = thisPhone.replaceAll(nondigits,'');
        system.debug('key ' + thisPhone + ' phoneDigits: ' + phoneDigits);
       if (market == 'US' && (phoneDigits.length() < numDigitsInNumber || phoneDigits.subString(0,1) == '0')) {
            system.debug('key ' + thisPhone + ' less than goal number or starts with 0');
            return thisPhone;
       }
       /*else if(market == 'INTL' && phoneDigits.subString(0,1) == '0'){
            system.debug('key ' + thisPhone + ' less than goal number');
             phoneDigits = '+' + countryCode + phoneDigits.replaceFirst('^0+', '') ;
       }*/
        else if(market == 'INTL' && String.isNotBlank(phoneDigits) && phoneDigits.subString(0,1) == '0'){
            system.debug('key ' + thisPhone + ' less than goal number');
             phoneDigits = '+' + countryCode + phoneDigits.removeStart('0') ;
       }
        else if (phoneDigits.length() == numDigitsInNumber) {
            system.debug('key ' + thisPhone + ' equals goal number');
            phoneDigits = '+' + countryCode + phoneDigits;
        } else if (phoneDigits.length() > numDigitsInNumber && market == 'US') { 
            system.debug('key ' + thisPhone + ' greater than goal number');
            if (phoneDigits.subString(0,countryCode.length()) == countryCode) {
                system.debug('key ' + thisPhone + ' has country code at start');
                if (phoneDigits.length() == (numDigitsInNumber+countryCode.length())) {
                    phoneDigits = '+' + phoneDigits;
                } else {
                    extraDigits = phoneDigits.subString(numDigitsInNumber+countryCode.length(),phoneDigits.length());
                    phoneDigits = '+' + phoneDigits.subString(0,numDigitsInNumber+countryCode.length());
                    
                }
            } else {
                system.debug('key ' + thisPhone + ' doesnt have country code at start');
                extraDigits = phoneDigits.subString(numDigitsInNumber,phoneDigits.length());
                phoneDigits = '+' + countryCode + phoneDigits.subString(0,numDigitsInNumber);
            }
            system.debug('phoneDigits: ' + phoneDigits + ', extraDigits: ' + extraDigits);
            if (extraDigits != null) {
                phoneDigits += 'x' + extraDigits;
            }
        }else{
             if (phoneDigits.length() >= countryCode.length() && phoneDigits.subString(0,countryCode.length()) == countryCode) {
                system.debug('key ' + thisPhone + ' has country code at start');
                phoneDigits = '+' + phoneDigits;
                return phoneDigits;
            }
            phoneDigits = '+' + countryCode + phoneDigits;
            system.debug('phoneDigits if greater than numofdigits ' + phoneDigits);
        }
        
        system.debug('after changes: ' + phoneDigits);
        return phoneDigits;
    }
   
}