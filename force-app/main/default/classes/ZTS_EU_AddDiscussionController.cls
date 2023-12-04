/*************************************************************************************
* Name          :    AddDiscussionController.
* Description   :    Controller for adding a discussion in the Sales Call. Discussion is created from
                :    Product, Campaign and Discussion Item Objects. On creation of Discussions each 
                :    Attendee of the call is mapped to all the discussions. 
* Author        :    Sunil
 
Modification Log
----------------
Date             Developer             Comments
---------------------------------------------------------------------------------------
12/23/2013       Sunil                  Created
03/25/2014       Akanksha               Modified
05/24/2014       Teresa                 Modified
**************************************************************************************/
public with sharing class ZTS_EU_AddDiscussionController {
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
    public String prodType{get;set;}
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
    
     public ZTS_EU_AddDiscussionController(){
         //searchString = '';
         attendeeid = '';
         discuname='';
         currdiscc='';
         attendeeRemoveId='';
         showattendee=false;
         hideattendee=false;
         showview=true;
    
         listattendees=new List<Attendee__c>();
         listattendees=[Select id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        
         for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
          setAttendeeId.Add(callattendee.Id);
         }
         prodvalue = '';
         URL = '';
         system.debug('------------------currnt URL: '+ ApexPages.currentPage().getURL());
         if(ApexPages.currentPage().getParameters().containsKey('searchString')){
            searchString  = ApexPages.currentPage().getParameters().get('searchString');
            //searchString = searchString.replace(' (Product)', '').replace(' (Campaign)', '').replace(' (Discussion Item','');
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
            * Description  : This is used to populate the List of Items seen on the UI for addition of Discusiion. This list consists of
                           : all the products, campaigns and discussion items that are available and active.
            * Return Type  : None.
            * Parameters   : none.
 ***********/
     public void populateProducts(){
        prodvalue = '';
        values = '';
        List <ZTS_EU_Species_Product__c> prodList = [SELECT Name,ZTS_EU_Type__c from ZTS_EU_Species_Product__c where ZTS_EU_Is_Detailable__c = true AND ZTS_EU_Is_Active__c = TRUE];
        List <Campaign> campList = [Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where IsActive=true AND ZTS_EU_Market__c != 'United States'];
        List <ZTS_EU_Discussion_Item__c> discitemsList = [SELECT Name,ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Active__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Active__c=true AND ZTS_EU_Market__c != 'United States'];
            
         for (ZTS_EU_Species_Product__c pro:prodList){
            prodvalue += '!dbqt' + pro.Name +' (Product-'+ pro.ZTS_EU_Type__c+')'+'dbqt' ; 
         }
         for (Campaign ca:campList){
            prodvalue += '!dbqt' + ca.Name +' (Campaign)'+'dbqt' ; 
         }
         for (ZTS_EU_Discussion_Item__c dis:discitemsList){
            prodvalue += '!dbqt' + dis.ZTS_EU_Discussion_Item_Title__c +' (Discussion Item)'+'dbqt' ;
         }
         prodvalue = prodvalue.replaceFirst('!','');
         values = prodvalue;
           System.debug('****************'+prodvalue );
                   
     }
     
/***********
            * Method name  : setProdCont
            * Description  : ApexPages.StandardSetController must be instantiated for standard list controllers for Products
            * Return Type  : None.
            * Parameters   : none.
 ***********/
     public ApexPages.StandardSetController setProdCont{
         get {
            if(setProdCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setProdCont = new ApexPages.StandardSetController([SELECT Id,Name,ZTS_EU_Type__c FROM ZTS_EU_Species_Product__c where ZTS_EU_Is_Detailable__c = true AND    ZTS_EU_Is_Active__c = TRUE and name like :searchTxt and Id NOT IN :setProductID order by name limit 750]);
                
                //sets the number of records in each page set   
                setProdCont.setPageSize(15);
            }
            return setProdCont;
         }
         set;
     }
/***********
            * Method name  : setCampCont
            * Description  : ApexPages.StandardSetController must be instantiated for standard list controllers for Campaigns
            * Return Type  : None.
            * Parameters   : none.
 ***********/
     public ApexPages.StandardSetController setCampCont{
         get {
            if(setCampCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setCampCont = new ApexPages.StandardSetController([Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where IsActive=true and name like :searchTxt and Id NOT IN :setCampID AND ZTS_EU_Market__c != 'United States' order by name limit 750]);
                
                //sets the number of records in each page set   
                setCampCont.setPageSize(15);
            }
            return setCampCont;
         }
         set;
     }
/***********
            * Method name  : setDiscItemsCont
            * Description  : ApexPages.StandardSetController must be instantiated for standard list controllers for Discussion Items
            * Return Type  : None.
            * Parameters   : none.
 ***********/
     public ApexPages.StandardSetController setDiscItemsCont{
         get {
            if(setDiscItemsCont == null && searchString != null && searchString != '') {
                String searchTxt= '%'+searchString +'%';
                setDiscItemsCont = new ApexPages.StandardSetController([SELECT Name,ZTS_EU_Active__c,ZTS_EU_Discussion_Item_Title__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Active__c=true AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Discussion_Item_Title__c like :searchTxt and Id NOT IN :setProductID order by ZTS_EU_Discussion_Item_Title__c limit 750]);
                
                //sets the number of records in each page set   
                setDiscItemsCont.setPageSize(15);
            }
            return setDiscItemsCont;
         }
         set;
     }
     
/***********
            * Method name  : getProducts
            * Description  : Return list of products
            * Return Type  : None.
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
            System.debug('product::'+pm.ZTS_EU_Product__c);
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
            * Description  : Return list of Campaigns
            * Return Type  : None.
            * Parameters   : none.
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
            * Description  : Return list of Discussion Items
            * Return Type  : None.
            * Parameters   : none.
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
            * Description  : Removes Product from Discussion object
            * Return Type  : None.
            * Parameters   : none.
 ***********/       
   
     public void removeProduct(){
        if(prodName != null){
        //Modified query by laxmikanth 9/13/2016 to limit delete of discussions to current call only
            List<ZTS_EU_Discussion__c> pMDelObj = [SELECT Id,Name,ZTS_EU_Call_Attendee__c 
 from ZTS_EU_Discussion__c where Name=:prodName and ZTS_EU_Call_Attendee__r.ZTS_EU_call__c=:callId AND ZTS_EU_Market__c != 'United States'];
            system.debug('-------LIST SIZE---------'+pMDelObj.size()+'---'+prodId+'---'+prodName);
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
            * Description  : Removes Discussion records when the Attendee in the call is deleted
            * Return Type  : None.
            * Parameters   : none.
 ***********/   
      public void removeAttendees(){
        if(attendeeRemoveId!= null){
            ZTS_EU_Discussion__c discDelete = [SELECT Id,Name,ZTS_EU_Call_Attendee__c 
 from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c=:attendeeRemoveId and Name=:discuname AND ZTS_EU_Market__c != 'United States'];
            try{
                delete discDelete;
                queryCurrentProduct();
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
     }

/***********
            * Method name  : addProduct
            * Description  : Fetch the Attendees present in the Call. Add Discussion record for each attendee 
                           : and the product.
            * Return Type  : None.
            * Parameters   : none.
 ***********/  
     public PageReference addProduct(){ 
         if(addProdId != null && prodName != null && callId != null){
            List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
                    ZTS_EU_Discussion__c pMetricsObj = new ZTS_EU_Discussion__c();
                    pMetricsObj.ZTS_EU_Product__c = addProdId;
                    pMetricsObj.Name = prodName +'-'+ prodType;
                    pMetricsObj.ZTS_EU_Call_Attendee__c = callattendee.Id;
                    diList.add(pMetricsObj);
            }
            
            //pMetricsObj.ZTS_EU_call__c = callId;
            try{
                insert diList;
                if(mapSearchedProdIdBool.containsKey(addProdId)){
                    mapSearchedProdIdBool.put(addProdId,false);
                }
                queryCurrentProduct();
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_AddDiscussionController-addProduct');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     }
     
/***********
            * Method name  : addCampaign
            * Description  : Fetch the Attendees present in the Call. Add Discussion record for each attendee 
                           : and the Campaign.
            * Return Type  : None.
            * Parameters   : none.
 ***********/ 
     public PageReference addCampaign(){ 
         if(addCampId != null && campName != null && callId != null){
         List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
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
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_AddDiscussionController-addCampaign');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     }
     
/***********
            * Method name  : addDI
            * Description  : Fetch the Attendees present in the Call. Add Discussion record for each attendee 
                           : and the Discussion Item.
            * Return Type  : None.
            * Parameters   : none.
 ***********/
     public PageReference addDI(){ 
         if(addDIId != null && DIName != null && callId != null){
         List<ZTS_EU_Discussion__c> diList = new List<ZTS_EU_Discussion__c>();
            system.debug('--------------callId: ' + callId);
            for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
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
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_AddDiscussionController-addDI');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            
         }
         return null;
     }
 
 /***********
            * Method name  : queryCurrentProduct
            * Description  : Fetch the Attendees present in the Call. Get all the discussion records for the attendees
                           : and map them as per product, campaign and discussion item.
            * Return Type  : None.
            * Parameters   : none.
 ***********/  
     public void queryCurrentProduct(){
      setAttendeeId = new Set<ID>();
        discattenMap = new Map<String,List<Attendee__c>>();
         discObj = new List<ZTS_EU_Discussion__c >();
         Map<Id,Attendee__c> mapattid = new Map<Id,Attendee__c>();
         for(Attendee__c callattendee:[SELECT id,Name,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c=:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']){
          setAttendeeId.Add(callattendee.Id);
          mapattid.put(callattendee.Id,callattendee);
         }
         Map<String,String> mapProductName = new Map<String, String>();
         system.debug('------------setAttendeeId: ' + setAttendeeId);
         for(ZTS_EU_Discussion__c disc : [select id,name,ZTS_EU_Product__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Call_Attendee__c 
 from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c in:setAttendeeId AND ZTS_EU_Market__c != 'United States']){
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
         //discObj = [select id,name,ZTS_EU_Species_Product__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c in:setAttendeeId AND ZTS_EU_Market__c != 'United States']; 
         //discObj = new List<ZTS_EU_Discussion__c>();
         system.debug('---------SIZE---------------'+discObj.size());
         for(ZTS_EU_Discussion__c  pm : discObj){
             setProductID.add(pm.ZTS_EU_Product__c);
             setCampID.add(pm.ZTS_EU_Campaign__c);
             setDisItemID.add(pm.ZTS_EU_Discussion_Items__c);
             
          }
     } 

 /***********
            * Method name  : addSearchString
            * Description  : Get the search String from UI as per category(Product/Campaign/Discussion Item)
                           : Get the data from Product/Campaign/Discussion Item and map it as per required
                           : for discussion object. 
            * Return Type  : None.
            * Parameters   : none.
 ***********/      
    public void addSearchString(){
        if(searchString.contains(' (Product')){
            String nameOfProduct = searchString.substring(0,searchString.indexOf(' (Product'));
            List<ZTS_EU_Species_Product__c> productList = [select Name, Id, ZTS_EU_Type__c from ZTS_EU_Species_Product__c where Name=:nameOfProduct AND ZTS_EU_Is_Detailable__c = true AND ZTS_EU_Is_Active__c = TRUE];
            if(productList != null && productList.size() >0){
                addProdId = productList[0].Id;
                prodName = productList[0].Name;
                prodType = productList[0].ZTS_EU_Type__c;
                addProduct();
            }
        }
        if(searchString.contains(' (Campaign)')){
            List <Campaign> campList = [Select Name,IsActive,ZTS_EU_Field_Targeting__c,StartDate,EndDate from Campaign where Name=:searchString.replace(' (Campaign)','') and IsActive=true AND ZTS_EU_Market__c != 'United States'];
        if(campList != null && campList.size() >0){
                addCampId = campList[0].Id;
                campName = campList[0].Name;
                addCampaign();
            }
        }
        if(searchString.contains(' (Discussion Item)')){
            List <ZTS_EU_Discussion_Item__c> discitemsList = [SELECT Name,ZTS_EU_Discussion_Item_Title__c,ZTS_EU_Active__c from ZTS_EU_Discussion_Item__c where ZTS_EU_Discussion_Item_Title__c=:searchString.replace(' (Discussion Item)','') AND ZTS_EU_Market__c != 'United States' and ZTS_EU_Active__c=true];
            system.debug('discitemsList====?'+ discitemsList);
            if(discitemsList != null && discitemsList.size() >0){
                addDIId = discitemsList[0].Id;
                DIName = discitemsList[0].ZTS_EU_Discussion_Item_Title__c;
                addDI();
            }
        }
    }
/***********
            * Method name  : showAttendeesAF
            * Description  : +View Attendees link from VF page directs to this method
                           : Here we fetch all attendees added to the call. We set boolean flags for rendering page appropriately
            * Return Type  : None.
            * Parameters   : none.
 ***********/          
     public void showAttendeesAF(){
        listattendees = [SELECT Id,Name,ZTS_EU_call__c,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c  from Attendee__c where ZTS_EU_call__c =:callId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        showattendee=true;
        hideattendee=true;
        showview=false;
        }
/***********
            * Method name  : hideAttendeesAF
            * Description  : - Hide Attendees link from VF page directs to this method
                           :  We set boolean flags for rendering page appropriately
            * Return Type  : None.
            * Parameters   : none.
 ***********/   
    public void hideAttendeesAF(){
     hideattendee=false;
     showattendee=false;
     showview=true;
    }
       
}