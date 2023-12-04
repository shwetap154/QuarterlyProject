/*
This code is written to meet integration requirement for Australia Vaccination Register project. 

A rest utility has been built in Touchpoint to insert Vaccination records from crown peak system.

Kaushik Ghosh   Cognizant Technology Solutions


*/


@RestResource(URLMAPPING='/VaccineRegister/REST/*')


global class AUS_CP_REST_VACC {
@httpget
    global static list<vaccinationregister__c> doget(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    
    list<vaccinationregister__c> myvaccinationregister = new list<vaccinationregister__c>();
    String vacId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    IF (vacId !=null && vacId !=''){
    myvaccinationregister = [select id,animal__r.Last_Hendra_Vaccination__c,Veterinary__c,Vet_Name__c,veterinary__r.ZTS_EU_Zoetis_SFDC_ID__c,animal__r.owner__r.ZTS_EU_Zoetis_SFDC_ID__c,treatment__c,external_id__c,Inactive__c,others__c,Vaccination_Country__c,Vaccination_State__c,Vaccination_Postcode__c,Due_Date__c,Vet_s_Email__c,veterinary__r.name,Veterinary__r.Hendra_Monthly_Email_Preference__c,Veterinary__r.RegistryReminderDisabled__c,Clinic__r.Email_Preference__c,Source_Application__c,Vaccination_Suburb__c, clinic__r.name,vaccinationdate__c,animal__r.name,animal__r.Notes__c,animal__r.Animal_Type__c,animal__r.AnimalChipID2__c,animal__r.Actual_Age__c,animal__r.Actual_Age_in_months__c,animal__r.age__c,animal__r.Animal_Name__c	,animal__r.owner__r.name,animal__r.Share_opt_in__c,animal__r.ShowPDFCertificateLink__c,animal__r.createdby.name,animal__r.AnimalChipID__c,animal__r.Breed__c,animal__r.Colour__c,animal__r.Deceased__c,animal__r.DOB__c,animal__r.Weight__c,animal__r.recordtype.name,animal__r.Contact_with_other_horses__c,animal__r.Removed_from_Owner__c,animal__r.owner.name,animal__r.Animal_Sex__c,animal__r.Height_hh__c,animal__r.createddate,animal__r.lastmodifiedby.name,animal__r.lastmodifieddate from vaccinationregister__c where Id =:vacId];
    system.debug(vacId);
    If (myvaccinationregister[0].Veterinary__c == null) myvaccinationregister[0].Veterinary__c = null;
    return myvaccinationregister;
    }
    else{
    system.debug(vacId);
    myvaccinationregister = [select id,animal__r.Last_Hendra_Vaccination__c,Vet_Name__c,Veterinary__c,veterinary__r.ZTS_EU_Zoetis_SFDC_ID__c,treatment__c,animal__r.owner__r.ZTS_EU_Zoetis_SFDC_ID__c,external_id__c,Inactive__c,others__c,Vaccination_Country__c,Vaccination_State__c,Vaccination_Postcode__c,Due_Date__c,Vet_s_Email__c,veterinary__r.name,Veterinary__r.Hendra_Monthly_Email_Preference__c,Veterinary__r.RegistryReminderDisabled__c,Clinic__r.Email_Preference__c,Source_Application__c,Vaccination_Suburb__c, clinic__r.name,vaccinationdate__c,animal__r.name,animal__r.Notes__c,animal__r.Animal_Type__c,animal__r.AnimalChipID2__c,animal__r.Actual_Age__c,animal__r.Actual_Age_in_months__c,animal__r.age__c,animal__r.Animal_Name__c	,animal__r.owner__r.name,animal__r.Share_opt_in__c,animal__r.ShowPDFCertificateLink__c,animal__r.createdby.name,animal__r.AnimalChipID__c,animal__r.Breed__c,animal__r.Colour__c,animal__r.Deceased__c,animal__r.DOB__c,animal__r.Weight__c,animal__r.recordtype.name,animal__r.Contact_with_other_horses__c,animal__r.Removed_from_Owner__c,animal__r.owner.name,animal__r.Animal_Sex__c,animal__r.Height_hh__c,animal__r.createddate,animal__r.lastmodifiedby.name,animal__r.lastmodifieddate from vaccinationregister__c where createddate = Today];
    return myvaccinationregister;
    }
    }

@httppost

  global static list<VaccinationRegister__c> dopost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        
        vaccinationwrapperresp vwrapper_resp = new vaccinationwrapperresp();
        
       
        list<vaccinationregister__c> mylist = new list<vaccinationregister__c>();
        
        
        
        
        Try{
       vaccinationwrapperreq a_req = (vaccinationwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), vaccinationwrapperreq.class);
        system.debug(a_req);
        list<Animal__c> myanimal = [select id,animal_name__c,name,AnimalChipID__c from animal__c where AnimalChipID__c = :a_req.animalchipid];
        list<contact> myvet = [select id, ZTS_EU_Zoetis_SFDC_ID__c from contact where ZTS_EU_Zoetis_SFDC_ID__c !=null and ZTS_EU_Zoetis_SFDC_ID__c = :a_req.vetname AND ZTS_EU_Market__c != 'United States' limit 1];
        list<Account> myacc = [select id, ZTS_EU_Zoetis_SFDC_ID__c from account where ZTS_EU_Zoetis_SFDC_ID__c !=null and ZTS_EU_Zoetis_SFDC_ID__c	 = :a_req.clinic AND ZTS_EU_Market__c != 'United States' limit 1];
        
        system.debug('Initial Json'+a_req);
        VaccinationRegister__c vw = new VaccinationRegister__c();
        vw.treatment__c = a_req.treatment;
        vw.VaccinationType2__c	 = a_req.vaccination;
        vw.VaccinationDate__c = a_req.vaccinationdate;
        vw.Source_Application__c = a_req.source;
        IF (myanimal.size()>0) vw.animal__c = myanimal[0].id;
        IF (myvet.size() >0) vw.Veterinary__c = myvet[0].id;
        IF (myacc.size() >0) vw.clinic__c = myacc[0].id;
        vw.Batch_Number__c = a_req.batch;
        vw.Vaccination_Address__c = a_req.vacaddress;
        vw.Vaccination_State__c	=a_req.vacstate;
        vw.Vaccination_Postcode__c = a_req.vacpostcode;
        vw.Vaccination_Country__c = a_req.vaccountry;
        vw.Vaccination_Suburb__c =a_req.vacsub;
        vw.Inactive__c = a_req.inactive;
        vw.others__c = a_req.other ;
        vw.external_id__c = a_req.externalid;
        insert vw;
        mylist.add(vw);
    //    Insert vwrapper.mylist;
        res.addHeader('Content-Type','application/json');
          res.StatusCode = 201;
        //  vwrapper_resp.responseBody = Blob.valueOf(JSON.serialize(a_req,true));
        vwrapper_resp.treatment = a_req.treatment;
        vwrapper_resp.vaccination	 = a_req.vaccination;
        vwrapper_resp.vaccinationdate = a_req.vaccinationdate;
        vwrapper_resp.source = a_req.source;
        vwrapper_resp.animalchipid = a_req.animalchipid;
        vwrapper_resp.Vetname = a_req.vetname;
        vwrapper_resp.clinic = a_req.clinic;
        vwrapper_resp.Batch = a_req.batch;
        vwrapper_resp.vacaddress = a_req.vacaddress;
        vwrapper_resp.vacstate	=a_req.vacstate;
        vwrapper_resp.vacpostcode = a_req.vacpostcode;
        vwrapper_resp.vaccountry = a_req.vaccountry;
        vwrapper_resp.vacsub =a_req.vacsub;
        vwrapper_resp.Inactive = a_req.inactive;
        vwrapper_resp.other = a_req.other ;
        vwrapper_resp.externalid = a_req.externalid;
        vwrapper_resp.message = 'Load Success';
        system.debug('StatusCode' +vwrapper_resp);
        system.debug(vwrapper_resp);
        String JSONMsg1= JSON.serialize(vwrapper_resp);
        system.debug(JSONMsg1);
        system.debug(res.statusCode);
        vwrapper_resp.message ='Your vaccination record inserted successfully';
        vwrapper_resp.status = 'Success';
        system.debug('Response Code'+res.statusCode);
        IF (res.statusCode==201)
        {
        system.debug('Successfully Inserted');
        res.addHeader('Content-Type','application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(vwrapper_resp,true));
        system.debug('Insert log'+res.statuscode +',' +res.responseBody);
        ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
        errortable.Status__c = 'Success';
        errortable.Details__c = JSONMsg1;
        Insert errortable;
        }
        }
        
        catch(exception e){
        res.responseBody = Blob.valueOf(e.getMessage());
        res.statusCode = 500;
        system.debug('Error occurred'+res.responsebody);
        ErrorLog_CrownPeak__c errortable = new ErrorLog_CrownPeak__c();
        //errortable.Details__c = JSON.serialize(a_req);
       errortable.Details__c = JSON.serialize(vwrapper_resp);
        errortable.Status__c = 'Failure';
        insert errortable;
        return null;
        }
        
        return mylist;
  
  }

    
 
  global class vaccinationwrapperreq{
     
  public string treatment;
  public string vaccination;
  public date vaccinationdate;
  public string animalchipid;
  public string vetname;
  public string clinic;
  public   string batch;
  public  string vacaddress;
  public   string vacstate;
  public   string vacpostcode;
  public string vaccountry;
  public   string vacsub;
  public   boolean inactive;
  public   string source;
  public   string other;
  public  string externalid;
     
  global vaccinationwrapperreq(){
         
     }
  }
  
  
  global class vaccinationwrapperresp{
  public   string treatment;
  public   string vaccination;
  public   date vaccinationdate;
  public   string animalchipid;
  public  string vetname;
  public   string clinic;
  public   string batch;
  public   string vacaddress;
  public  string vacstate;
  public  string vacpostcode;
  public string vaccountry;
  public string vacsub;
  public  boolean inactive;
  public  string source;
  public  string other;
  public  string externalid;
  public  string message;
  public  Integer errorcode;
  public string status;
  global vaccinationwrapperresp(){
      
  }
  }

}