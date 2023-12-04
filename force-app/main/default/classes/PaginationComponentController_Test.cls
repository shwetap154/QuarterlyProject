@isTest
public class PaginationComponentController_Test{

 public static testMethod void Pagination_Test(){
     try{
     set<string> objNames = new set<String>();
          objNames.add('Account');
      objNames.add('ZTS_EU_Species_Product__c');
          list<recordtype> recordtypesLst = new list<recordtype>();
          recordtypesLst = [select id, developerName,SobjectType from recordtype where SobjectType in :objNames ];
          
          map<string, string> recordtypeMap = new map<string, string>();
          
          for(Recordtype r : recordtypesLst){
            string objName_DeveloperName = r.SobjectType +'-'+ r.developerName;
            recordtypeMap.put(objName_DeveloperName, r.id);
            system.debug('objName_DeveloperName>>:'+objName_DeveloperName);
          }
     list<Account> accountRecords = new list<account>();
          accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
          accountRecords.addAll(TestUtilities.createNoInsertAccount('Acc','Farm','Beef',recordtypeMap.get('Account-ZTS_EU_Activated_Account'),'United Kingdom','1',false));
          
          if(accountRecords.size() > 0){
            insert accountRecords;
          }
     list<String>  sObjectFieldList=  new List<String>{'Name','Type'};
   PaginationComponentController pg= new PaginationComponentController();
   ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountRecords);
   pg.idList=accountRecords ;
   pg.getIdListRecords();  
   pg.SobjFieldList=sObjectFieldList;
   pg.getSobjtFieldList();
   List<String> fieldList=pg.FieldList;
   pg.getSObjectRecs();       
   ssc = pg.setOfRecords;
 }
   catch(Exception e)
   {
       system.debug('Exception'+e);
   }
 }
 
}