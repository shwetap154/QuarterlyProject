/*************************************************************************************
* Name          :    ZTS_GL_AddSampleDrop_Controller.
* Description   :    Controller for adding a Sample Drop in the Sales Call.
* Author        :    Akanksha
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
05/20/2014       Akanksha                    Created
10/20/2014       SOHIL SHAH(CloudSense)      Added code to solve defect - 1297 
02/05/2015       SOHIL SHAH(CloudSense)      Modified the query for DEF- DEF-001269 (Product Name Vs Description)   
**************************************************************************************/
public  with sharing  class ZTS_GL_AddSampleDrop_Controller{

    public String callId{get;set;}
    public String searchString{get;set;}
    public List<ZTS_US_Sample_Drop__c> sDropObjList{get;set;}
    public ZTS_US_Sample_Drop__c samdrop{get;set;}
    public Set<Id> setSDropID = new Set<Id>();
    public String addSampleId{get;set;}
    public String sampleDropId{get;set;}    
    public map<Id,Boolean> mapSearchedSampleIdBool {get;set;} {mapSearchedSampleIdBool = new map<Id,Boolean>();}  
    public List<ZTS_US_Sample__c> sampleList{get;set;}
    public boolean removeadd{get;set;}
    public boolean detailsection{get;set;}
    public String onhand{get;set;}
    public String productdescription{get;set;}
    public String lot{get;set;}
    /***********
        * Method name  : ZTS_GL_AddSampleDrop_Controller
        * Description  : Get the details of Sample record.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_GL_AddSampleDrop_Controller(){
       sDropObjList = new List<ZTS_US_Sample_Drop__c>();
       samdrop= new ZTS_US_Sample_Drop__c();
        searchString = '';
        removeadd=false;
        detailsection=false;
        onhand='';
        productdescription='';
        lot = '';
        //By sohil   Modified the query for DEF- DEF-001269 (Product Name Vs Description)   
        sampleList=[select id,Name,ZTS_US_Product__c,ZTS_US_Product__r.Name, ZTS_US_Item_Code__c,ZTS_US_Product__r.ZTS_Description__c,  ZTS_US_Start_Quantity__c ,ZTS_US_On_Hand_Balance__c,OwnerId,ZTS_US_Lot__c from ZTS_US_Sample__c where OwnerId = : UserInfo.getUserId() ];
        if(ApexPages.currentPage().getParameters().containsKey('searchString')){
            searchString  = ApexPages.currentPage().getParameters().get('searchString');
        } 
        if(ApexPages.currentPage().getParameters().containsKey('callId')){
             callId = ApexPages.currentPage().getParameters().get('callId');
        }
        if(callId != null){
            querySampleDrop();
        } 
    }
    /***********
        * Method name  : setSDropCont
        * Description  : Standard controller for the page.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/ 
    public ApexPages.StandardSetController setSDropCont{
        get {
            if(setSDropCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                //By sohil   Modified the query for DEF- DEF-001269 (Product Name Vs Description)
                setSDropCont =  new ApexPages.StandardSetController([select id,Name,ZTS_US_Product__c,ZTS_US_Product__r.Name,ZTS_US_Product__r.ZTS_Description__c, ZTS_US_Item_Code__c,  ZTS_US_Start_Quantity__c ,ZTS_US_On_Hand_Balance__c,OwnerId,ZTS_US_Lot__c from ZTS_US_Sample__c   where ( ZTS_US_Product__r.Name like:searchTxt or name like :searchTxt ) and OwnerId = : UserInfo.getUserId() and Id NOT IN :setSDropID order by name limit 750]);
                // sets the number of records in each page set   
                setSDropCont.setPageSize(15);
            }
            return setSDropCont;
        }set;
    }
    /***********
        * Method name  : getAssoSamples
        * Description  : Method to get the samples created by the logged in user.
        * Return Type  : List<ZTS_EU_Sample__c >.
        * Parameters   : None.
    ***********/ 
    public List<ZTS_US_Sample__c > getAssoSamples(){
            /*changed bu sohil shah(Cloud Sense)20th oct
              Display only those line items whose On Balance value is greater than 0
            * Modified the query for DEF- DEF-001269 (Product Name Vs Description)
            */
            sampleList=[select id,Name,ZTS_US_Product__c,ZTS_US_Product__r.Name,ZTS_US_Product__r.ZTS_Description__c, ZTS_US_Item_Code__c,  ZTS_US_Start_Quantity__c ,ZTS_US_On_Hand_Balance__c,OwnerId,ZTS_US_Lot__c,(Select Id,ZTS_US_Sample__c,ZTS_US_Call__c from Sample_Drops__r where ZTS_US_Call__c=:callId) from ZTS_US_Sample__c where OwnerId = : UserInfo.getUserId() and ZTS_US_On_Hand_Balance__c > 0 order by ZTS_US_Product__r.ZTS_Description__c,ZTS_US_Lot__c ASC];
             for(ZTS_US_Sample__c  sas : sampleList){
             if(sas.Sample_Drops__r!=null && sas.Sample_Drops__r.size()>0){ //&& sas.callid=callId){
                 mapSearchedSampleIdBool.put(sas.id,false);
                 }
                 else{
                 mapSearchedSampleIdBool.put(sas.id,true);
                 }
            }
           
            
            return sampleList ;
     
    }
    /***********
        * Method name  : addSampleDrop
        * Description  : Method to add the samples to the call and create an associated sample drop.
        * Return Type  : pageReference.
        * Parameters   :None.
    ***********/
    public pageReference addSampleDrop(){ 
    
     system.debug('--------INSIDE SAMPLE---'+addSampleId+'----------'+samdrop);
     removeadd=true;
     detailsection=false;
       if(addSampleId != null && callId != null){
            Call__c callObj = [select id ,ZTS_EU_Account__c from call__c where id=:callId AND ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States' limit 1];  
            samdrop.ZTS_US_Account__c = callObj.ZTS_EU_Account__c;
            samdrop.ZTS_US_Call__c = callId;
            samdrop.ZTS_US_Sample_Drop_Type__c = 'Sample Drop';
            try{
                insert samdrop;
                system.debug('----------INSIDE SAMPLE-----'+addSampleId+'------map-----'+mapSearchedSampleIdBool);
                if(mapSearchedSampleIdBool.containsKey(addSampleId)){
                    mapSearchedSampleIdBool.put(addSampleId,false);
                }
                querySampleDrop();
                system.debug('----------INSIDE SAMPLE-----'+addSampleId+'------map-----'+mapSearchedSampleIdBool);
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return new PageReference('/apex/ZTS_GL_AddSampleDrop?callId='+callId);
     }
     /***********
        * Method name  : addedSample
        * Description  : Method invoked when add button is clicked to add the sample to the call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
     public void addedSample(){
     samdrop= new ZTS_US_Sample_Drop__c();
     detailsection=true;
     removeadd=true;
     //By sohil  Modified the query for DEF- DEF-001269 (Product Name Vs Description)
       List<ZTS_US_Sample__c> samList= [Select Id,ZTS_US_Product__r.Name,ZTS_US_Lot__c,ZTS_US_Product__r.ZTS_Description__c,ZTS_US_On_Hand_Balance__c from ZTS_US_Sample__c where Id=:addSampleId];
       if(samList!=null && samList.size()>0){
       productdescription=samList[0].ZTS_US_Product__r.ZTS_Description__c; // by sohil for product description 
       lot = samList[0].ZTS_US_Lot__c;
       samdrop.ZTS_US_Sample__c=samList[0].Id;
       onhand=String.valueOf(samList[0].ZTS_US_On_Hand_Balance__c);
     }
     }
    /***********
        * Method name  : removeSamples
        * Description  : Method invoked when remove button is clicked to remove the sample from the call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
     public void removeSamples(){
     removeadd=false;
        if(sampleDropId != null){
            ZTS_US_Sample_Drop__c sDDelObj = new ZTS_US_Sample_Drop__c (id =sampleDropId );
            try{
                delete sDDelObj;
                querySampleDrop();
            }catch(exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
     }
     /***********
        * Method name  : querySampleDrop
        * Description  : Method to query the associated samples to a call and display.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    public void  querySampleDrop(){
        sDropObjList = new List<ZTS_US_Sample_Drop__c>();
        //By sohil   Modified the query for DEF- DEF-001269 (Product Name Vs Description)
        sDropObjList = [select id,Name,ZTS_US_Account__c,ZTS_US_Call__c,ZTS_EU_Quantity__c,ZTS_US_Sample__c,ZTS_US_Sample_Drop_Type__c, ZTS_US_Sample__r.Name,ZTS_US_Sample__r.ZTS_US_Lot__c,ZTS_US_Sample__r.ZTS_US_Product__r.Name,ZTS_US_Sample__r.ZTS_US_Product__r.ZTS_Description__c, ZTS_US_Sample__r.ZTS_US_On_Hand_Balance__c from ZTS_US_Sample_Drop__c where ZTS_US_Call__c =:callId];
        for(ZTS_US_Sample_Drop__c sd : sDropObjList ){
            setSDropID.add(sd.ZTS_US_Sample__c);
        }
    }
    
}