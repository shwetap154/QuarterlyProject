/* Name          :    ZTS_EU_SalesCallController.
* Description   :    Controller for a New Call page(SalesCallDetails).
                :    Controller for Call Details page(ZTS_EU_ViewSalesCallDetails).
                :    New Call page is used to enter details like Call Activity Date, Call Objective
                :    which gets stored in Call object and a Call is Created.
                :    After Call creation user is redirected to ViewSalesCallDetails page.
                :    Here the user can add attendees, colleagues, follow up activities, discussion
                :    and production adoption profile for the Call. 
                :    Employee Call Credit -Whenever a user is added as a colleague if there is any 
                :    active account positionfor the user it gets displayed in the dropdown 'Account Position'. 
                :    Employee Call Credit gets created by default with the active Account position the user selects.
                :    Product Adoption Profile - The Widget for product Adoption Profile enables the user to 
                :    add data for each attendee for product adoption.
* Author        :    Teresa

Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
12/17/2013       Sunil                    Created
03/20/2014       Akanksha                 Modified
05/20/2014       Teresa                   Modified
05/28/2014       Pankaj                   Modified
09/30/2014       Ilirjana                 Moved inner class wrapProdBarrior to new apex class.
12/09/2014       Shefali                  Modified for Call Owner field
04/14/2015       Shefali                  Modified for hiding 14 days warning pop up in case of Canada(INC0268017)
05/18/2015       Shreyas                  Modified the code to remove the MD relationship between BI and CP and replace it with a junction object. 
12/29/2020       Aritra                   Modified code to show Survey alert prompt for AUS and NZ market while creating and submitting Account Call(SC-004984)
01/26/2021       Aritra                   Modified code to add null checking on Account and account market for calls added from Calls and Calendar tab(SC-008346)
**************************************************************************************/
public with sharing class ZTS_EU_SalesCallController{
    /*****************************************
    VARIABLES
    ******************************************/
    public string ownerName{get;set;} // Shefali 09 Dec 2014
    public Boolean ownerFlag{get;set;}// Shefali 09 Dec 2014
    public Call__c call{get;set;}
    public String  address{get; set;}
    public String selectedop{get;set;}
    public String title{get;set;}   
    public Id loggedInUserId {get;set;}
    public List<Attendee__c> attendeeList{get;set;} 
    public List<ZTS_EU_Colleague__c> colleagueList{get;set;}
    //public List<ZTS_EU_Objective_Call_Association__c> objctvCallAssoList;
    //public List<ZTS_EU_Account_Action_Plan__c> actionPlanList{get;set;}
    public List<attendeerWrapper> attendeeWraList{get;set;}
    Public List<attendeerWrapper> colleagueWraList{get;set;}
    Public List<attendeerWrapper> objectiveCallAssociationWraList{get;set;}
    public List<AccountContactRole> accConRoleList;
    public String attendeeRemoveId{get;set;}
    public String colleagueRemoveId{get;set;}
    public Id discRemoveId{get;set;}
    public String discAttId{get;set;}
    public String productRemoveId{get;set;}
    public String keyMsgRemoveId{get;set;}
    public String sDropRemoveId{get;set;}
    public String aapRemoveId{get;set;}
    public List<Product_Metrics__c> productList{get;set;}
    public List<Key_Message_Discussions__c> keyMsgList = new List<Key_Message_Discussions__c>();
    //public List<Sample_Drop__c> sampleDropList{get;set;}
   // public List<Key_Message_Discussions__c> kMsgList{get;set;}
    public Map<String,String> attendeeMap = new Map<String,String>();
    public List<Product_Metrics__c> productAddList; 
    public List<Attendee__c> attendeeAddList; 
    //public List<Sample_Drop__c> sDropAddList; 
    public List<Key_Message_Discussions__c> kMsgUpdateList; 
     public Map<Id, List<Key_Message_Discussions__c>> mapKeyMsg = new Map<Id, List<Key_Message_Discussions__c>>(); 
     public boolean shwSubmitError{get;set;}
     public boolean shwDeldiscsnError{get;set;}
     public boolean showdiscussion{get;set;}
     public boolean hidediscussion{get;set;}
     public boolean showview{get;set;}
     public String attendeeid{get;set;}
     public String accid{get;set;}
     public boolean showErr{get;set;}
     public String callAccountMarket{get;set;}
    public map<Id,List<CampaignMemberStatus>> campaignIdCampMemStatusObjListMap = new map<Id,List<CampaignMemberStatus>>();
    public List<CampaignMemberStatus> CampMemStatList = new List<CampaignMemberStatus>();
    
    public Integer attendeecount;
    public String startDate = '';
    public String startTime = '';
    public String startDateTime = '';
    
    //Added By Vineet for SC-003151 
    public Datetime mydate1;
    public String sdate1 = '';
    public Datetime mydate2;
    public String sdate2 = '';
    
    //Added By Aritra for SC-004984     
    public boolean showsurveyprompt{get;set;}   
    public boolean isAccountCall;   
    public boolean ismarketSurveyEnabled{get;set;}  
    public string surveyalertmessage {get;set;} 
    //public map<String,String> marketMessageMap = new map<String,String>();
    
    //public datetime callStartDateTime = new datetime();
    public final String COMPLETED_STATUS{get;set;}{COMPLETED_STATUS = 'Completed';}    
    public final String NEW_STATUS{get;set;}{NEW_STATUS = 'Planned';}
    List<Call__c> lstCall = new List<Call__c>();
    
    public List<CampaignMember> campaignMemberList{get;set;}
    public List<CampaignMember> campaignMemberAddList ;
    public List<Task> followUpActivitiesList{get;set;}
    public String followUpActivityRemoveId{get;set;}
    public Task taskObj{get; set;}{taskObj = new Task();}
    public boolean addFollowUpSection{get;set;}{addFollowUpSection = false;}
    public List<ZTS_EU_Discussion__c> listdiscc{get;set;}
    public List<SelectOption> subtypelist{get;set;}
    public List<ZTS_EU_Account_Position__c> accposlist{get;set;}
    public String forceid{get;set;}
    public String name{get;set;}
    public List<ZTS_EU_Employee_Call_Credit__c> lstEmpCallCredit{get;set;}
    public List<String> empIdList = new List<String>();
    
    //Added by Pankaj Mishra
    public String attConID {get; set;}  
    public List<wrapProdBarrior> wrapPbList {get; set;} 
    public List<selectOption> options = new List<selectOption>();
    public List<selectOption> optionCompetitor = new List<selectOption>();
    public List<selectOption> optionBrandIndication = new List<selectOption>();
    public integer selIndex{get; set;}
    public List<ZTS_EU_Product_Adoption_Profile__c> lstProAdoPro{get;set;}
    public List<ZTS_EU_Product_Adoption_Profile__c> finalList = new List<ZTS_EU_Product_Adoption_Profile__c>();
    public integer brandsCnt{get; set;}
    public boolean conClicked{get; set;}
	public Map<String, Boolean>subtypeMandatoryMap{get;private set;}//TPDEV-1266
    Public List<ZTS_EU_Discussion__c> EUdiscuss{get;set;}
    Public List<ZTS_EU_Discussion__c> EUFinaldiscuss{get;set;}
    Public Map<Id,List<ZTS_EU_Discussion__c>> mapDiscuss{get;set;}
    Public Id id{get;set;}
    public Map<String, ZTS_EU_Discussion__c> discussionItemMap {get;set;}//TPDEV-775
    public List<ZTS_EU_Discussion__c> discList {get;set;}//TPDEV-775
     //Added by Bimba Ravi
    public String userMarket = '';
    /*Added by Bimba Ravi for the new CLAR field
    * agreed to purchase.
    */
    public Boolean getIsMarketFromCLAR() {
        
        //Get logged in user details.
        Boolean isMarketFromCLAR = false;




        List<MarketGeoMapping__c> csList = MarketGeoMapping__c.getAll().values();

        for(MarketGeoMapping__c cs : csList ){

            if(cs.Geo__c == 'CLAR' && cs.Name == userMarket){
                isMarketFromCLAR = true;
                break;
            }
        }
            
        return isMarketFromCLAR;       
    }
    
    public String userProfileName {
        get {
            return [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId()
                    ].Profile.Name;
        }
    }
    public boolean callEditForUser{get;set;}
    
    
    public Void accountChange()
    {
        address = '';
        if(call.ID == NULL)
        {
            getPreviousCallObjectives();
        }
    }
    //Create the Address picklist based on an account's address. 
    public  List<SelectOption> addressList{
        get{
            
            if(addressList == null){ 
                addressList = new  List<SelectOption>();
            }
            if(call.ZTS_EU_Account__c != Null && call.id == null){ 
                List<Address__c> addressDetailList = new List<Address__c>();
                addressDetailList = [select id,ZTS_EU_City__c,ZTS_EU_Street__c,ZTS_EU_State_County__c,ZTS_EU_Account__c,ZTS_EU_Primary_Address__c  from Address__c where ZTS_EU_Account__c =: call.ZTS_EU_Account__c ORDER BY ZTS_EU_Primary_Address__c DESC];
                addressList = new  List<SelectOption>();           
                //addressList.add(new selectOption('None', 'None'));                                           
                for(Address__c a : addressDetailList){ 
                                           
                    String str = a.ZTS_EU_Street__c != Null ?a.ZTS_EU_Street__c+', ':'';
                    str+= a.ZTS_EU_City__c!= Null ?a.ZTS_EU_City__c+', ':'';
                    str+= a.ZTS_EU_State_County__c!= Null ?a.ZTS_EU_State_County__c: null;                                            
                    addressList.add(new SelectOption(a.id, str));
              
                }
                if((address == NULL || Address == '') && addressDetailList.size()>0 )
                {
                    address = addressDetailList[0].ID;
                }          
            }
            else if(call.ZTS_EU_Account__c != Null && call.id != null && call.ZTS_EU_Address__c!= null){ 
               
                List<Address__c> addressDetailList1 = new List<Address__c>();
                addressDetailList1 = [select id,ZTS_EU_City__c,ZTS_EU_Street__c,ZTS_EU_State_County__c,ZTS_EU_Account__c,ZTS_EU_Primary_Address__c  from Address__c where ZTS_EU_Account__c =: call.ZTS_EU_Account__c];           
                addressList = new  List<SelectOption>();
                addressList.add(new selectOption(call.ZTS_EU_Address__c, call.ZTS_EU_SelectedAdress__c));   
                                                        
               for(Address__c a : addressDetailList1){                                            
                    String str = a.ZTS_EU_Street__c != Null ?a.ZTS_EU_Street__c+', ':'';
                    str+= a.ZTS_EU_City__c!= Null ?a.ZTS_EU_City__c+', ':'';
                    str+= a.ZTS_EU_State_County__c!= Null ?a.ZTS_EU_State_County__c: null;
                   
                    System.debug('Address String ******>'+str);
                     System.debug('Selected Address  ******>'+call.ZTS_EU_SelectedAdress__c);
                    if(str != call.ZTS_EU_SelectedAdress__c){
                        addressList.add(new SelectOption(a.id, str));
                    }
              
                }
                if(address == NULL || Address == '')
                {
                        address=call.ZTS_EU_Address__c;
                }
                        
            }        
        return addressList;
      
         
        }set;
    }
     //Create the Title picklist 
    public  List<SelectOption> titleList{
        get{
            
            if(titleList== null){        
                titleList= new  List<SelectOption>();
            }
            if(call.id == null){                                                       
                                                              
                titleList.add(new SelectOption('Account Call', 'Account Call'));
                titleList.add(new SelectOption('Meeting', 'Meeting'));           
                     
            }
            else if( call.id != null && call.name == 'Account Call'){                
                          
                 titleList.add(new selectOption(call.name , call.name));
                 titleList.add(new selectOption('Meeting' , 'Meeting'));                                        
                        
            }
            else if(call.id != null && call.name == 'Meeting'){                
                          
                 titleList.add(new selectOption(call.name , call.name));
                 titleList.add(new selectOption('Account Call' , 'Account Call'));                                        
                        
            }          
        return titleList;
      
         
        }set;
    }
    
    //Populate city based on the selected address
    public String city{
         get{
              String cityFormula = '';
             if(address != Null && address != 'None' && address != ''){                 
                Address__c add = [select id,ZTS_EU_City__c  from Address__c where id =:address];                 
                 cityFormula = add.ZTS_EU_City__c;
             }
             else if(call.ZTS_EU_City__c != null){
                cityFormula = call.ZTS_EU_City__c;
             }
             return cityFormula;
         } set;
    
    }

     /***********
        * Method name  : ZTS_EU_SalesCallController
        * Description  : Get the details of call record.
        * Return Type  : None.
        * Parameters   : ApexPages.StandardController.
    ***********/
    public ZTS_EU_SalesCallController(ApexPages.StandardController controller) {
       discussionItemMap = new Map<String, ZTS_EU_Discussion__c>();//TPDEV-775
        discList = new List<ZTS_EU_Discussion__c>();//TPDEV-775
        brandsCnt = 0;
        conClicked = false;
        String createdById;
        List<String> forceidfields= new List<String>();
        listdiscc=new List<ZTS_EU_Discussion__c>();
        subtypelist = new List<SelectOption>();
        attendeeid='';
        showdiscussion=false;
        hidediscussion=false;
        showview=true;
        showErr =false;
        name=Userinfo.getFirstName()+' '+Userinfo.getLastName();
        call = (Call__c)controller.getrecord();
        //Added by Aritra (SC-004984)
        isAccountCall = false;  
        ismarketSurveyEnabled =false;   
        showsurveyprompt = false;
         //TPDEV-1266
        List<Call_Subtype_and_Local_Subtype__mdt> mandatorySubtypes = Call_Subtype_and_Local_Subtype__mdt.getAll().values(); 
        subtypeMandatoryMap = new Map<String, Boolean>();
        for (Call_Subtype_and_Local_Subtype__mdt subtypeRecord : mandatorySubtypes) {
            subtypeMandatoryMap.put(subtypeRecord.Sub_Type__c, subtypeRecord.Call_SubType_Mandatory__c);
        }
        if (String.isEmpty(call.ZTS_EU_Account__c) && ApexPages.currentPage().getParameters().get('accountId') != 'undefined')
        {
            call.ZTS_EU_Account__c = ApexPages.currentPage().getParameters().get('accountId');
        }

       id = call.id;
        mapDiscuss = new Map<Id,List<ZTS_EU_Discussion__c>>();

       loggedInUserId = UserInfo.getUserId();
       userMarket = [Select Id,ZTS_EU_Market__c from User WHERE Id =: loggedInUserId].ZTS_EU_Market__c;

       shwSubmitError=false;
       system.debug('-----callid-----'+call.id);
       selectedop = call.ZTS_EU_Sub_Type__c;
       //selectedLoSubType = call.ZTS_EU_Local_Subtype__c;
       //List <Call__c> listcall= [SELECT Id,Completed_Calls__c,ZTS_EU_Account__r.ZTS_EU_Market__c,CreatedById,ZTS_EU_Agree_To_Purchase__c,ZTS_EU_Historical_Owner_Name__c ,ZTS_EU_Call_Owner__c,ZTS_EU_Call_Owner__r.name from Call__c where Id=:call.id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];--Commented out above query (by Aritra for SC-004984)
       List <Call__c> listcall= [SELECT Id,ZTS_EU_Sub_Type__c,Completed_Calls__c,ZTS_EU_Account__r.ZTS_EU_Market__c,CreatedById,ZTS_EU_Agree_To_Purchase__c,ZTS_EU_Historical_Owner_Name__c ,ZTS_EU_Call_Owner__c,ZTS_EU_Call_Owner__r.name from Call__c where Id=:call.id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']; //Added ZTS_EU_Sub_Type__c in above SOQL query (by Aritra for SC-004984)
       if(listcall.size() > 0){
             //Shefali 03 Dec 2014 
            ownerName = listcall[0].ZTS_EU_Call_Owner__r.name;
            callAccountMarket = listcall[0].ZTS_EU_Account__r.ZTS_EU_Market__c;
             system.debug('ownerName####'+ownerName);
             system.debug('historicName####'+listcall[0].ZTS_EU_Historical_Owner_Name__c);
             if(ownerName == null  || ownerName ==''){
                ownerName = listcall[0].ZTS_EU_Historical_Owner_Name__c;
             }
             if(listcall[0].ZTS_EU_Historical_Owner_Name__c!=null){
                ownerFlag =true;
                system.debug('inside history@@@###');
             }else{
                ownerFlag = false;
                
             } 
         //Shefali 04/14/2015 (INC0268017)
             if(userProfileName.contains('CA')){
                showErr = false;
             }else{
                showErr = true;
             }
             //EOC Shefali
           createdById=listcall[0].CreatedById;
            //selectedop = listcall[0].ZTS_EU_Sub_Type__c;
           if(loggedInUserId == createdById || userProfileName.contains('Admin') || loggedInUserId == listcall[0].ZTS_EU_Call_Owner__c)
             callEditForUser = true;
            else
             callEditForUser = false;
            //Code Added by Aritra (SC-004984)    
            if(listcall[0].ZTS_EU_Sub_Type__c == 'Account Call') {isAccountCall = true;} 
            String market = System.Label.ZTS_EU_COVID_19_Survey_Markets; 
            List<String> marketList = market.split(';'); 
            system.debug('---marketList--'+marketList);  
            for(String s: marketList)    
               {    
                   if(s == callAccountMarket){ismarketSurveyEnabled=true;}  
               }    
                   if((isAccountCall==true)&&(ismarketSurveyEnabled==true)) 
                   {    
                        showsurveyprompt = true; 
                   }    
               system.debug('isAccountCall---->'+isAccountCall);    
               system.debug('ismarketSurveyEnabled---->'+ismarketSurveyEnabled);    
               system.debug('showsurveyprompt---->'+showsurveyprompt);   
               //End of code - Code Added by Aritra (SC-004984)          
       }else {
           callEditForUser = true;
           //Code Added by Aritra (SC-004984) 
           system.debug('--Inside Else--'); 
           system.debug('--Account Id--'+call.ZTS_EU_Account__c);
           if(call.ZTS_EU_Account__c<>null) //26-Jan-21:Added this Null checking on Account in call for call created from Call tab or Calendar - by Aritra (SC-008346)
           {
               List<Account> acc = [Select Id,ZTS_EU_Market__c from Account where Id =: call.ZTS_EU_Account__c];    
               if(acc[0].ZTS_EU_Market__c<>null) //26-Jan-21:Added this Null checking on Account market - by Aritra (SC-008346)
               {
                   string mkt = acc[0].ZTS_EU_Market__c;    
                   system.debug('---Market---'+mkt);    
                   String market = System.Label.ZTS_EU_COVID_19_Survey_Markets;    
                   List<String> marketList = market.split(';'); 
                   system.debug('---marketList--'+marketList);  
                   for(String s: marketList)    
                   {    
                       if(s == mkt){ismarketSurveyEnabled=true;}    
                   }    
                   system.debug('--survey enabled --'+ismarketSurveyEnabled);
               }
               //End of code - Code Added by Aritra (SC-004984)
           }
       }

       if(!callEditForUser)
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,System.Label.ZTS_EU_You_do_not_have_access_to_edit_this_call));
       system.debug('-----accid-----'+call.ZTS_EU_Account__c);
      // accposlist =[SELECT Id,ZTS_EU_Employee__c,ZTS_US_Field_ForceID__c,ZTS_EU_Account__c from //ZTS_EU_Account_Position__c where ZTS_EU_Account__c=:call.Account__c and ZTS_EU_Employee__c=:name];

       Schema.DescribeFieldResult callSubtype = Call__c.ZTS_EU_Sub_Type__c.getDescribe();

        List<Schema.PicklistEntry> callSubtypeValues = callSubtype.getPicklistValues();
        for (Schema.PicklistEntry a : callSubtypeValues)
        { 
            //subtypelist.add(new SelectOption(a.getLabel(), a.getValue()));
            subtypelist.add(new SelectOption(a.getValue(), a.getLabel())); 
        }  
              
                 
     //  }
       if(ApexPages.currentPage().getParameters().containsKey('evt13')) {
           String startTimeTemp = ApexPages.currentPage().getParameters().get('evt13');
           startTime = EncodingUtil.urlDecode(startTimeTemp,'UTF-8');
           system.debug('startTime is: '+startTime);
           
           //call.ZTS_EU_Start_Date_Time__c = ApexPages.currentPage().getParameters().get('evt13');
           
       }
       if(ApexPages.currentPage().getParameters().containsKey('evt4')) {
           String startDateTemp = ApexPages.currentPage().getParameters().get('evt4');
           startDate = EncodingUtil.urlDecode(startDateTemp,'UTF-8');
           system.debug('startDate is: '+startDate);
       }
       if(startTime != null && startTime != '' && startDate != null && startDate != ''){
           startDateTime = startDate + ' ' + startTime;
           system.debug('startDateTime is: '+startDateTime);
           Datetime callStartDateTime = Datetime.parse(startDateTime);
           system.debug('callStartDateTime  is: '+callStartDateTime);
       
       call.ZTS_EU_Start_Date_Time__c = callStartDateTime;
       call.ZTS_EU_End_Date_Time__c = callStartDateTime.addHours(1);
       }else if(startDate != null && startDate != ''){
           startDateTime = startDate ;
           system.debug('startDateTime is111: '+startDateTime);
           Date callStartDate = Date.parse(startDateTime);
           Datetime callStartDateTime = Datetime.newInstance(callStartDate.year(),callStartDate.month(),callStartDate.day()).addHours(9);
           system.debug('callStartDateTime  is111: '+callStartDateTime);
       
       call.ZTS_EU_Start_Date_Time__c = callStartDateTime;
       call.ZTS_EU_End_Date_Time__c = callStartDateTime.addHours(1);
       } 
       else if( String.isBlank(startDate) && String.isBlank(call.Id)) {
            Date callStartDate = System.today();
            Datetime callStartDateTime = Datetime.newInstance(callStartDate.year(),callStartDate.month(),callStartDate.day()).addHours(9);
            system.debug('callStartDateTime  is222: '+callStartDateTime);
       
            call.ZTS_EU_Start_Date_Time__c = callStartDateTime;
            call.ZTS_EU_End_Date_Time__c = callStartDateTime.addHours(1);
        }
       
       if(call.Id != Null){
       
            showAttendee();
            //showProduct();
            //showKeyMessage(); 
            //showSampleDrop();
            showFollowUpActivities();
            if(system.now()<call.ZTS_EU_Start_Date_Time__c)
                shwSubmitError=true;
       }
       else
       {
           getPreviousCallObjectives();
       }
    }

 /***********Added by pankaj
    * Method name  : productAdaptation.
    * Description  : Show Product Adoptation Profile.
                   : Create dropdown list of select options for brands, barriers and competitor products
    * Return Type  : Pagereference.
    * Parameters   : None.
***********/   
   public pageReference productAdaptation(){
   brandsCnt=0; 
conClicked = true;   
         wrapPbList = new list<wrapProdBarrior>();
         system.debug('*****param attConID*****'+attConID);
        lstProAdoPro = new List<ZTS_EU_Product_Adoption_Profile__c>();
        list<Attendee__c>  attRec = [SELECT ZTS_EU_Contact__c FROM Attendee__c where ZTS_EU_Contact__c =: attConID AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        system.debug('*****attRec*****'+attRec);
        if(!attRec.isempty()){ 
            lstProAdoPro  = [select id, LastModifiedDate,ZTS_EU_Contact__c,ZTS_EU_Brand_Indication__r.name,zts_eu_brand_indication__c , ZTS_EU_Product_Barrier__r.name,ZTS_EU_Competitor_Product__r.name,ZTS_EU_Usage__c from ZTS_EU_Product_Adoption_Profile__c where ZTS_EU_Contact__c =: attRec[0].ZTS_EU_Contact__c];
        }   
        List<SelectOption> brands = new List<SelectOption>();
        
        List<SelectOption> barriers = new List<SelectOption>();
         barriers.add(new Selectoption('','--None--'));
        List<SelectOption> comps = new List<SelectOption>();
         comps.add(new Selectoption('','--None--'));
       system.debug('*****lstProAdoPro*****'+lstProAdoPro);
       if(lstProAdoPro.size() > 0){
            Set<Id> brandIds = new Set<id>();
            for(ZTS_EU_Product_Adoption_Profile__c pap: lstProAdoPro){
                brandIds.add(pap.ZTS_EU_Brand_Indication__c);
            }
            brandsCnt = brandIds.size();    
                list<ZTS_EU_Brand_Indication__c> pbList = [select id,name from ZTS_EU_Brand_Indication__c where id in : brandIds order by name limit 50000];
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+pbList.size());
                brands.clear();
                
                if(pbList.size()>0){
                    for(ZTS_EU_Brand_Indication__c br : pbList){
                        brands.add(new Selectoption(br.Id,br.name));
                    }
                           
                    System.debug('>>>>>>>>>>brands>>>>>>>>>>>>>>'+brands.size());
                    System.debug('>>>>>>>>>>brands>>>>>>>>>>>>>>'+brands);
                } 
                
                comps.clear();
                comps.add(new Selectoption('','--None--'));
                /*
                List<ZTS_EU_Competitor_Product__c> lstcomps = [Select id,name,ZTS_EU_Brand_Indication__c from ZTS_EU_Competitor_Product__c where ZTS_EU_Brand_Indication__c in:brandIds];
                Map<Id,List<Selectoption>> mpComps = new Map<Id,List<SelectOption>>();
                List<SelectOption> compsLst = new List<SelectOption>{new SelectOption('','--None--')};
                for(ZTS_EU_Competitor_Product__C cmp: lstcomps){
                    
                    if(mpComps.get(cmp.ZTS_EU_Brand_Indication__c) == null){
                        
                        mpComps.put(cmp.ZTS_EU_Brand_Indication__c,new List<SelectOption>{new SelectOption(cmp.id,cmp.name)});
                    }
                    else{
                    
                    mpComps.get(cmp.ZTS_EU_Brand_Indication__c).add(new Selectoption(cmp.id,cmp.name));
                    }
                }
                */
                List<Competitor_and_BI_Association__c> lstcomps = [Select id,name,ZTS_EU_Brand_Indication__c, ZTS_EU_Competitor_Product__c, ZTS_EU_Competitor_Product__r.Name
                                                                  from Competitor_and_BI_Association__c where ZTS_EU_Brand_Indication__c in:brandIds];
                Map<Id,List<Selectoption>> mpComps = new Map<Id,List<SelectOption>>();
                for(Competitor_and_BI_Association__c cmp: lstcomps){
                    
                    if(mpComps.get(cmp.ZTS_EU_Brand_Indication__c) == null){
                        
                        mpComps.put(cmp.ZTS_EU_Brand_Indication__c,new List<SelectOption>{new SelectOption(cmp.ZTS_EU_Competitor_Product__c,cmp.ZTS_EU_Competitor_Product__r.name)});
                    }
                    else{
                    
                    mpComps.get(cmp.ZTS_EU_Brand_Indication__c).add(new Selectoption(cmp.ZTS_EU_Competitor_Product__c,cmp.ZTS_EU_Competitor_Product__r.name));
                    }
                }
                
                
                
                barriers.clear();
                 barriers.add(new Selectoption('','--None--'));
                Map<Id,List<Selectoption>> mpbarriers = new Map<Id,List<SelectOption>>();
                List<ZTS_EU_Product_Barrier__c> lstBarriers = [Select id,name,ZTS_EU_Brand_Indication__c from ZTS_EU_Product_Barrier__c where ZTS_EU_Brand_Indication__c in:brandIds order by name];
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstBarriers.size());
                if(lstBarriers.size()>0){
                List<SelectOption> barriersLst = new List<SelectOption>{new SelectOption('','--None--')};
                for(ZTS_EU_Product_Barrier__c zpb: lstBarriers){
                    
                    if(mpbarriers.get(zpb.ZTS_EU_Brand_Indication__c) == null){
                        mpbarriers.put(zpb.ZTS_EU_Brand_Indication__c,new List<SelectOption>{new SelectOption(zpb.id,zpb.name)});
                    }
                    else{
                        mpbarriers.get(zpb.ZTS_EU_Brand_Indication__c).add(new Selectoption(zpb.id,zpb.name));
                    }
                }
                
                
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+barriers.size());
                }
                    for(ZTS_EU_Product_Adoption_Profile__c pA : lstProAdoPro){
                       if(mpBarriers!= null && mpBarriers.containskey(pA.ZTS_EU_Brand_Indication__c)){
                        mpBarriers.get(pA.ZTS_EU_Brand_Indication__c).add(new Selectoption('','--None--'));
                        mpBarriers.get(pA.ZTS_EU_Brand_Indication__c).sort(); 
                        }
                        else{
                            mpBarriers.put(pA.ZTS_EU_Brand_Indication__c, new List<Selectoption> {new Selectoption('','--None--')});
                        }
                        if(mpcomps!= null && mpcomps.containskey(pA.ZTS_EU_Brand_Indication__c)){
                        mpcomps.get(pA.ZTS_EU_Brand_Indication__c).add(new Selectoption('','--None--'));
                        mpcomps.get(pA.ZTS_EU_Brand_Indication__c).sort(); 
                        }
                        else
                         mpcomps.put(pA.ZTS_EU_Brand_Indication__c,new List<SelectOption>{new Selectoption('','--None--')});
                           
                         system.debug('brandssize****'+brands.size());             
                        wrapPbList.add(new wrapProdBarrior(pA,pA.ZTS_EU_Product_Barrier__c,pA.ZTS_EU_Competitor_Product__c,pA.ZTS_EU_Brand_Indication__c, wrapPbList.size(),mpBarriers.get(pA.ZTS_EU_Brand_Indication__c),brands,mpcomps.get(pA.ZTS_EU_Brand_Indication__c),true));
                    }
               }
               System.debug('>>>>>>>>>>>>>>>>'+wrapPbList);
               System.debug('>>>>>>>>>>>>>>>>'+wrapPbList.size());
            
       return null;     
   }
    /***********Added by pankaj
    * Method name  : productAdaptationChange.
    * Description  : On change of brand Indication this method is called
    * Return Type  : Pagereference.
    * Parameters   : None.
***********/   

   public void productAdaptationChange(){
    
        if(selIndex != NULL){
            wrapProdBarrior wpb = wrapPbList[selIndex];
                
                List<SelectOption> barriers = new List<SelectOption>();
                List<SelectOption> comps = new List<SelectOption>();
                comps.clear();
                /*
                List<ZTS_EU_Competitor_Product__C> lstcomps = [Select id,name from ZTS_EU_Competitor_Product__c where ZTS_EU_Brand_Indication__c =: wpb.brandIndication order by name];
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstcomps.size());
                comps.add(new Selectoption('','--None--'));
                if(lstcomps.size()>0){
                    
                    for(ZTS_EU_Competitor_Product__C cp:lstComps){
                        comps.add(new Selectoption(cp.id,cp.Name));
                    }
                    System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps.size());  
                    System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps);
                }
                */
                List<Competitor_and_BI_Association__c> lstcomps = [Select id,name,ZTS_EU_Brand_Indication__c, ZTS_EU_Competitor_Product__c, ZTS_EU_Competitor_Product__r.Name
                                                                  from Competitor_and_BI_Association__c where ZTS_EU_Brand_Indication__c  =: wpb.brandIndication order by name];
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstcomps.size());
                comps.add(new Selectoption('','--None--'));
                if(lstcomps.size()>0){
                    
                    for(Competitor_and_BI_Association__c cp:lstComps){
                        comps.add(new Selectoption(cp.ZTS_EU_Competitor_Product__c,cp.ZTS_EU_Competitor_Product__r.Name));
                    }
                    System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps.size());  
                    System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps);
                }
                
                barriers.clear();
                List<ZTS_EU_Product_Barrier__c> lstBarriers = [Select id,name from ZTS_EU_Product_Barrier__c where ZTS_EU_Brand_Indication__c =: wpb.brandIndication order by name];
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstBarriers.size());
                barriers.add(new Selectoption('','--None--'));
                if(lstBarriers.size()>0){
                    
                for(ZTS_EU_Product_Barrier__c br:lstBarriers){
                    barriers.add(new Selectoption(br.id,br.Name));
                }
                System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+barriers.size());
                }
                wpb.barriers = barriers;
                wpb.Comps = comps;
                    
        }
   }
        
/***********Added by pankaj
    * Method name  : addBrandIndication.
    * Description  : Method used to add Product Adoption Profile for attendee on click of 'Add Product Adoption Profile' link
    * Return Type  : Pagereference.
    * Parameters   : None.
***********/   
   public void addBrandIndication()
    {
       string selBrandId = '';
        string selCompId='';
        string selBarrierId = '';
        
        List<SelectOption> brands = new List<SelectOption>();
        List<SelectOption> barriers = new List<SelectOption>();
        List<SelectOption> comps = new List<SelectOption>();
        Set<Id> brIndicationID = new Set<Id>();
        
        for(wrapProdBarrior wpb : wrapPbList){
            brIndicationID.add(wpb.brandIndication);
        }
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+brIndicationID.size());
        
        list<ZTS_EU_Brand_Indication__c> pbList = [select id,name from ZTS_EU_Brand_Indication__c where id not in : brIndicationID order by name limit 50000];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+pbList.size());
        brands.clear();
        
        if(pbList.size()>0){
            for(ZTS_EU_Brand_Indication__c br : pbList){
                if(!brIndicationID.contains(br.Id))
                    brands.add(new Selectoption(br.Id,br.name));
            }
            brandsCnt = brands.size();
                        
            System.debug('>>>>>>>>>>brands>>>>>>>>>>>>>>'+brands.size());
            System.debug('>>>>>>>>>>brands>>>>>>>>>>>>>>'+brands);
            selBrandId = brands[0].getValue();
        } 
        
        comps.clear();
        /*
        List<ZTS_EU_Competitor_Product__C> lstcomps = [Select id,name,ZTS_EU_Brand_Indication__c from ZTS_EU_Competitor_Product__c where ZTS_EU_Brand_Indication__c =:selBrandId order by name];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstcomps.size());
        comps.add(new Selectoption('','--None--'));
        if(lstcomps.size()>0){
            
            for(ZTS_EU_Competitor_Product__C cp:lstComps){
                comps.add(new Selectoption(cp.id,cp.Name));
            }
            System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps.size());
            System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps);
            
            selCompId = comps[0].getValue();
        }
        */
        List<Competitor_and_BI_Association__c> lstcomps = [Select id,name,ZTS_EU_Brand_Indication__c, ZTS_EU_Competitor_Product__c, ZTS_EU_Competitor_Product__r.Name
                                                           from Competitor_and_BI_Association__c where ZTS_EU_Brand_Indication__c  =:selBrandId order by name];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstcomps.size());
        comps.add(new Selectoption('','--None--'));
        if(lstcomps.size()>0){
            
            for(Competitor_and_BI_Association__c cp:lstComps){
                comps.add(new Selectoption(cp.ZTS_EU_Competitor_Product__c,cp.ZTS_EU_Competitor_Product__r.Name));
            }
            System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps.size());
            System.debug('>>>>>>>>>>comps>>>>>>>>>>>>>>'+comps);
            
            selCompId = comps[0].getValue();
        }
                
        
        
        barriers.clear();
        List<ZTS_EU_Product_Barrier__c> lstBarriers = [Select id,name,ZTS_EU_Brand_Indication__c from ZTS_EU_Product_Barrier__c where ZTS_EU_Brand_Indication__c =:selBrandId order by name];
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+lstBarriers.size());
        barriers.add(new Selectoption('','--None--'));
        if(lstBarriers.size()>0){
            
        for(ZTS_EU_Product_Barrier__c br:lstBarriers){
            barriers.add(new Selectoption(br.id,br.Name));
        }
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>'+barriers.size());
        selBarrierId = barriers[0].getValue();
        }
        
        wrapPbList.add(new wrapProdBarrior(new ZTS_EU_Product_Adoption_Profile__c(),selBarrierId,selCompId,selBrandId,wrapPbList.size(),barriers,brands,comps,false));
        
    }  
   public void cancelBrandIndication()
    {
        if(selIndex != null){
            wrapPbList.remove(selIndex);
            integer i = 0;
            for(wrapProdBarrior WC :  wrapPbList){
                wc.index = i;
                i++;
            }
        }
        
    } 
    /***********Added by pankaj
    * Method name  : addNewPAP.
    * Description  : Method used to save Product Adoption Profile for attendee on click of 'Add Product Adoption Profile' link
    * Return Type  : Pagereference.
    * Parameters   : None.
***********/ 
    public void addNewPAP()
    {
        
        wrapProdBarrior wc = wrapPbList[selIndex];
        finalList.clear();
        if(WC.pALis.id != null){
            ZTS_EU_Product_Adoption_Profile__c newPAP   = new ZTS_EU_Product_Adoption_Profile__c(id = WC.pALis.id);
            newPAP.ZTS_EU_Product_Barrier__c            = WC.prodBarrier;
            newPAP.ZTS_EU_Competitor_Product__c         = WC.prodCompetitor;
            newPAP.ZTS_EU_Brand_Indication__c           = WC.brandIndication;
            newPAP.ZTS_EU_Usage__c                      = WC.pALis.ZTS_EU_Usage__c;
            finalList.add(newPAP); 
                system.debug('****ID is not null****');
                system.debug('****ID is null****'+WC.pALis.id);
                system.debug('****ID is null finalList****'+finalList);
            }  
            else {
                ZTS_EU_Product_Adoption_Profile__c newPAP   = new ZTS_EU_Product_Adoption_Profile__c();
                newPAP.ZTS_EU_Product_Barrier__c            = WC.prodBarrier;
                newPAP.ZTS_EU_Competitor_Product__c         = WC.prodCompetitor;
                newPAP.ZTS_EU_Brand_Indication__c           = WC.brandIndication;
                newPAP.ZTS_EU_Usage__c                      = WC.pALis.ZTS_EU_Usage__c;
                newPAP.ZTS_EU_Contact__c                    = attConID;
                finalList.add(newPAP); 
                system.debug('****ID is null****');
                system.debug('****ID is finalList****'+finalList);
            }
            if(!finalList.isempty()){
                upsert finalList;
            }
            //wrapPbList[selIndex].pALis = finalList[0];
            productAdaptation(); 
            //cancelBrandIndication();
            //productAdaptationChange();
            
                
                    
        }
        
/***********Added by pankaj
    * Method name  : displaySave.
    * Description  : Method used to display the save button against each record in UI for Product Adoption Profile
    * Return Type  : Pagereference.
    * Parameters   : None.
***********/ 
         public void displaySave()
         {
            
            if(selIndex != null){
                wrapPbList[selIndex].displaySave = false;
            }
            
            
         }
        
    
    
    
    
     /***********
        * Method name  : saveCall
        * Description  : Insert or Update a call and redirect to the associated account, if no errors.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    
    public PageReference saveCall() {
        system.debug('Name Inside*****'+call.name); 
        system.debug('*********************************update the call*111*****************************'+call.Id);
        system.debug('*********************************update the call******************************'+title);
        PageReference pg=null;
        calculateEndDateTime();
        /*************************Update the Call*************************************************************/
       // if(call.id != Null && title != Null){
            if(call.id != Null ){
            system.debug('*********************************update the call******************************');
            Call__c updateCall = new Call__c(id=call.id);

            updateCall.ZTS_EU_Account__c = call.ZTS_EU_Account__c;
            //updateCall.Name = title; -- SC-003913 (Commented by Avik to stop populating call name with call id)
            updateCall.Name = call.Name;
            updateCall.ZTS_EU_Start_Date_Time__c = call.ZTS_EU_Start_Date_Time__c;
            //updateCall.ZTS_EU_Sub_Type__c = call.ZTS_EU_Sub_Type__c;
            updateCall.ZTS_EU_End_Date_Time__c = call.ZTS_EU_End_Date_Time__c;
            updateCall.ZTS_EU_Status__c = call.ZTS_EU_Status__c;
            updateCall.ZTS_EU_Call_Objectives__c = call.ZTS_EU_Call_Objectives__c;
            updateCall.ZTS_EU_Additional_Notes__c = call.ZTS_EU_Additional_Notes__c;
            updateCall.ZTS_EU_Next_Step__c = call.ZTS_EU_Next_Step__c;
            updateCall.ZTS_EU_Duration__c = call.ZTS_EU_Duration__c;
            updateCall.ZTS_EU_Next_Call_Date__c=call.ZTS_EU_Next_Call_Date__c;
            updateCall.ZTS_EU_Sub_Type__c = call.ZTS_EU_Sub_Type__c;
            updateCall.ZTS_EU_Local_Subtype__c = call.ZTS_EU_Local_Subtype__c;
            updateCall.ZTS_EU_Expense_Value__c = call.ZTS_EU_Expense_Value__c;
            updateCall.ZTS_EU_Expense_Type__c = call.ZTS_EU_Expense_Type__c;
            updateCall.ZTS_EU_Expense_Comments__c = call.ZTS_EU_Expense_Comments__c;
            updateCall.ZTS_EU_Call_Owner__c = call.ZTS_EU_Call_Owner__c; //Shefali 03 Dec 2014
           // updateCall.ZTS_EU_Unique_Call_Number__c = call.ZTS_EU_Unique_Call_Number__c;
           updateCall.ZTS_EU_Agree_To_Purchase__c = call.ZTS_EU_Agree_To_Purchase__c;
            //TPDEV-346
            if(updateCall.ZTS_EU_Next_Call_Date__c==null)
            {
                updateCall.ZTS_EU_Next_Call_Type__c=null;
            }
            else{
                updateCall.ZTS_EU_Next_Call_Type__c=call.ZTS_EU_Next_Call_Type__c;
            }     
            
            system.debug('Name*****'+call.name);
            system.debug('Name*****'+call.ZTS_EU_Status__c);
            
            // Added by Vineet Singh SC-003151 For restricting User to change Activity date to Future's date Post Submission of Call
            If (call.ZTS_EU_Status__c=='Completed'){ 
                DateTime dT = call.ZTS_EU_Start_Date_Time__c;
                myDate1 = datetime.newinstance(dT.year(), dT.month(), dT.day(),dt.hour(),dt.minute(),dt.second());
                sdate1 = String.valueOf(myDate1);

                DateTime dT1 = call.ZTS_EU_Submitted_Date__c;
                if( dT1 != null ){
                    myDate2 = datetime.newinstance(dT1.year(), dT1.month(), dT1.day(),dt1.hour(),dt1.minute(),dt1.second());
                    sdate2 = String.valueOf(myDate2); 
                }
                else {
                    myDate2 = System.today();
                    sdate2 = String.valueOf(myDate2);
                }
                
                if((sdate1>sdate2) && (sdate2 !=NULL)) 
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Activity Date cannot be changed to Future date post Completion of Call'));
                    return null;
                }
            }
            
            try{
                update updateCall;
                /*Call__C call1 = [select id,Completed_Calls__c from Call__C where id=:updateCall.id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
                System.debug('updateCall.ZTS_EU_Sub_Type__c------'+updateCall.ZTS_EU_Sub_Type__c);
                System.debug('call.ZTS_EU_Sub_Type__c------'+call.ZTS_EU_Sub_Type__c);
                if((updateCall.ZTS_EU_Sub_Type__c != call.ZTS_EU_Sub_Type__c))
                {
                    string sd;
                    integer day;
                    integer month;
                    integer year ;
                    date mydate;
                    string name;
                    DateTime dt;
                    dt = updateCall.ZTS_EU_Start_Date_Time__c;
                    sd = string.valueOf(dt.date());
                    mydate = Date.valueOf(sd);
                    day = myDate.day();
                    month = myDate.month();
                    year = myDate.year();
                    name = updateCall.ZTS_EU_Sub_Type__c + ' - ' + day + '/' + month + '/' + year;
                    System.debug('call1.Completed_Calls__c------'+call1.Completed_Calls__c);
                    Event eve = [Select Id, Subject,CallRecordId__c from Event where CallRecordId__c =: updateCall.id and isChild = false AND ZTS_EU_Market__c != 'United States'];
                    System.debug('eve'+eve.Subject + eve.id);                   
                    if(updateCall.ZTS_EU_Status__c == 'Planned')
                    {
                        eve.Subject = '(Planned)' + ' ' + name;
                    }
                    if(updateCall.ZTS_EU_Status__c == 'Completed')
                    {
                        eve.Subject =  '(Completed)' +' ' + name;
                    }
                    
                    List<Event> eventsToUpdate = new List<Event>();
                    eventsToUpdate.add(eve);
                    update eventsToUpdate;
                    System.debug('eventsToUpdate---Subject'+eventsToUpdate[0].Subject);
                }*/
                pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
                pg.getParameters().put('retURL',updateCall.ZTS_EU_Account__c);
                pg.getParameters().put('id',updateCall.Id);
                pg.getParameters().put('accountId',updateCall.ZTS_EU_Account__c);
                pg.setRedirect(true);
                return  pg;


            }
            catch(DmlException e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
            







        }
        /*************************Insert a Call*************************************************************/
        else{        
            Call__c newCall = new Call__c();
            
            newCall.ZTS_EU_Account__c = call.ZTS_EU_Account__c;
            if(title != Null)
            //updateCall.Name = title; -- SC-003913 (Commented by Avik to stop populating call name with call id)
            newCall.Name = call.Name;
            newCall.ZTS_EU_Start_Date_Time__c = call.ZTS_EU_Start_Date_Time__c;
            //newCall.ZTS_EU_Sub_Type__c = call.ZTS_EU_Sub_Type__c;
            newCall.ZTS_EU_Sub_Type__c = call.ZTS_EU_Sub_Type__c;
            newCall.ZTS_EU_Local_Subtype__c = call.ZTS_EU_Local_Subtype__c;
            newCall.ZTS_EU_End_Date_Time__c = call.ZTS_EU_End_Date_Time__c;
            newCall.ZTS_EU_Status__c = NEW_STATUS;
            newCall.ZTS_EU_Call_Objectives__c = call.ZTS_EU_Call_Objectives__c;
            newCall.ZTS_EU_Additional_Notes__c = call.ZTS_EU_Additional_Notes__c;
            newCall.ZTS_EU_Next_Step__c = call.ZTS_EU_Next_Step__c;
            newCall.ZTS_EU_Duration__c = call.ZTS_EU_Duration__c;
            newCall.ZTS_EU_Next_Call_Date__c=call.ZTS_EU_Next_Call_Date__c;
            newCall.ZTS_EU_Expense_Value__c = call.ZTS_EU_Expense_Value__c;
            newCall.ZTS_EU_Expense_Type__c = call.ZTS_EU_Expense_Type__c;
            newCall.ZTS_EU_Expense_Comments__c = call.ZTS_EU_Expense_Comments__c;
            newCall.ZTS_EU_Agree_To_Purchase__c = call.ZTS_EU_Agree_To_Purchase__c;
           // newCall.ZTS_EU_Call_Owner__c = call.ZTS_EU_Call_Owner__c; //Shefali 03 Dec 2014
         //   newCall.ZTS_EU_Unique_Call_Number__c = call.ZTS_EU_Unique_Call_Number__c;
         //   //   TPDEV-346
            if(newCall.ZTS_EU_Next_Call_Date__c==null)
            {
                newCall.ZTS_EU_Next_Call_Type__c=null;
            }
            else{
                newCall.ZTS_EU_Next_Call_Type__c=call.ZTS_EU_Next_Call_Type__c;
            }
            system.debug ('>>>>>>>>>.ADDRESS>>>>>>>>>' + address);
            if(address!= Null && address!= 'None' && address != ''){
                newCall.ZTS_EU_Address__c = address;
                //newCall.ZTS_EU_SelectedAdress__c = buildAddress();
            }
            system.debug('Name*****'+call.name);
            try{
                insert newCall;
                pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
                pg.getParameters().put('retURL',newCall.ZTS_EU_Account__c);
                pg.getParameters().put('id',newCall.Id);
                pg.getParameters().put('accountId',newCall.ZTS_EU_Account__c);
                pg.setRedirect(true);
                return  pg;
            }
            catch(DmlException e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }





        }
        return null;
       
    }
     /***********
        * Method name  : cancelCall
        * Description  : redirect to related account detail page.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference cancelCall() {
        PageReference pg = new PageReference('/' + call.ZTS_EU_Account__c);
        return pg;       
    }
    /***********
        * Method name  : editCall
        * Description  : redirect to edit detail page if no errors.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference editCall() {      
      if(call.Id != Null && call.ZTS_EU_Account__c != Null){
          PageReference pg=new PageReference('/apex/SalesCall');
          pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
          pg.getParameters().put('id',call.Id);
          pg.setRedirect(true);
          return  pg;
      }    
      return  Null;      
    }
    /***********
        * Method name  : updateCallDetails
        * Description  : redirect to the related account.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference updateCallDetails(){ 
      PageReference pg = null;
      kMsgUpdateList = new List<Key_Message_Discussions__c>(); 
      productAddList = new List<Product_Metrics__c>();
      attendeeAddList = new List<Attendee__c>();
      campaignMemberAddList = new List<CampaignMember>(); 
      lstEmpCallCredit = new List<ZTS_EU_Employee_Call_Credit__c>();
      //sDropAddList = new List<Sample_Drop__c>();   
      /*if(productWrapperList.size()>0){
          for(productWrapper pw : productWrapperList){
              productAddList.add(pw.pMetricsObj);
              for(Key_Message_Discussions__c key : pw.childKeyMsg){
                kMsgUpdateList.add(key);
              }
          }           
               
      }*/   
      if(attendeeWraList.size()>0){
          for(attendeerWrapper aw : attendeeWraList){
            system.debug('************************aw****************'+aw);
            system.debug('************************aw.selectedAcctPos****************'+aw.selectedAcctPos);
            attendeeAddList.add(aw.attendeeObj);
            for(CampaignMember cm : campaignMemberList){
                if(cm.ContactId == aw.attendeeObj.ZTS_EU_Contact__c && cm.CampaignId == aw.attendeeObj.ZTS_EU_Related_Campaign__c){
                    cm.Status = aw.attendeeObj.ZTS_EU_Campaign_Response__c;
                    campaignMemberAddList.add(cm);
                }
            }
          }           
      }
       /* below code is used to add Employee Call Credit against colleague having active account position */
      if(colleagueWraList.size()>0){
        List<Period> FYdates= [SELECT FiscalYearSettings.Name,StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY];
        Date currentFiscalYearEnddate;
        Date currentFiscalYearStartdate;

        for(attendeerWrapper aw : colleagueWraList){
            system.debug('************************aw****************'+aw);
            system.debug('************************aw.selectedAcctPos****************'+aw.selectedAcctPos);
            if(FYdates.size()>0 && !FYdates.isEmpty()){
                currentFiscalYearEnddate = FYdates[0].EndDate;
                currentFiscalYearStartdate = FYdates[0].StartDate;
            }
            if(aw.colleagueobj.ZTS_EU_User__c != null && aw.selectedAcctPos!= null ){
                ZTS_EU_Employee_Call_Credit__c eccObj = new ZTS_EU_Employee_Call_Credit__c();
                system.debug('**************aw.empCreditId***********'+aw.empCreditId);
                if(aw.empCreditId != null && aw.empCreditId != ''){
                    eccObj.Id = aw.empCreditId;
                    eccObj.ZTS_EU_Account_Position__c = aw.selectedAcctPos;
                    eccObj.ZTS_EU_Call__c = aw.colleagueobj.ZTS_EU_Call__c;
                    eccObj.ZTS_EU_FY_StartDate__c = currentFiscalYearStartdate;
                    eccObj.ZTS_EU_FY_EndDate__c = currentFiscalYearEnddate;
                    //SC-003323-defect-prabhat
                    eccObj.Call_End_Date__c = aw.colleagueobj.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c;
                } else {
                    eccObj.ZTS_EU_Account_Position__c = aw.selectedAcctPos;
                    eccObj.ZTS_EU_Employee_Colleague__c = aw.colleagueobj.Id;
                    eccObj.ZTS_EU_Call__c = aw.colleagueobj.ZTS_EU_Call__c;
                    eccObj.ZTS_EU_FY_StartDate__c = currentFiscalYearStartdate;
                    eccObj.ZTS_EU_FY_EndDate__c = currentFiscalYearEnddate;
                    //SC-003323-defect-prabhat
                    eccObj.Call_End_Date__c = aw.colleagueobj.ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c;
                }
                lstEmpCallCredit.add(eccObj);
            }
          }           
      }
      try{
            update productAddList;
            update kMsgUpdateList;
            update attendeeAddList;
            update campaignMemberAddList;
            upsert lstEmpCallCredit;
            //update sDropAddList; 
            pg = new PageReference('/' + call.ZTS_EU_Account__c);
        }
      catch(DmlException e){      
          system.debug('Exception'+e);
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
      }
      return  pg; 
    }
    
     /***********
        * Method name  : saveAndSubmit
        * Description  : updates the status field on Call record to Completed.
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/
    public PageReference saveAndSubmit(){        
       if(call.id != Null){
           updateCallDetails();
           lstCall = [Select name,Completed_Calls__c,c.ZTS_EU_Historical_Owner_Name__c,c.ZTS_EU_Agree_To_Purchase__c,c.ZTS_EU_Status__c,c.ZTS_EU_Address__c,c.ZTS_EU_Next_Step__c,c.ZTS_EU_Additional_Notes__c,c.ZTS_EU_SelectedAdress__c,c.ZTS_EU_Sub_Type__c,c.ZTS_EU_Local_Subtype__c,c.ZTS_EU_Expense_Value__c,c.ZTS_EU_Expense_Type__c,c.ZTS_EU_Expense_Comments__c,c.ZTS_EU_Unique_Call_Number__c,c.ZTS_EU_Next_Call_Date__c,c.Id, c.ZTS_EU_Account__c,c.ZTS_EU_End_Date_Time__c, c.ZTS_EU_Duration__c,c.ZTS_EU_Submitted_Date__c,ZTS_EU_Call_Owner__c,c.ZTS_EU_Next_Call_Type__c From Call__c c where c.Id=:call.Id AND c.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
           //Changes done by Mayukh Deb for SC-002827
           List<Attendee__c> listatt2 = [SELECT Id,Name,ZTS_EU_call__c,ZTS_EU_of_Discussion_items__c FROM Attendee__c where ZTS_EU_Call__c =:call.Id AND ZTS_EU_of_Discussion_items__c=0  AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
           if(listatt2.size()>0){
               system.debug('@@when list is checked@@');
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.ZTS_EU_Call_Attendee_Discussion_Item));
           }
        else{                    
           List<ZTS_EU_Discussion__c>listdis = [SELECT Id,Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Product__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__r.ZTS_EU_call__c =:call.Id AND ZTS_EU_Market__c != 'United States'];
           if(listdis.size()>0){
           try{
               if(lstCall != null && lstCall.size()>0){
                   if(lstCall[0].ZTS_EU_Next_Call_Date__c<>null&&lstCall[0].ZTS_EU_Status__c<>COMPLETED_STATUS){
                       Call__c oCall=lstCall[0].clone(false,true);
                       oCall.ZTS_EU_Next_Step__c=null;
                       oCall.ZTS_EU_Next_Call_Date__c=null;
                       oCall.ZTS_EU_Additional_Notes__c=null;
                       oCall.ZTS_EU_Start_Date_Time__c=lstCall[0].ZTS_EU_Next_Call_Date__c;
                       oCall.ZTS_EU_End_Date_Time__c = lstCall[0].ZTS_EU_Next_Call_Date__c.addMinutes(30);//Added by Shefali for DEF-000823
                       //oCall.ZTS_EU_Call_Objectives__c=lstCall[0].ZTS_EU_Next_Step__c;   // Duplicated 
                       oCall.ZTS_EU_Call_Objectives__c=lstCall[0].ZTS_EU_Next_Step__c;
                       oCall.ZTS_EU_Status__c=NEW_STATUS;
                       oCall.ZTS_EU_Sub_Type__c=lstCall[0].ZTS_EU_Next_Call_Type__c;    //TPDEV-346
                       oCall.ZTS_EU_Next_Call_Type__c=null;                             //TPDEV-346
                       insert oCall;
                   }
                   lstCall[0].ZTS_EU_Status__c = COMPLETED_STATUS;
                  //lstCall[0].ZTS_EU_Submitted_Date__c = date.today(); //Original line commented by Parvez
                  //Code added by Parvez
                  lstCall[0].ZTS_EU_Submitted_Date__c = system.now();
                  //EOC Parvez
               }
               
               update lstCall;
               // Sohil Shah(CloudSense) DEF-001522 internal field for counting no of completed calls on account positions
               //Commented by Laxmikanth: Implemented on the trigger
             /* List<Call__c> callList = new List<Call__C>();
              List<ZTS_EU_Employee_Call_Credit__c> eccListToUpdate = new List<ZTS_EU_Employee_Call_Credit__c>();
              callList = [Select id, ZTS_EU_Status__c,ZTS_EU_End_Date_Time__c,ZTS_EU_Submitted_Date__c,(Select Id, ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c,Call_End_Date__c, ZTS_EU_Call__r.ZTS_EU_Status__c, Is_Call_status_Completed__c from Employee_Call_Credits__r) from Call__C where id=: call.id AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States']; 
              // Srinivas K(CloudSense) updated Is_Call_Completed_In_Current_FY__c field on ECC as part of the defect SC-002109
              String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name; 
              
              String callSubmitYear = string.valueOf((Date.valueOf(callList[0].ZTS_EU_Submitted_Date__c)).year());
                for(ZTS_EU_Employee_Call_Credit__c ecc : callList[0].Employee_Call_Credits__r)
                {
                    ecc.Is_Call_status_Completed__c = true;
                    //ecc.Call_End_Date__c = callList[0].ZTS_EU_End_Date_Time__c;
                    if(currentFiscalYear == callSubmitYear){
                         ecc.Is_Call_Completed_In_Current_FY__c=true;
                    }
                    eccListToUpdate.add(ecc);
                }
                Database.update(eccListToUpdate,false);
                */
                
                // EOC Sohil Shah DEF-001522
               PageReference pg=new PageReference('/' + call.ZTS_EU_Account__c);     
               return  pg; 
             }
               catch(DmlException e){
                  system.debug('Exception'+e);
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
              }
            } else {
                system.debug('in else');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.ZTS_EU_Please_make_sure_the_Call_has_at_least_one_Attendee_and_that_every_Attend));
            }
           }
       } 
       return null;
    }
    
    /***********
        * Method name  : showAttendee
        * Description  : Method used to display attendee list and colleague list that are addied against a call
        * Return Type  : Pagereference.
        * Parameters   : None.
    ***********/

    public Void showAttendee(){
        if(call.Id != Null){
            set<Id> conIdSet = new set<Id>();
            set<Id> campIdSet = new set<Id>();
            map<Id,List<CampaignMember>> mapAttIdLstCampMem = new map<Id,List<CampaignMember>>();
            List<SelectOption> relCamOption = new List<SelectOption> ();
            set<Id> accIdSet = new set<Id>();
            map<Id,ZTS_EU_Affiliations__c> accContAffMap = new Map<ID,ZTS_EU_Affiliations__c>();
           // List<CampaignMemberStatus> CampMemStatList = new List<CampaignMemberStatus>();
            Map<String,String> empAcctPosMap = new Map<String,String>();
            Map<String,String> empEmpCrMap = new Map<String,String>();
            attendeeWraList = new List<attendeerWrapper>();
            colleagueWraList = new List<attendeerWrapper>();
            objectiveCallAssociationWraList=new List<attendeerWrapper>();
            
           attendeeList = [select id,name,ZTS_EU_call__c, ZTS_EU_Contact__r.Account.Name, ZTS_EU_Contact__r.FirstName, ZTS_EU_Contact__r.Lastname, ZTS_EU_Contact__r.AccountId,ZTS_EU_Contact__c,ZTS_EU_Represents_Account__c,ZTS_EU_Contact_Profession__c,ZTS_EU_Related_Campaign__c,ZTS_EU_Campaign_Response__c,ZTS_EU_Employee__c from Attendee__c where ZTS_EU_call__c=:call.Id AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
            //SC-003323-defect-prabhat
              colleagueList =[select id,Name,ZTS_EU_Call__c,ZTS_EU_Call__r.ZTS_EU_Account__c,ZTS_EU_Call__r.ZTS_EU_End_Date_Time__c,ZTS_EU_User__c,ZTS_EU_User_Email__c from ZTS_EU_Colleague__c where ZTS_EU_Call__c=:call.Id AND ZTS_EU_Market__c != 'United States'];
           
           //objctvCallAssoList =[Select Id,  ZTS_EU_Call__c , ZTS_EU_Objective__c,ZTS_EU_Objective__r.Name from ZTS_EU_Objective_Call_Association__c where ZTS_EU_Call__c =:call.Id ];
        
                               
            for(Attendee__c att : attendeeList){
                if(att.ZTS_EU_Contact__c!= null){
                    conIdSet.add(att.ZTS_EU_Contact__c);
                }
                if(att.ZTS_EU_Represents_Account__c !=null){
                    accIdSet.add(att.ZTS_EU_Represents_Account__c);
                }
            }
             
            for(ZTS_EU_Affiliations__c acaff : [Select ZTS_EU_Job_Function__c,ZTS_EU_Contact__c,ZTS_EU_Account__c from ZTS_EU_Affiliations__c where ZTS_EU_Contact__c in :conIdSet and ZTS_EU_Account__c in:accIdSet AND ZTS_EU_Market_from_Parent__c != 'United States' ORDER BY CreatedDate ASC]){
                if(!accContAffMap.containsKey(acaff.ZTS_EU_Contact__c)){
                    accContAffMap.put(acaff.ZTS_EU_Contact__c, acaff);
                }
            }
            
            system.debug('@@@@@@conIdSet is: '+conIdSet);
                campaignMemberList = [Select c.ContactId, c.Campaign.IsActive, c.Campaign.Name, c.Status, c.CampaignId From CampaignMember c 
                                        where c.ContactId in :conIdSet and c.Campaign.IsActive = true AND ZTS_EU_Market__c != 'United States'];
            system.debug('@@@@@@campaignMemberList is: '+campaignMemberList);
            /*
            for(CampaignMember campaignMemberObj : [Select c.ContactId, c.Campaign.IsActive, c.Campaign.Name, c.CampaignId From CampaignMember c 
                                                        where c.ContactId in :conIdSet and c.Campaign.IsActive = true]){
                campIdSet.add(campaignMemberObj.CampaignId);                                        
            }   
            */  
            //accConRoleList = [select accountID,Account.Name,contactID from AccountContactRole where accountID = : call.ZTS_EU_Account__c];
            
            //this is added for dynamic
            
            for(CampaignMember campaignMemberObj : campaignMemberList){
                campIdSet.add(campaignMemberObj.CampaignId);                                        
            }   
            
            
            CampMemStatList = [Select Label, IsDefault, Id, HasResponded, CampaignId From CampaignMemberStatus Where CampaignId IN: campIdSet];
            
            for(CampaignMemberStatus cmpgnMemStatusObj : CampMemStatList) {
                List<CampaignMemberStatus> campMemStatusList = campaignIdCampMemStatusObjListMap.get(cmpgnMemStatusObj.CampaignId);
                if(campMemStatusList == null) {
                    campMemStatusList = new List<CampaignMemberStatus>();
                }
                campMemStatusList.add(cmpgnMemStatusObj);
                campaignIdCampMemStatusObjListMap.put(cmpgnMemStatusObj.CampaignId,campMemStatusList);
                
            }
            
            
            for(Attendee__c att : attendeeList){
                mapAttIdLstCampMem.put(att.id,new List<CampaignMember>());
                if(att.ZTS_EU_Contact__c!= null){
                    for(CampaignMember cm : campaignMemberList){
                    system.debug('@@@@@@cm is: '+cm );
                    system.debug('@@@@@@att.ZTS_EU_Contact__c is: '+att.ZTS_EU_Contact__c );
                    system.debug('@@@@@@cm.ContactId is: '+cm.ContactId );
                    
                        if(cm.ContactId != null && att.ZTS_EU_Contact__c == cm.ContactId){
                                mapAttIdLstCampMem.get(att.id).add(cm);
                                system.debug('@@@@@@mapAttIdLstCampMem.get(att.id) is: '+mapAttIdLstCampMem.get(att.id) );
                                system.debug('@@@@@@mapAttIdLstCampMem.get(att.id) size is: '+mapAttIdLstCampMem.get(att.id).size() );
                        }
                        //system.debug('@@@@@@mapAttIdLstCampMem.get(att.id) is: '+mapAttIdLstCampMem.get(att.id) );
                    }
                    //system.debug('@@@@@@campaignMemberList for att is: '+mapAttIdLstCampMem.get(att.id));
                }   
            }
            system.debug('@@@@@@campaignMemberList is: '+campaignMemberList);
           
            for (ZTS_EU_Colleague__c col: colleagueList){
                empIdList.add(col.Id);
            }
             List<ZTS_EU_Employee_Call_Credit__c> eccObjSelected = [select Id,ZTS_EU_Account_Position__r.ZTS_EU_Position__c, ZTS_EU_Account_Position__r.ZTS_EU_Position__r.Name, ZTS_EU_Employee_Colleague__c FROM ZTS_EU_Employee_Call_Credit__c WHERE ZTS_EU_Employee_Colleague__c IN: empIdList AND ZTS_EU_Market__c != 'United States'];
            for(ZTS_EU_Employee_Call_Credit__c eccr :eccObjSelected){
                empAcctPosMap.put(eccr.ZTS_EU_Employee_Colleague__c,eccr.ZTS_EU_Account_Position__c);
                empEmpCrMap.put(eccr.ZTS_EU_Employee_Colleague__c,eccr.Id);
            }
            for (ZTS_EU_Colleague__c col: colleagueList){
            attendeerWrapper attWar = new attendeerWrapper(); 
            attWar.colleagueobj = col;
             if(empAcctPosMap.get(col.id) != null){
                   attWar.selectedAcctPos = empAcctPosMap.get(col.id);
                    attWar.empCreditId = empEmpCrMap.get(col.id);
                }
             colleagueWraList.add(attWar);
             
            //Added by Ajay for hide discussion functionality
            }
            //campaign,discussion items and product can be created at a call submission.
            for(ZTS_EU_Discussion__c dis :  [select id,name,ZTS_EU_Call_Attendee__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Product__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c IN:attendeeList AND ZTS_EU_Market__c != 'United States']){ 
                //TPDEV-775
                //discussionItemMap-composite key of three lookup fields which can identify a Discussion as Unique.
                if(!discussionItemMap.containsKey(dis.ZTS_EU_Campaign__c+''+dis.ZTS_EU_Product__c+''+dis.ZTS_EU_Discussion_Items__c)){
                    discussionItemMap.put(dis.ZTS_EU_Campaign__c+''+dis.ZTS_EU_Product__c+''+dis.ZTS_EU_Discussion_Items__c,dis);
                }
				//TPDEV-775 end
                    System.debug('discussions:::::::::::::'+dis);               
                    if(mapDiscuss.containsKey(dis.ZTS_EU_Call_Attendee__c)){                   
                        List<ZTS_EU_Discussion__c> discussionList =  mapDiscuss.get(dis.ZTS_EU_Call_Attendee__c);
                        discussionList.add(dis);
                        mapDiscuss.put(dis.ZTS_EU_Call_Attendee__c, discussionList);                                        
                    } else {
                        List<ZTS_EU_Discussion__c> discussionList = new List<ZTS_EU_Discussion__c>();
                        discussionList.add(dis);
                        mapDiscuss.put(dis.ZTS_EU_Call_Attendee__c, discussionList);
                    }                
                }
            discList.addAll(discussionItemMap.values()); //TPDEV-775
            for(Attendee__c att : attendeeList){               
                attendeerWrapper attWar = new attendeerWrapper();               
                attWar.attendeeObj = att;
                if(mapDiscuss != null && (!mapDiscuss.isEmpty()) && mapDiscuss.containskey(att.id))
                {
                    attWar.EUdiscuss.addall(mapDiscuss.get(att.id));
                    System.debug('DDDDDDDDDDDDD'+attWar);
                }
            //Added by Ajay for hide discussion functionality till here    
                attWar.aConAff = accContAffMap.get(att.ZTS_EU_Contact__c);
                
                if(att.ZTS_EU_Contact__r.AccountId != null){
                    attWar.accountRep.add(new selectOption(att.ZTS_EU_Contact__r.AccountId, att.ZTS_EU_Contact__r.Account.Name));
                }
                
                if(att.ZTS_EU_Contact__c != null && mapAttIdLstCampMem.get(att.id) != null){
                    for(CampaignMember cm : mapAttIdLstCampMem.get(att.id)){
                        attWar.relCamOption.add(new selectOption(cm.CampaignId, cm.Campaign.Name));
                    }
                }
                
                
               // EuDiscuss = [select id,name,ZTS_EU_Call_Attendee__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c IN:attendeeList AND ZTS_EU_Market__c != 'United States'];
                
                
                
                system.debug('@@@@@@attWar.relCamOption is: '+attWar.relCamOption);
                
                attendeeWraList.add(attWar);
                
                
                system.debug('@@@@@@attendeeWraList is: '+attendeeWraList);
                
            }
            
           /* List<Id> objectivesId =new List<ID>();
            if(!objctvCallAssoList.isEmpty()){
                for(ZTS_EU_Objective_Call_Association__c objtClAsso : objctvCallAssoList){
                    objectivesId.add(objtClAsso.ZTS_EU_Objective__c);
                } 
            }
            
            List<ZTS_EU_Account_Action_Plan_Objectives__c> actionPlanObjectivesList =[select Id, ZTS_EU_Account_Action_Plan__c from ZTS_EU_Account_Action_Plan_Objectives__c where Id IN: objectivesId]; 
             system.debug('####ObjectivesAssociation'+actionPlanObjectivesList);
             if(!objctvCallAssoList.isEmpty()){
                for(ZTS_EU_Objective_Call_Association__c obCallAsso :objctvCallAssoList){
                    attendeerWrapper attWar = new attendeerWrapper();
                    attWar.objtvCallAssoObj = obCallAsso;
                    objectiveCallAssociationWraList.add(attWar);
                    
                    system.debug('####objectiveCallAssociationWraList####'+objectiveCallAssociationWraList);
                }
            
            }*/
            
            
        }
           
    }

    /***********
        * Method name  : removeAttendee
        * Description  : Remove the attendee from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeAttendee(){
        /*attendeecount = -1;
        for(Integer i=0; i<attendeeWraList.size();i++){
            if(attendeeWraList[i].attendeeObj.Id == attendeeRemoveId){
                attendeecount = i;
                break;
            }
        }
        if(attendeecount != -1){
            attendeeWraList.remove(attendeecount);
        }*/
        if(attendeeRemoveId!= null){
            Attendee__c attDelete = new Attendee__c(id=attendeeRemoveId);
            
            try{
                delete attDelete;
                
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-removeAttendee');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.getParameters().put('accountId',call.ZTS_EU_Account__c);
         pg.setRedirect(true);
         return  pg;
    
    }
    
    /***********
        * Method name  : removeColleague
        * Description  : Remove the attendee from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeColleague(){
        /*attendeecount = -1;
        for(Integer i=0; i<attendeeWraList.size();i++){
            if(attendeeWraList[i].attendeeObj.Id == attendeeRemoveId){
                attendeecount = i;
                break;
            }
        }
        if(attendeecount != -1){
            attendeeWraList.remove(attendeecount);
        }*/
        if(colleagueRemoveId!= null){
            
            ZTS_EU_Colleague__c colDelete = new ZTS_EU_Colleague__c(id=colleagueRemoveId);
            try{
                
                delete colDelete;
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-removeColleague');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.getParameters().put('accountId',call.ZTS_EU_Account__c);
         pg.setRedirect(true);
         return  pg;
    
    }
    
    
    /***********
        * Method name  : removeAAP
        * Description  : Remove the AAP from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
        * Author       : Shefali vinchurkar
    ***********/
    /*
    public PageReference removeAAP(){
        
        if(aapRemoveId!= null){
            
            ZTS_EU_Objective_Call_Association__c aapObjtDelete = new ZTS_EU_Objective_Call_Association__c(id=aapRemoveId);
            try{
                
                delete aapObjtDelete;
            }catch(Exception e){
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.setRedirect(true);
         return  pg; 
         return null;
    
    }*/

    /***********
        * Method name  : validate_discdel
        * Description  : Validate discussion item counts.
        * Return Type  : Boolean.
        * Parameters   : ID.
        * Author        : Mayukh Deb.
        * done as part of SC-002827
    ***********/    
    public boolean validate_discdel(id discAttId){
        shwDeldiscsnError = false;
        system.debug('deleted discussion attendee'+discAttId);
        List<Attendee__c> disc_count = [SELECT ZTS_EU_of_Discussion_items__c FROM Attendee__c where ZTS_EU_Call__c =:call.Id AND Id=:discAttId AND ZTS_EU_call__r.ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'];
        if(disc_count.size()>0){
            integer cnt= Integer.valueOf(disc_count[0].ZTS_EU_of_Discussion_items__c);
          system.debug(cnt);
          if(cnt<=1)
          {
            system.debug('When cnt <1');
              shwDeldiscsnError= true;
          }
        }
        return shwDeldiscsnError;
    }    
    
    /***********
        * Method name  : removeDiscussionItem
        * Description  : Remove the DiscussionItem from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeDiscussionItem(){
        /*attendeecount = -1;
        for(Integer i=0; i<attendeeWraList.size();i++){
            if(attendeeWraList[i].attendeeObj.Id == attendeeRemoveId){
                attendeecount = i;
                break;
            }
        }
        if(attendeecount != -1){
            attendeeWraList.remove(attendeecount);
        }*/

        //Changes below are done by Mayukh Deb for SC-002827
        
         system.debug('Inside the discussion delete method'); 
         Boolean val_result;
        val_result = validate_discdel(discAttId);
        system.debug('val result '+ val_result);
         if (val_result==true)
         {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.Call_Attendee_Discussion_Item_Delete));
        
        }
        else
        {
            if(discRemoveId!= null){
                //ZTS_EU_Discussion__c discDelete = new ZTS_EU_Discussion__c(id=discRemoveId);
                List<ZTS_EU_Discussion__c> discDelete = [SELECT Id,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Product__c FROM ZTS_EU_Discussion__c WHERE (ZTS_EU_Campaign__c=:discRemoveId OR ZTS_EU_Discussion_Items__c=:discRemoveId OR ZTS_EU_Product__c=:discRemoveId)  AND ZTS_EU_Call_Attendee__r.ZTS_EU_call__c=:call.Id];
              try{
                  delete discDelete;
              }catch(Exception e){
                  ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-removeDiscussionItem');
                  system.debug('Exception'+e);
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
              }
            }
          PageReference pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
           pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
           pg.getParameters().put('id',call.Id);
           pg.getParameters().put('accountId',call.ZTS_EU_Account__c);
           pg.setRedirect(true);
           return  pg;
        }
         return null;
    }
  
    /***********
        * Method name  : deleteCall
        * Description  : Delete the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference deleteCall(){
        String callAccId = '';
        if(call.id != Null && call.ZTS_EU_Account__c != null){
            callAccId = call.ZTS_EU_Account__c;
            Call__c delCall = new Call__c(id= call.id);
            try{
                delete delCall;
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-deleteCall');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }        
        PageReference pg = new PageReference('/' + call.ZTS_EU_Account__c);
        return pg;
       }
       return null;
    }   
   
     //Teresa
   /***********
        * Method name  : showFollowUpActivities
        * Description  : Display the Activities list based on the Call.
        * Return Type  : None.
        * Parameters   : None.
    ***********/
    public void showFollowUpActivities(){
       followUpActivitiesList = [select id,Subject,Status,Priority,Owner.Name,ActivityDate from Task where WhatId =:call.Id];
       
    }
    
     /***********
        * Method name  : removeFollowUpActivities
        * Description  : Remove the FollowUpActivities from the Call.
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public PageReference removeFollowUpActivities(){
        if(followUpActivityRemoveId != null){
            Task followUpActObjDelete = new Task(id=followUpActivityRemoveId);
            try{
                delete followUpActObjDelete;
            }catch(Exception e){
                ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-removeFollowUpActivities');
                system.debug('Exception'+e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'' +e.getDMLMessage(0)));
            }
        }
         PageReference pg=new PageReference('/apex/ZTS_EU_ViewSalesCallDetails');
         pg.getParameters().put('retURL',call.ZTS_EU_Account__c);
         pg.getParameters().put('id',call.Id);
         pg.getParameters().put('accountId',call.ZTS_EU_Account__c);
         pg.setRedirect(true);
         return  pg;
    }
    
   public class attendeerWrapper{
        public Attendee__c attendeeObj{get;set;}
        public ZTS_EU_Affiliations__c aConAff{get;set;}
        public ZTS_EU_Colleague__c colleagueobj{get;set;}
       // public ZTS_EU_Objective_Call_Association__c objtvCallAssoObj{get;set;} // Added By Shefali
        public List<SelectOption> accountRep{get;set;}
        public String empCreditId{get;set;}
        public String selectedAcctPos{get;set;}
        public List<ZTS_EU_Discussion__c> EUdiscuss{get;set;}
        public List<SelectOption> empAcctPos{get{
            this.empAcctPos = new List<SelectOption>();
            system.debug('**********this.attendeeObj.ZTS_EU_Employee__c********'+this.colleagueobj.ZTS_EU_User__c);
            system.debug('**********this.colleagueobj.ZTS_EU_Call__r.ZTS_EU_Account__c********'+this.colleagueobj.ZTS_EU_Call__r.ZTS_EU_Account__c);
            List<ZTS_EU_Account_Position__c> listAcctPos = [SELECT Id, ZTS_EU_Account__c, ZTS_EU_Position__r.Name,ZTS_EU_Employee__c FROM ZTS_EU_Account_Position__c WHERE ZTS_EU_Position__r.ZTS_EU_Employee__c =: this.colleagueobj.ZTS_EU_User__c AND ZTS_EU_Account__c =: this.colleagueobj.ZTS_EU_Call__r.ZTS_EU_Account__c AND ZTS_EU_Is_Active__c = TRUE AND ZTS_EU_Market__c != 'United States'];
            system.debug('listAcctPos ==== ' + listAcctPos );
            for(ZTS_EU_Account_Position__c accPos : listAcctPos){
                this.empAcctPos.add(new SelectOption(accPos.Id, accPos.ZTS_EU_Position__r.Name));
             }
            system.debug('***************empAcctPos**********'+empAcctPos);
            return this.empAcctPos;
            }set;}
        public List<SelectOption> relCamOption{get;set;}
        public List<SelectOption> relCamRespOption {get{
            this.relCamRespOption = new List<SelectOption>();
            //List<CampaignMemberStatus> lstStat = campaignIdCampMemStatusObjListMap.get(this.attendeeObj.ZTS_EU_Related_Campaign__c);
            List<CampaignMemberStatus> lstStat = [Select Label, IsDefault, Id, HasResponded, CampaignId From CampaignMemberStatus Where CampaignId =: this.attendeeObj.ZTS_EU_Related_Campaign__c];
            this.relCamRespOption.add(new SelectOption('None', 'None'));
            for(CampaignMemberStatus cms : lstStat){
                this.relCamRespOption.add(new SelectOption(cms.label, cms.label));
            }
            
            return this.relCamRespOption; 
        } set;}
    
        public String selectedAttendee{get;set;} 
        public attendeerWrapper(){
            attendeeObj = new Attendee__c();
            aConAff = new ZTS_EU_Affiliations__c();
            colleagueobj = new ZTS_EU_Colleague__c();
            accountRep = new List<SelectOption>();
            relCamOption = new List<SelectOption>();
            relCamRespOption  = new List<SelectOption>();
            EUdiscuss = new List<ZTS_EU_Discussion__c>();
        }
    }
   /***********
        * Method name  : calculateEndDateTime

        * Description  : Method to calculate End date Time as per entered activity date and Duration values
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
   public void calculateEndDateTime()
    {
            system.debug(LoggingLevel.ERROR,'@@ date '+ Date.today());
            //call.ZTS_EU_End_Date_Time__c = Datetime.now();
            system.debug(LoggingLevel.ERROR,'#### start date '+ call.ZTS_EU_Duration__c);
            String str = '';
            if(call.ZTS_EU_Duration__c != NULL )
            {
               str = call.ZTS_EU_Duration__c; 
            }
            else
            {
                //str = '0.5 Hours';
            }
            
            List <String> strList = str.split(' ');
            String str1 = strList[0];
            str1 = str1.trim();
            Double minutes = Double.valueOf(str1) * 60; 
            if(call.ZTS_EU_Start_Date_Time__c != NULL || call.ZTS_EU_Duration__c == '--None--' )
            {
                //Integer minutes = Integer.valueOf(call.ZTS_EU_Duration__c);
                call.ZTS_EU_End_Date_Time__c = call.ZTS_EU_Start_Date_Time__c.addMinutes(Integer.valueOf(minutes));
            }
    }
    
    /***********
        * Method name  : getPreviousCallObjectives
        * Description  : Method to get Previous Call objectives 
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public void getPreviousCallObjectives()
    {
        if(call.ZTS_EU_Account__c != null)
        {
           List<Call__c> prevCallList = [SELECT ID, ZTS_EU_Agree_To_Purchase__c,Completed_Calls__c,ZTS_EU_Historical_Owner_Name__c,
                                            ZTS_EU_Call_Owner__c,ZTS_EU_Next_Step__c 
                                        FROM Call__c 
                                        WHERE CreatedByID = :UserInfo.getUserId() 
                                            AND ZTS_EU_Account__c = :call.ZTS_EU_Account__c 
                                            AND ZTS_EU_End_Date_Time__c != NULL
                                            AND ZTS_EU_Account__r.ZTS_EU_Market__c != 'United States'
                                            Order by ZTS_EU_End_Date_Time__c DESC LIMIT 1];
            
            if(prevCallList.size() > 0)
            {
                for(Call__c prevCall: prevCallList)
                {
                    call.ZTS_EU_Call_Objectives__c = prevCall.ZTS_EU_Next_Step__c;
                }    
            }
        }        
    }
   /***********
        * Method name  : saveTask
        * Description  : This method is used to save Task
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
    public pageReference  saveTask()
   {
       taskObj =  new Task(OwnerId = loggedInUserId,
                                       whatId = call.Id, 
                                       Subject = taskObj.subject, 
                                       priority = taskObj.Priority, 
                                       Status = taskObj.Status,
                                       ActivityDate = taskObj.ActivityDate
                                      );
       try
       {
           insert taskObj;
            taskObj = new Task(Subject='--Enter Subject--',Status = 'Not Started', Priority = 'Normal');
            showFollowUpActivities();
          
           
        }
       catch(Exception e)
       {
            ZTS_EU_Logger.error('NonDMLException : '+e.getMessage(), null, 'ZTS_EU_SalesCallController-saveTask');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Insert Failes:Contact'));
       }
       return null;
       }
     
     /***********
        * Method name  : addSectionToTask
        * Description  : This method is used to update whether the section for adding task needs to be displayed   
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
     public PageReference addSectionToTask(){
           if(addFollowUpSection)
                addFollowUpSection = false;
           else{
                taskObj = new Task(Subject='--Enter Subject--',Status = 'Not Started', Priority = 'Normal');
                addFollowUpSection = true;
           }
           return null;
      }
   /***********
        * Method name  : showDiscussionAF
        * Description  : This method is used to display discussion for each attendee
        * Return Type  : PageReference.
        * Parameters   : None.
    ***********/
   public void showDiscussionAF(){
        system.debug('--------AttendeeID-----'+attendeeid);
        listdiscc = [SELECT Id,Name,ZTS_EU_Call_Attendee__c,ZTS_EU_Campaign__c,ZTS_EU_Discussion_Items__c,ZTS_EU_Product__c from ZTS_EU_Discussion__c where ZTS_EU_Call_Attendee__c =:attendeeid AND ZTS_EU_Market__c != 'United States'];
        showdiscussion=true;
        hidediscussion=true;
       // showview=false;
        }
    
     /***********
        * Method name  : hideDiscussionAF
        * Description  : This method is used to hide discussion of the attendee and set the page rendering variables appropriately
        * Return Type  : PageReference.
        * Parameters   : None
    ***********/
    public void hideDiscussionAF(){
     hidediscussion=false;
     showdiscussion=false;
    // showview=true;
     }

     /***********
        * Method name  : redirect
        * Description  : This method is used to redirect to the US version of Sales Call
        * Return Type  : PageReference.
        * Parameters   : None
    ***********/
    public PageReference redirect()
    {
        //US Call not returned in query above
        // if( callAccountMarket == null )
        // {
        PageReference pr = new ApexPages.StandardController(call).view();
        Id currentId = (Id)ApexPages.CurrentPage().getparameters().get('id');
        if(userMarket == 'United States') { 
            pr.getParameters().put('nooverride', '1');
            pr.getParameters().put('id',currentId);
            pr.setRedirect(true);
            return pr; 
        }
        // }
        else
        {
            return null;
        }
        //Updated the redirect method to open the standard call record page with no-override for INTL markets too (SC-004726)
        //PageReference pr = new ApexPages.StandardController(call).view();
        //Id currentId = (Id)ApexPages.CurrentPage().getparameters().get('id');
        //pr.getParameters().put('nooverride', '1');
        //       pr.getParameters().put('id',currentId);
        //       pr.setRedirect(true);
        //       return pr; 
        // Above commented out by Morgan Marchese to fix Chromium Bug  
    }

    public PageReference redirectEditCloneNew()
    {   
        String checkMarket;     
        if( call.ZTS_EU_Account__c == null )
        {
            checkMarket = userMarket;
        }
        else 
        {
            checkMarket = [SELECT ZTS_EU_Market__c FROM Account WHERE Id = :call.ZTS_EU_Account__c].ZTS_EU_Market__c; 
       
        }
 
        
        //US Call not returned in query above  
        if( checkMarket == 'United States' || checkMarket == 'Brazil' )//Added by Sreekanth to show the call detail page to Brazil - SC-008023
        {
            Id userId = UserInfo.getUserId();
            User u = [SELECT ZTS_EU_Market__c FROM User WHERE Id = :userId LIMIT 1];

            Id currentId = (Id)ApexPages.CurrentPage().getparameters().get('id');
            Call__c call = new Call__c(Id=currentId);
            PageReference pr = new ApexPages.StandardController(call).view();
            // Theme4d is lightning
            // Theme3 is classic
            if((u.ZTS_EU_Market__c == 'United States' || u.ZTS_EU_Market__c == 'Brazil') && currentId != null) {
                pr.getParameters().put('nooverride', '1');
                pr.getParameters().put('id',currentId);
                pr.setRedirect(true);
                return pr; 
            }
            return null;
        }
        else
        {
            return null;
        }
   }      
  
    
}