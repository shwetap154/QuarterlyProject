/*************************************************************************************
* Name          :    ZTS_EU_HistoryTrackingController.
* Description   :    Controller for the History Tracking .
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer        Comments
---------------------------------------------------------------------------------------
3/11/2014        Sunil            Created

**************************************************************************************/
public with sharing class ZTS_EU_HistoryTrackingController {

    public List<List<objectHistoryLine>> objHistoryList{get;set;}
    public ID objIds{get;set;}
    public Map<String,String> chilObjRelationShipName = new map<String,String>();
    public static Map<String, Schema.SObjectField> objectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues; 
     
    /***********
            * Method name  : ZTS_EU_HistoryTrackingController
            * Description  : Gets the account id and display history items.
            * Return Type  : None.
            * Parameters   : None.
     ***********/
    public ZTS_EU_HistoryTrackingController(){
     
        if(ApexPages.currentPage().getParameters().containskey('id')){ 
              childRelationName(); 
              objHistoryList=new List<List<objectHistoryLine>>();
              objIds =  ApexPages.currentPage().getParameters().get('id');
              Schema.SObjectType token = objIds.getSObjectType();           
              Schema.DescribeSObjectResult dr = token.getDescribe();                        
              List<SObject>  sobjHistList=getSObjectHistoryData(dr.getName(),false,objIds);
              objHistoryList.add(populateHistoryLine(sobjHistList,dr.getName()));
                         
           //get child history records
           
           // for(String childName: getChildNames(dr)){
           for(String childName:chilObjRelationShipName.keySet()){
               if(chilObjRelationShipName.containsKey(childName)){
                  List<SObject>  sobjHistList2=getSObjectHistoryData(childName,true,objIds );
                  if(sobjHistList2.size()>0)
                  objHistoryList.add(populateHistoryLine(sobjHistList2,childName));
              }          
            }
       }
      
    }     
    /***********
            * Method name  : childRelationName
            * Description  : Fetch the child relationship name.
            * Return Type  : None.
            * Parameters   : None.
     ***********/
    public void childRelationName(){
        chilObjRelationShipName.put('ZTS_EU_Account_Affiliations__c','ZTS_EU_Account__c');
        chilObjRelationShipName.put('Address__c','ZTS_EU_Account__c');
        chilObjRelationShipName.put('Contact','Accountid');
        chilObjRelationShipName.put('ZTS_GL_Request__c','ZTS_GL_Account_To_Be_Changed__c');
        chilObjRelationShipName.put('ZTS_EU_Affiliations__c','ZTS_EU_Account__c');
        chilObjRelationShipName.put('ZTS_EU_Account_Species_Potential__c','Account__c');
        chilObjRelationShipName.put('Case','Accountid');
        chilObjRelationShipName.put('Call__c','ZTS_EU_Account__c');
        
        
        
    }
    /***********
            * Method name  : SObjectHistoryData
            * Description  : Get the history data.
            * Return Type  : List.
            * Parameters   : String,Boolean,ID.
     ***********/
    public List<SObject> getSObjectHistoryData(String sobjectName , boolean child,Id accId){
        List<SObject> sobjlist=new List<SObject>();  
        try{  
        
            if(child){
                            
                String qry='SELECT Id from '+sobjectName + ' WHERE ' +chilObjRelationShipName.get(sobjectName)+' = :accId';
                if(sobjectName == 'ZTS_EU_Account_Affiliations__c' || sobjectName == 'Address__c') qry += ' AND ZTS_EU_Market_from_Primary_Account__c != \'United States\'';
                System.debug('  qry  :::: '+qry);
                List<SObject> objList=Database.query(qry);    
                System.debug('  objList  :::: '+objList.size());            
                sobjectName=sobjectName.replace('__c','__');
                system.debug('sobjectName*******>'+sobjectName);
                if(sobjectName == 'Contact'){
                    String qry_contact='SELECT id FROM Contact WHERE accountId =:accId AND ZTS_EU_Market__c != \'United States\'';
                    List<SObject> conIdList=Database.query(qry_contact);
                    String con_history='SELECT ContactId,CreatedDate,CreatedById,Field,NewValue,OldValue FROM contacthistory WHERE ContactId IN:conIdList Order By CreatedDate DESC LIMIT 25'  ;
                    sobjlist=Database.query(con_history);
                }
                else if(sobjectName == 'Case'){
                    String qry_case='SELECT id FROM case WHERE accountId =:accId';
                    List<SObject> caseIdList=Database.query(qry_case);
                    String con_history='SELECT CaseId,CreatedDate,CreatedById,Field,NewValue,OldValue FROM casehistory where CaseId IN:caseIdList LIMIT 25';
                }
                else {
                    String qry_history='SELECT parentid,CreatedDate,CreatedById,Field,NewValue,OldValue FROM '+sobjectName+'History '+'where ParentId IN :objList Order By CreatedDate DESC LIMIT 50';
                    system.debug('qry_history******>'+qry_history);               
                    sobjlist=Database.query(qry_history);
                } 
            }
            else{  
                if(sobjectName == 'Account'){         
                    String qry='SELECT AccountID,CreatedDate,CreatedById,Field,NewValue,OldValue FROM '+sobjectName+'History '+'where AccountId = :accId  Order By CreatedDate DESC LIMIT 25';
                    sobjlist=Database.query(qry);                   
                } 
            }                                               
            
        }     
        catch(Exception ex){
            System.debug('Exception : '+ex); 
        }
  
        return sobjlist;  
    }
    /***********
            * Method name  : populateHistoryLine
            * Description  : Get the history data.
            * Return Type  : List.
            * Parameters   : List,String.
     ***********/
    public List<objectHistoryLine> populateHistoryLine(List<SObject> sobjList,String SObjectName){
        List<objectHistoryLine> objHistList=new List<objectHistoryLine>();
        for(SObject sobj:sobjList){
           objectHistoryLine objHist=new objectHistoryLine();
           objHist.field=(String)sobj.get('Field');
           if(sobj.get('Field') == 'Owner'){}
           Object obj=sobj.get('newValue');
           if(obj instanceof DateTime && obj!= null){              
               objHist.newValue=((DateTime)obj).format();
           }
           else if(obj instanceof Date && obj!= null){              
               objHist.newValue=((Date)obj).format();
           }
           else{
            objHist.newValue=String.valueOf(sobj.get('newValue'));           
           }
           Object objOld =sobj.get('oldValue');
           if(objOld instanceof DateTime && objOld!= null){              
               objHist.oldValue=((DateTime)objOld).format();
           }
           else if(objOld instanceof Date && objOld!= null){              
               objHist.oldValue=((Date)objOld).format();
           }
           else{
            objHist.oldValue=String.valueOf(sobj.get('oldValue'));           
           }
           
           objHist.SObjectName=SObjectName;
           if(sobj.get('CreatedDate') != null)
           objHist.theDate = Datetime.valueof(sobj.get('CreatedDate')).format();
           objHist.userId = String.valueOf(sobj.get('CreatedById'));
           objHist.who = String.valueOf(sobj.get('CreatedById'));
           if(SObjectName == 'Account' && (String.valueOf(sobj.get('AccountID')) != null || String.valueOf(sobj.get('AccountID')) != '')){
              objHist.parentID = String.valueOf(sobj.get('AccountID'));
           }
           else if(SObjectName == 'Contact' && (String.valueOf(sobj.get('ContactId')) != null || String.valueOf(sobj.get('ContactId')) != '')){
               objHist.parentID = String.valueOf(sobj.get('ContactId'));
           }
           else if(String.valueOf(sobj.get('parentid')) != null || String.valueOf(sobj.get('parentid')) != ''){
              objHist.parentID = String.valueOf(sobj.get('parentid'));
           }
                
            // Add to the list
            objHistList.add(objHist);   
        }

        List<Id> userIdList = new List<Id>();
        for (objectHistoryLine userHistory : objHistList){
             userIdList.add(userHistory.userId);
         }

         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList AND ZTS_EU_Market__c != 'United States']);
         for (objectHistoryLine userDetail : objHistList){
             if (userIdMap.containsKey(userDetail.userId) & (userDetail.who != '') ){
                 userDetail.who = userIdMap.get(userDetail.who).Name;
             }
         }
        return objHistList;  
    }
    /***********
            * Method name  : ChildNames
            * Description  : Get the Child name.
            * Return Type  : List.
            * Parameters   : DescribeSObjectResult.
     ***********/
    public List<String> getChildNames(DescribeSObjectResult dr){
  
        List<String> childNames=new List<String>();  
        List<childRelationship>  childObjList = dr.getchildRelationships(); 
        for(childRelationship   child: childObjList ){
            if(String.valueOf(child.getChildSobject()).contains('__c')){
                childNames.add(String.valueOf(child.getChildSobject()));                    
            }
        }
        return childNames;
  
    }
    
    
    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine{
  
       public String theDate {get; set;}
       public Id userId {get; set;}
       public String newValue{get; set;}
       public String oldValue{get; set;} 
       public String field{get; set;} 
       public String SObjectName{get;set;}
       public String parentID{get;set;}
       public String who {get; set;}
       
    }
}