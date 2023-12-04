/*************************************************************************************
* Name          :    ZTS_EU_ContactRedirect .
* Description   :    Override the new button.
* Author        :    Chandra
 
Modification Log
----------------
Date             Developer                Comments
---------------------------------------------------------------------------------------
3/7/2014         Chandra                   Created
5/20/2014        Chandra                   Added Market pre-populate
3rd-Sep-2014     Shreyas                   Added the field 'ZTS_EU_City_Country__c' below to autopopulate the City-Country lookup field for CLAR 
21-May-2015      Shreyas                   Added the field 'District' field for accounts/contact/address.   
08-Jun-2015      Shreyas                   Added the field 'Commune' field for accounts/contact/address. 
**************************************************************************************/
public with sharing class ZTS_EU_ConRedirect {
    /*****************************************
    VARIABLES
    ******************************************/
    public String userDefaultCon{get;set;}
    public String defaultValues {get; set;}
    public List<Account> accountAddressFields;
    public List<String> availableRecIds=new List<String>();
    public static final string NOOVERRIDE_PARAMETER_STR = 'nooverride=1';
    public static final String parentId = ApexPages.currentPage().getParameters().get('accid');
    public String retURL            = ''; 
    public String accid             = '';   
    public String countryId         = '';
    public String addressLine1      = '';
    public String addressLine2      = '';
    public String addressLine3      = '';
    public String city              = '';
    public String county            = '';
    public String countyName        = '';
    public String postalCode        = '';
    public String PreferredLanguage = '';
    public String Market = '';
    public String Phone = '';
    public String citylookup = '';
    public String citylookupName = '';
    public String District = '';
    public String Communelookup = '';
    public String CommunelookupName = '';
    public String recordTypeId{get; set;}
    
    


    
    public ZTS_EU_ConRedirect(ApexPages.StandardController controller) {     

        User user = [select id,Default_Country__c, ZTS_EU_Market__c from user where id = : UserInfo.getUserID()];
        //added logic to populate the default value for lightning view
        //adding logic to fix bug with creating from listview of Contacts
        if( String.isEmpty( parentId ) )
        {
            defaultValues = JSON.serialize( new Map<String, Object>{'ZTS_EU_Market__c'=> user.ZTS_EU_Market__c});
        }
        else
        {
            defaultValues = JSON.serialize( SL_ContactManager.getContactDefaultValues( parentId ) );
        }
        ZTS_EU_Field_ID__c fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_Country_Id');
        countryId = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_AddressLine1_Id');
        addressLine1 = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_AddressLine2_Id');
        addressLine2 = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_AddressLine3_Id');
        addressLine3 = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_City_Id');
        city = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_County_Id');
        county = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_CountyName_Id');
        countyName = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_PostalCode_Id');
        postalCode = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Prefered_Language_Id');
        PreferredLanguage = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_Market_Field_Id');
        Market = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_PrivatePhoneId');
        Phone = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_District_Id');
        District = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_Commune_Id');
        Communelookup = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_CommuneName_Id');
        CommunelookupName = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_CityLookup_Id');
        citylookup = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        fieldId = ZTS_EU_Field_ID__c.getValues('ZTS_EU_Contact_CityLookupName_Id');
        citylookupName = fieldId!=null?fieldId.ZTS_EU_ID__c:'';
        
        
        userDefaultCon = user.Default_Country__c;
        if(ApexPages.currentPage().getParameters().containskey('retURL')){
            retURL =  ApexPages.currentPage().getParameters().get('retURL');
        }
        if(ApexPages.currentPage().getParameters().containskey('accid')){

            accid =  ApexPages.currentPage().getParameters().get('accid');
        }
        recordTypeId = System.currentPageReference().getParameters().get('RecordType');

    }

    public pagereference conRedirect(){
        PageReference redirectedPage   = null;
        String url =''; 
        url =  '/003/e'; 
        // Srinivas K Added code as part of the defect INC0651758      
        url = url + '?retURL='+'/'+accid;        
        url = url + '&' +NOOVERRIDE_PARAMETER_STR;
        
        //Prasanta Bai to get Selected Record Type
        if(String.isNotEmpty(recordTypeId)){
          url = url + '&RecordType='+recordTypeId;
          }
           
        if(accid != null || accid != ''){
            
            accountAddressFields = [SELECT ZTS_EU_Address_Line_1__c,ZTS_EU_Preferred_Language__c, ZTS_EU_Address_Line_2__c, ZTS_EU_Address_Line_3__c,ZTS_EU_District__c,
                                    ZTS_EU_State_County__r.Id, ZTS_EU_State_County__r.Name,ZTS_EU_City__c,ZTS_EU_Market__c, ZTS_EU_Country__c, ZTS_EU_Zip_Postal_Code__c, 
                                    ZTS_EU_City_Country__r.Id, ZTS_EU_City_Country__r.Name, ZTS_EU_State_County__c,ZTS_EU_Main_Phone__c, ZTS_EU_Commune_Lookup__c,
                                    ZTS_EU_Commune_Lookup__r.Id, ZTS_EU_Commune_Lookup__r.Name  
                                    FROM Account where Id =: accid LIMIT 1];
            url = url + '&accid='+accid;
                if(accountAddressFields.size() > 0){
                url = url + '&'+PreferredLanguage+'='+(accountAddressFields[0].ZTS_EU_Preferred_Language__c!= null ?accountAddressFields[0].ZTS_EU_Preferred_Language__c : '');
                url = url + '&'+Market+'='+(accountAddressFields[0].ZTS_EU_Market__c!= null ?accountAddressFields[0].ZTS_EU_Market__c : '');
                url = url + '&'+addressLine1+'='+(accountAddressFields[0].ZTS_EU_Address_Line_1__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_1__c : '');
                url = url + '&'+addressLine2+'='+(accountAddressFields[0].ZTS_EU_Address_Line_2__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_2__c : '');
                url = url + '&'+addressLine3+'='+(accountAddressFields[0].ZTS_EU_Address_Line_3__c!= null ?accountAddressFields[0].ZTS_EU_Address_Line_3__c : '');
                url = url + '&'+city+'='+(accountAddressFields[0].ZTS_EU_City__c!= null ?accountAddressFields[0].ZTS_EU_City__c : '');
                if(accountAddressFields[0].ZTS_EU_State_County__r.Id!= null)
                    url = url + '&'+county+'='+accountAddressFields[0].ZTS_EU_State_County__r.Id;
                url = url + '&'+countyName+'='+(accountAddressFields[0].ZTS_EU_State_County__r.Name!= null ?accountAddressFields[0].ZTS_EU_State_County__r.Name: '');
                url = url + '&'+countryId+'='+(accountAddressFields[0].ZTS_EU_Country__c!= null ?accountAddressFields[0].ZTS_EU_Country__c : '');
                url = url + '&'+postalCode+'='+(accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c!= null ?accountAddressFields[0].ZTS_EU_Zip_Postal_Code__c: '');
                url = url + '&'+Phone+'='+(accountAddressFields[0].ZTS_EU_Main_Phone__c!= null ?accountAddressFields[0].ZTS_EU_Main_Phone__c: '');
                url = url + '&'+District+'='+(accountAddressFields[0].ZTS_EU_District__c!= null ?accountAddressFields[0].ZTS_EU_District__c: '');
                
                
                if(accountAddressFields[0].ZTS_EU_City_Country__c != null){
                    url = url + '&'+citylookup+'='+accountAddressFields[0].ZTS_EU_City_Country__r.Id;
                    url = url + '&'+citylookupName+'='+(accountAddressFields[0].ZTS_EU_City_Country__r.Name!= null ?accountAddressFields[0].ZTS_EU_City_Country__r.Name: '');
                }
                
                if(accountAddressFields[0].ZTS_EU_Commune_Lookup__c != null){
                    url = url + '&'+Communelookup+'='+accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Id;
                    url = url + '&'+CommunelookupName+'='+(accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Name!= null ?accountAddressFields[0].ZTS_EU_Commune_Lookup__r.Name: '');
                }
    
              }
           
           }
           
                  
        redirectedPage = new PageReference(url); 
        redirectedPage.setRedirect(true);         
        return redirectedPage;
    } 

    /***********
      * Method name  : backToView
      * Description  : This method will exit from the record creation wizard.
      * Return Type  : PageReference
      * Parameters   : NA.
    ***********/
    public PageReference backToView() {
        PageReference pageRef = !Test.isRunningTest() ? ( String.isNotBlank(parentId) ? new PageReference('/'+parentId): new ApexPages.Action('{!List}').invoke() ) 
            										  : ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }
}