/*************************************************************************************
* Name          :    AddDiscussionController.
* Description   :    Controller for adding a discussion in the Sales Call.
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
12/23/2013       Sunil                       Created

01/05/2014      Akanksha                    Modified to incorporate latest call changes.
01/08/2015      Sohil Shah(CloudSense)      Modified the removeProduct Method for retrieving products/DI related to calls only 
                                            and delete them from database for that call attendees
**************************************************************************************/
public with sharing class AddDiscussionController {
    public String callId{get;set;}
    public List<ZTS_EU_Discussion__c> discObj{get;set;}
    public Map<String,List<Attendee__c>> discattenMap {get;set;} 
    public String prodId{get;set;}
    public String campId{get;set;}
    public String DIId{get;set;}
    public String discuname{get;set;}
    public String searchString{get;set;}
    public String addProdId{get;set;}
    public String addCampId{get;set;}
    public String addDIId{get;set;}
    public String currdiscc{get;set;}
    public String attendeeRemoveId{get;set;}
    public String prodName{get;set;}
    public String campName{get;set;}
    public String DIName{get;set;}
    public String discId{get;set;}    
    public Set<Id> setProductID = new Set<Id>(); 
    public Set<Id> setCampID = new Set<Id>(); 
    public Set<Id> setDisItemID = new Set<Id>(); 
    public String prodvalue{get;set;}
    public String values{get;set;}
    public String URL{get;set;}
    public map<Id,Boolean> mapSearchedProdIdBool {get;set;} {mapSearchedProdIdBool = new map<Id,Boolean>();}  
    public Set<Id> setAttendeeId = new Set<Id>();
    public List<Attendee__c> listattendees{get;set;}
    public boolean showattendee{get;set;}
    public boolean  hideattendee{get;set;}
    public boolean showview{get;set;}
    public String attendeeid{get;set;}
    
    /***********
        * Method name  : AddDiscussionController
        * Description  : Get the details of discussion record.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
     public AddDiscussionController(){
         //searchString = '';
         attendeeid = '';
         discuname='';
         currdiscc='';
         attendeeRemoveId='';
         showattendee=false;
         hideattendee=false;
         showview=true;
         listattendees=new List<Attendee__c>();
         listattendees=[Select id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
         for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']){
                setAttendeeId.Add(callattendee.Id);
         }
         prodvalue = '';
         URL = '';
         if(ApexPages.currentPage().getParameters().containsKey('searchString')){
            searchString  = ApexPages.currentPage().getParameters().get('searchString');
            searchString = searchString.replace(' (Product)', '').replace(' (Campaign)', '').replace(' (Discussion Item','');
         } 
         if(ApexPages.currentPage().getParameters().containsKey('callId')){
             callId = ApexPages.currentPage().getParameters().get('callId');
         }
         if(callId != null){
            queryCurrentProduct();
         }
         
     }
     /***********
        * Method name  : populateProducts
        * Description  : Method to add products as discussion to call.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
     public void populateProducts(){
        prodvalue = '';
        values = '';
        List <ZTS_EU_Species_Product__c> prodList = [SELECT Name,ZTS_Hierarchy_Level__c from ZTS_EU_Species_Product__c where ZTS_Hierarchy_Level__c = 'Brand'];
        List <Campaign> campList = [Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where IsActive=true and Is_Active_Campaign__c=true AND ZTS_EU_Market__c = 'United States'];
        List <ZTS_EU_Discussion_Item__c> discitemsList = [SELECT Name,ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Active_DI__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Active_DI__c=true AND ZTS_EU_Market__c = 'United States'];
         for (ZTS_EU_Species_Product__c pro:prodList){
            prodvalue += ',dbqt' + pro.Name +' (Product)'+'dbqt' ; 
         }
         for (Campaign ca:campList){
            prodvalue += ',dbqt' + ca.Name +' (Campaign)'+'dbqt' ; 
         }
         for (ZTS_EU_Discussion_Item__c dis:discitemsList){
            prodvalue += ',dbqt' + dis.ZTS_EU_Discussion_Item_Title__c +' (Discussion Item)'+'dbqt' ;
         }
         prodvalue = prodvalue.replaceFirst(',','');
         values = prodvalue;
           System.debug('$$$ ****************'+prodvalue );
                   
         }
    /***********
        * Method name  : setProdCont
        * Description  : Standard controller to set Products.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
     public ApexPages.StandardSetController setProdCont{
         get {
            if(setProdCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setProdCont = new ApexPages.StandardSetController([SELECT Id,Name,ZTS_Hierarchy_Level__c FROM ZTS_EU_Species_Product__c where ZTS_Hierarchy_Level__c='Brand' and name like :searchTxt and Id NOT IN :setProductID order by name limit 750]);
                //sets the number of records in each page set   
                setProdCont.setPageSize(15);
            }
            return setProdCont;
         }
         set;
     }
     /***********
        * Method name  : setCampCont
        * Description  : Standard controller to set Campaigns.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
     public ApexPages.StandardSetController setCampCont{
         get {
            if(setCampCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setCampCont = new ApexPages.StandardSetController([Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where IsActive=true and name like :searchTxt and Id NOT IN :setCampID AND ZTS_EU_Market__c = 'United States' order by name limit 750]);
                
                //sets the number of records in each page set   
                setCampCont.setPageSize(15);
            }
            return setCampCont;
         }
         set;
     }
     /***********
        * Method name  : setDiscItemsCont
        * Description  : Standard controller to set Discussion Items.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
     public ApexPages.StandardSetController setDiscItemsCont{
         get {
            if(setDiscItemsCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setDiscItemsCont = new ApexPages.StandardSetController([SELECT Name,ZTS_EU_Active_DI__c,ZTS_EU_Discussion_Item_Title__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Active_DI__c=true and ZTS_EU_Discussion_Item_Title__c like :searchTxt and Id NOT IN :setProductID AND ZTS_EU_Market__c = 'United States' order by ZTS_EU_Discussion_Item_Title__c limit 750]);
                
                //sets the number of records in each page set   
                setDiscItemsCont.setPageSize(15);
            }
            return setDiscItemsCont;
         }
         set;
     }
     /***********
        * Method name  : getProducts
        * Description  : Method to get the products on the page.
        * Return Type  : List<ZTS_EU_Species_Product__c>.
        * Parameters   : none.
    ***********/
     public List<ZTS_EU_Species_Product__c> getProducts(){
        if(setProdCont!= null){
            List<ZTS_EU_Species_Product__c> lstTempProd = new List<ZTS_EU_Species_Product__c>();
            lstTempProd = (List<ZTS_EU_Species_Product__c>) setProdCont.getRecords();
            for(ZTS_EU_Species_Product__c p : lstTempProd){
                mapSearchedProdIdBool.put(p.Id,true);
            }
            for(ZTS_EU_Discussion__c pm : discObj){
                if(mapSearchedProdIdBool.containsKey(pm.ZTS_EU_Product__c)){
                     mapSearchedProdIdBool.put(pm.ZTS_EU_Product__c,false);
                }
            }
            system.debug('Products******>' +lstTempProd);
            return lstTempProd;
        }
        else
        return null;
        }
    /***********
        * Method name  : getCampaigns
        * Description  : Method to get the campaigns on the page.
        * Return Type  : List<Campaign>.
        * Parameters   : None.
    ***********/
     public List<Campaign> getCampaigns(){
        if(setCampCont!= null){
            List<Campaign> lstTempCamp = new List<Campaign>();
            lstTempCamp = (List<Campaign>) setCampCont.getRecords();
            for(Campaign c : lstTempCamp){
                mapSearchedProdIdBool.put(c.Id,true);
            }
            for(ZTS_EU_Discussion__c pm : discObj){
                if(mapSearchedProdIdBool.containsKey(pm.ZTS_EU_Campaign__c)){
                     mapSearchedProdIdBool.put(pm.ZTS_EU_Campaign__c,false);
                }
            }
            system.debug('Campaigns******>' +lstTempCamp );
            return lstTempCamp ;
        }
        else
        return null;
        }
    /***********
        * Method name  : getdiscitems
        * Description  : Method to get the discussion items on the page.
        * Return Type  : List<ZTS_EU_Discussion_Item__c>.
        * Parameters   : None.
    ***********/
    public List<ZTS_EU_Discussion_Item__c> getdiscitems(){
        if(setDiscItemsCont!= null){
            List<ZTS_EU_Discussion_Item__c> lstTempDI = new List<ZTS_EU_Discussion_Item__c>();
            lstTempDI = (List<ZTS_EU_Discussion_Item__c>) setDiscItemsCont.getRecords();
            for(ZTS_EU_Discussion_Item__c di : lstTempDI){
                mapSearchedProdIdBool.put(di.Id,true);
            }
            for(ZTS_EU_Discussion__c pm : discObj){
                if(mapSearchedProdIdBool.containsKey(pm.ZTS_EU_Discussion_Items__c)){
                     mapSearchedProdIdBool.put(pm.ZTS_EU_Discussion_Items__c,false);
                }
            }
            system.debug('Discussion Items******>' +lstTempDI);
            return lstTempDI;
        }
        else
        return null;
        }
    /***********
        * Method name  : removeProduct
        * Description  : Method to remove the products added as discussions on the page.
        * Return Type  : Void.
        * Parameters   : None.
        
        * Modified     : Sohil Shah(CloudSense) retrieving products/DI related to calls only and delete them from database for that call attendees
    ***********/
     public void removeProduct(){
        if(prodName != null){          
            List<ZTS_EU_Discussion__c> pMDelObj = [SELECT Id,Name,ZTS_EU_Call_Attendee__c from ZTS_EU_Discussion__c where Name=:prodName and ZTS_EU_Call_Attendee__r.ZTS_EU_call__c=:callId AND ZTS_EU_Market__c = 'United States'];
            try{
                delete pMDelObj;
                queryCurrentProduct();
            }catch(exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
     }
     /***********
        * Method name  : removeAttendees
        * Description  : Method to remove the attendees added for discussions on the page.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
      public void removeAttendees(){
        if(attendeeRemoveId!= null){
            List<ZTS_EU_Discussion__c> listDisc=[SELECT Id,Name,ZTS_EU_Call_Attendee__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c=:attendeeRemoveId and Name=:discuname AND ZTS_EU_Market__c = 'United States'];
            try{
                if(listDisc!=null && listDisc.size()>0){
                delete listDisc;
                queryCurrentProduct();
                }
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
     }
     /***********
        * Method name  : searchProduct
        * Description  : Method to search the products and discussions to be added.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public PageReference searchProduct(){
         system.debug('--------------searchString: '+ searchString);
         searchString = searchString.replace(' (Product)', '').replace(' (Campaign)', '').replace(' (Discussion Item','');
          system.debug('--------------searchString: '+ searchString);
         searchString=  EncodingUtil.urlEncode(searchString, 'UTF-8');
         URL = '/apex/AddProduct?searchString='+searchString;
         if(callId != null){
             URL = URL + '&callId='+callId;
         }
         pageReference pg =  new pageReference(URL );
         system.debug('--------------PAGE REF '+ pg);
         pg.setRedirect(true);
         return pg;
     }
     /***********
        * Method name  : addProduct
        * Description  : Method to add the products as discussions.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public PageReference addProduct(){ 
         if(addProdId != null && prodName != null && callId != null){
            List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']){
                    ZTS_EU_Discussion__c pMetricsObj = new ZTS_EU_Discussion__c();
                    pMetricsObj.ZTS_EU_Product__c = addProdId;
                    pMetricsObj.Name = prodName;
                    pMetricsObj.ZTS_EU_Call_Attendee__c = callattendee.Id;
                    diList.add(pMetricsObj);
            }
            
            //pMetricsObj.Call__c = callId;
            try{
                insert diList;
                if(mapSearchedProdIdBool.containsKey(addProdId)){
                    mapSearchedProdIdBool.put(addProdId,false);
                }
                queryCurrentProduct();
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     }
     /***********
        * Method name  : addCampaign
        * Description  : Method to add the campaigns as discussions.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public PageReference addCampaign(){ 
         if(addCampId != null && campName != null && callId != null){
         List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']){
            ZTS_EU_Discussion__c pMetricsObj = new ZTS_EU_Discussion__c();
            pMetricsObj.ZTS_EU_Campaign__c = addCampId;
            pMetricsObj.Name = campName;
            pMetricsObj.ZTS_EU_Call_Attendee__c = callattendee.Id;
            diList.add(pMetricsObj);
            }
            //pMetricsObj.Call__c = callId;
            try{
                insert diList;
                if(mapSearchedProdIdBool.containsKey(addCampId)){
                    mapSearchedProdIdBool.put(addCampId,false);
                }
                queryCurrentProduct();
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     } 
     /***********
        * Method name  : addDI
        * Description  : Method to add the discussion items as discussions.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public PageReference addDI(){ 
         if(addDIId != null && DIName != null && callId != null){
         List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']){
            ZTS_EU_Discussion__c pMetricsObj = new ZTS_EU_Discussion__c();
            pMetricsObj.ZTS_EU_Discussion_Items__c = addDIId;
            pMetricsObj.Name = DIName;
            pMetricsObj.ZTS_EU_Call_Attendee__c = callattendee.Id;
            diList.add(pMetricsObj);
            }
            //pMetricsObj.Call__c = callId;
            try{
                insert diList;
                if(mapSearchedProdIdBool.containsKey(addDIId)){
                    mapSearchedProdIdBool.put(addDIId,false);
                }
                queryCurrentProduct();
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     }
      /***********
        * Method name  : queryCurrentProduct
        * Description  : Method to query products as discussions and add a discussion record.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
     public void queryCurrentProduct(){
         setAttendeeId = new Set<ID>();
         discattenMap = new Map<String,List<Attendee__c>>();
         discObj = new List<ZTS_EU_Discussion__c >();
         Map<Id,Attendee__c> mapattid = new Map<Id,Attendee__c>();
         for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States']){
          setAttendeeId.Add(callattendee.Id);
          mapattid.put(callattendee.Id,callattendee);
         }
         Map<String,String> mapProductName = new Map<String, String>();
         system.debug('------------setAttendeeId: ' + setAttendeeId);
         for(ZTS_EU_Discussion__c disc : [select id,name,ZTS_EU_Product__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Call_Attendee__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c in:setAttendeeId AND ZTS_EU_Market__c = 'United States']){
             if(!mapProductName.containsKey(disc.Name)){
                 discObj.add(disc);
                 mapProductName.put(disc.Name,disc.Name);
             }
             if(!discattenMap.containsKey(disc.Name)){
                    discattenMap.put(disc.Name,new List<Attendee__c>{mapattid.get(disc.ZTS_EU_Call_Attendee__c)});
             }
             else{
                    discattenMap.get(disc.Name).add(mapattid.get(disc.ZTS_EU_Call_Attendee__c));
             }
             
         }
         system.debug('---------SIZE---------------'+discObj.size());
         for(ZTS_EU_Discussion__c  pm : discObj){
             setProductID.add(pm.ZTS_EU_Product__c);
             setCampID.add(pm.ZTS_EU_Campaign__c);
             setDisItemID.add(pm.ZTS_EU_Discussion_Items__c);
             
          }
     } 
      /***********
        * Method name  : addSearchString
        * Description  : Method to appened the search results with Product,Campaigns and Discussion Items.
        * Return Type  : Void.
        * Parameters   : None.
    ***********/
    public void addSearchString(){
        system.debug('-----------searchString: '+ searchString);
        if(searchString.contains(' (Product)')){
            List<ZTS_EU_Species_Product__c> productList = [select Name, Id from ZTS_EU_Species_Product__c where Name=:searchString.replace(' (Product)','') and ZTS_Hierarchy_Level__c = 'Brand'];
            if(productList != null && productList.size() >0){
                addProdId = productList[0].Id;
                prodName = productList[0].Name;
                addProduct();
            }
        }
        if(searchString.contains(' (Campaign)')){
            List <Campaign> campList = [Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where Name=:searchString.replace(' (Campaign)','') and IsActive=true AND ZTS_EU_Market__c = 'United States'];
        if(campList != null && campList.size() >0){
                addCampId = campList[0].Id;
                campName = campList[0].Name;
                addCampaign();
            }
        }
        if(searchString.contains(' (Discussion Item)')){
            List <ZTS_EU_Discussion_Item__c> discitemsList = [SELECT Name,ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Active_DI__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Discussion_Item_Title__c=:searchString.replace(' (Discussion Item)','') and ZTS_EU_Active_DI__c=true AND ZTS_EU_Market__c = 'United States'];
            if(discitemsList != null && discitemsList.size() >0){
                addDIId = discitemsList[0].Id;
                DIName = discitemsList[0].ZTS_EU_Discussion_Item_Title__c;
                addDI();
            }
        }
    }
    /***********
        * Method name  : showDiscussionAF
        * Description  : Action Function called on page to show the list of attendees .
        * Return Type  : Void.
        * Parameters   : None.
    ***********/ 
     public void showAttendeesAF(){
        system.debug('--------CallID-----'+callId);
        listattendees = [SELECT Id,Name,ZTS_EU_call__c,ZTS_EU_Represents_Account__c,ZTS_US_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c =:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c = 'United States'];
        showattendee=true;
        hideattendee=true;
        //showview=false;
        }
   /***********
        * Method name  : hideAttendeesAF
        * Description  : Action Function called on page to hide the list of attendees .
        * Return Type  : Void.
        * Parameters   : None.
    ***********/ 
    public void hideAttendeesAF(){
     hideattendee=false;
     showattendee=false;
     //showview=true;
    }
       
}