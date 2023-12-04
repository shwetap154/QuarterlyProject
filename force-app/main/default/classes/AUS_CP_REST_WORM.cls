/*
This code is written to meet integration requirement for Australia Vaccination Register project. 

A rest utility has been built in Touchpoint to insert Worming records from crown peak system.

Kaushik Ghosh   Cognizant Technology Solutions


*/

@RestResource(URLMAPPING='/Worming/REST/*')


global class AUS_CP_REST_WORM {
    
@httpget
global static list<worming__c> doget(){
   
   RestRequest req = RestContext.request;
   RestResponse res = RestContext.response;
    
   list<worming__c> aworminglist = new list<worming__c>();
   String vacId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
   IF (vacId !=null && vacId !=''){
   aworminglist = [select name, animal__c,lastmodifieddate,external_id__c,
   animal__r.Actual_Age_in_months__c,createddate
,animal__r.Actual_Age__c
,animal__r.Age__c
,animal__r.AgeMonth__c
,animal__r.AnimalChipID__c
,animal__r.AnimalChipID2__c
,animal__r.Animal_Name__c
,animal__r.Animal_Sex__c
,animal__r.Animal_Type__c	
,animal__r.Breed__c
,animal__r.Colour__c
,animal__r.Contact_with_other_horses__c
,animal__r.Deceased__c
,animal__r.DOB__c
,animal__r.Height_hh__c
,animal__r.Notes__c
,animal__r.Owner__c
,animal__r.Removed_from_Owner__c
,animal__r.Share_opt_in__c
,animal__r.ShowPDFCertificateLink__c
,animal__r.Weight__c
,animal__r.name
,animal__r.recordtype.name
,animal__r.owner.name,Date_of_Worming__c,Due_Date__c,Product__c,Veterinary__c,Veterinary__r.name,Worming_Country__c,Worming_Postcode__c,Worming_State__c
,Worming_Street__c,Veterinary__r.Hendra_Monthly_Email_Preference__c,
veterinary__r.RegistryReminderDisabled__c,Worming_Suburb__c from worming__c where Id =:vacId];
   
   string JsonMsg=Json.serialize(aworminglist);
   system.debug(JsonMsg);
   return aworminglist;
   }
   else
   {
       aworminglist = [select name, animal__c,lastmodifieddate,external_id__c,
   animal__r.Actual_Age_in_months__c,createddate
,animal__r.Actual_Age__c
,animal__r.Age__c
,animal__r.AgeMonth__c
,animal__r.AnimalChipID__c
,animal__r.AnimalChipID2__c
,animal__r.Animal_Name__c
,animal__r.Animal_Sex__c
,animal__r.Animal_Type__c	
,animal__r.Breed__c
,animal__r.Colour__c
,animal__r.Contact_with_other_horses__c
,animal__r.Deceased__c
,animal__r.DOB__c
,animal__r.Height_hh__c
,animal__r.Notes__c
,animal__r.Owner__c
,animal__r.Removed_from_Owner__c
,animal__r.Share_opt_in__c
,animal__r.ShowPDFCertificateLink__c
,animal__r.Weight__c
,animal__r.name
,animal__r.recordtype.name
,animal__r.owner.name,Date_of_Worming__c,Due_Date__c,Product__c,Veterinary__c,Veterinary__r.name,Worming_Country__c,Worming_Postcode__c,Worming_State__c
,Worming_Street__c,Veterinary__r.Hendra_Monthly_Email_Preference__c,
veterinary__r.RegistryReminderDisabled__c,Worming_Suburb__c from worming__c where createddate =Today];
string JsonMsg=Json.serialize(aworminglist);
   system.debug(JsonMsg);
   return aworminglist;
   }
   }

@httppost

  global static list<worming__c> dopost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        
        wormingwrapperresp wwrapper_resp = new wormingwrapperresp();
        
       
        list<worming__c> mylist = new list<worming__c>();
        
        
         
        
        Try{
      
        wormingwrapperreq a_req = (wormingwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), wormingwrapperreq.class);
        system.debug(a_req);
        list<Animal__c> myanimal = [select id,animal_name__c,name,AnimalChipID__c from animal__c where AnimalChipID__c!=null and  AnimalChipID__c = :a_req.animalchipid];
        list<contact> myvet = [select id, ZTS_EU_Zoetis_SFDC_ID__c from contact where ZTS_EU_Zoetis_SFDC_ID__c!=null and  ZTS_EU_Zoetis_SFDC_ID__c = :a_req.vetname AND ZTS_EU_Market__c != 'United States' limit 1];
        
        
        system.debug('Initial Json'+a_req);
        Worming__c vw = new Worming__c();
        vw.Vaccination_Type__c = a_req.vaccination;
        vw.animal__c = myanimal[0].id;
        IF (myvet.size()>0) vw.Veterinary__c = myvet[0].id;
        vw.product__c = a_req.product;
        vw.Date_of_Worming__c = a_req.dateofworming;
        vw.Worming_Street__c = a_req.street;
        vw.Worming_Suburb__c = a_req.suburb;
        vw.Worming_Country__c = a_req.wormingcountry;
        vw.Worming_State__c = a_req.state;
        vw.Worming_Postcode__c = a_req.postcode;
        vw.Source_Application__c = a_req.source;
        vw.external_id__c = a_req.externalid;
        insert vw;
        mylist.add(vw);
    //    Insert vwrapper.mylist;
        system.debug(res.statuscode);
        res.addHeader('Content-Type','application/json');
        res.StatusCode = 201;
        //  vwrapper_resp.responseBody = Blob.valueOf(JSON.serialize(a_req,true));
        
        system.debug('Response Code'+res.statusCode);
        IF (res.statusCode==201)
        {
        wwrapper_resp.animalchipid = a_req.animalchipid;
        wwrapper_resp.vaccination = a_req.vaccination;
        wwrapper_resp.vetname = a_req.vetname;
        wwrapper_resp.product = a_req.product; 
        wwrapper_resp.dateofworming = a_req.dateofworming;
        wwrapper_resp.street = a_req.street;
        wwrapper_resp.suburb = a_req.suburb;
        wwrapper_resp.wormingcountry= a_req.wormingcountry;
        wwrapper_resp.state = a_req.state;
        wwrapper_resp.postcode = a_req.postcode;
        wwrapper_resp.source = a_req.source;
        wwrapper_resp.externalid = a_req.externalid;
        system.debug('Successfully Inserted');
        res.addHeader('Content-Type','application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(wwrapper_resp,true));
        system.debug('Insert log'+res.statuscode +',' +res.responseBody);
        ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
        errortable.Status__c = 'Success';
        errortable.Details__c = (JSON.serialize(wwrapper_resp));
        Insert errortable;
        
        }
        }
        
        catch(exception e){
        res.responseBody = Blob.valueOf(e.getMessage());
        res.statusCode = 500;
        system.debug('Error occurred'+res.responsebody);
        ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
        errortable.Details__c = JSON.serialize(wwrapper_resp);
        errortable.status__c = 'Failure';
        Insert errortable;
        return null;
        }
        
        return mylist;
  
  }

    
 
  global class wormingwrapperreq{
     public string animalchipid;
     public string vaccination;
     public string street;
     public string vetname;
     public string suburb;
     public string state;
     public string product;
     public string postcode;
     public string source;
     public date dateofworming;
     public string wormingcountry;
     public string externalid;
     
     global wormingwrapperreq(){
         
     }
  }
  
  
  global class wormingwrapperresp{
     public string animalchipid; 
     public string vaccination;
     public string street;
     public string vetname;
     public string suburb;
     public string state;
     public string product;
     public string postcode;
     public string source;
     public date dateofworming;
     public string wormingcountry;
     public string externalid;
     public string message;
     public Integer errorcode;
     public string status;
  
  global wormingwrapperresp(){
      
  }
  }

}