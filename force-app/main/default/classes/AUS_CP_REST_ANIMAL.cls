/*

This code is written to meet integration requirement for 'Australia Vaccination Register' project. 

A rest utility has been built in Touchpoint to insert/update/delete Animal records from crown peak system.

Kaushik Ghosh   Cognizant Technology Solutions


*/


@RestResource(URLMAPPING='/Animal/REST/*')


global class AUS_CP_REST_ANIMAL {
@httpget
    global static list<animal__c> doget(){
    
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    
    list<Animal__c> myanimal = new list<Animal__c>();
    String animalId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
    
    IF (animalId !=null && animalId !=''){
    myanimal = [select ID,
    NAME,
    RECORDTYPE.NAME,
    Age__c,
    AgeMonth__c,
    AnimalChipID__c,
    AnimalChipID2__c,
    Animal_Name__c,
    Animal_Sex__c,
    Animal_Type__c,
    Breed__c,
    Colour__c,  
    Contact_with_other_horses__c,
    Deceased__c,
    DOB__c,
    Height_hh__c,
    Notes__c,
    Owner__c,
    Removed_from_Owner__c,
    Share_opt_in__c,
    ShowPDFCertificateLink__c,
    Actual_Age_in_months__c,
    Actual_Age__c,
    Weight__c from animal__c where animalchipid__c =:animalId];
    If (myanimal.size()>0 && myanimal[0].colour__c ==null) myanimal[0].colour__c = '';
    If (myanimal.size()>0 && myanimal[0].Height_hh__c ==null) myanimal[0].Height_hh__c = null;
    If (myanimal.size()>0 && myanimal[0].weight__c == null) myanimal[0].weight__c = null;
    If (myanimal.size()>0 && myanimal[0].age__c ==null) myanimal[0].age__c = null;
    If (myanimal.size()>0 && myanimal[0].AgeMonth__c ==null) myanimal[0].AgeMonth__c = null;
    If (myanimal.size()>0 && myanimal[0].AnimalChipID2__c ==null) myanimal[0].AnimalChipID2__c = '';
    return myanimal;
    }
    
    else{
        
    system.debug(animalId);
    
    myanimal =  [select ID,
    NAME,
    RECORDTYPE.NAME,
    Age__c,
    AgeMonth__c,
    AnimalChipID__c,
    AnimalChipID2__c,
    Animal_Name__c,
    Animal_Sex__c,
    Animal_Type__c,
    Breed__c,
    Colour__c,  
    Contact_with_other_horses__c,
    Deceased__c,
    DOB__c,
    Height_hh__c,
    Notes__c,
    Owner__c,
    Removed_from_Owner__c,
    Share_opt_in__c,
    ShowPDFCertificateLink__c,
    Weight__c,createddate from animal__c limit 40];
    system.debug(animalId);
    return myanimal;
    }
    }

@httppatch
global static list<animal__c> dopatch(){

RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
          
animalwrapperresp awrapper_resp = new animalwrapperresp();
list<animal__c> mylist = new list<animal__c>();

animalwrapperreq a_req = (animalwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), animalwrapperreq.class);
 animal__c aw = [select id, AnimalChipID__c from animal__c where animalchipid__c =:a_req.animalchipid];
 list<account> aw1 = [select id, ZTS_EU_Zoetis_SFDC_ID__c from account where ZTS_EU_Zoetis_SFDC_ID__c!= null and  ZTS_EU_Zoetis_SFDC_ID__c =:a_req.animalownersfdcid AND ZTS_EU_Market__c != 'United States'];
 
 If (aw.AnimalChipID__c == a_req.animalchipid) {
  aw.Contact_with_other_horses__c = a_req.contactwithotherhorses;
  aw.Removed_from_Owner__c = a_req.removedfromowner;
  aw.Share_opt_in__c = a_req.shareoptin;
  aw.Deceased__c = a_req.decesased;
  aw.ShowPDFCertificateLink__c = a_req.showpdflink;
  aw.colour__c = a_req.color;
  aw.breed__c = a_req.breed;
  aw.weight__c = a_req.weight;
  aw.Height_hh__c = a_req.height;
  aw.notes__c = a_req.notes;
  aw.age__c = a_req.Age;
  aw.AgeMonth__c = a_req.agemonth;
  aw.Animal_Sex__c =a_req.animalsex;
  aw.Animal_Name__c = a_req.animalname;
  aw.dob__c = a_req.dob;
  aw.animalchipid2__c = a_req.animalchipid2;//--uncommented by Aritra upon request from Daniel on 6-Jun-2019
  aw.Animal_Type__c = a_req.animaltype;
  If (aw1.size()>0) aw.owner__c = aw1[0].id;
  update aw;
  mylist.add(aw);
  return mylist;
 }
 return null;
   
    
}

@httpdelete
global static void  dodelete(){

RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
          
animalwrapperresp awrapper_resp = new animalwrapperresp();
list<animal__c> mylist = new list<animal__c>();

 String animalId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

//animalwrapperreq a_req = (animalwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), animalwrapperreq.class);
 list<animal__c> aw = [select id, AnimalChipID__c from animal__c where animalchipid__c =:animalId];

If (aw.size()>0)
  delete aw;
  
 }
 



  
@httppost

  global static list<animal__c> dopost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        
        animalwrapperresp awrapper_resp = new animalwrapperresp();
        
       
        list<animal__c> mylist = new list<animal__c>();
        
        
         animalwrapperreq a_req = (animalwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), animalwrapperreq.class);
       
              Try{
      //  animalwrapperreq a_req = (animalwrapperreq) JSON.deserializeStrict(req.requestBody.toString(), animalwrapperreq.class);
       
        system.debug(a_req);
        List<Account> myaccount = [Select id,name,ZTS_EU_Zoetis_SFDC_ID__c from account where ZTS_EU_Zoetis_SFDC_ID__c!=null and  ZTS_EU_Zoetis_SFDC_ID__c =:a_req.animalownersfdcid AND ZTS_EU_Market__c != 'United States' limit 1];
        
        system.debug('Initial Json'+a_req);
        animal__c aw = new animal__c();
       // aw.Name = a_req.name;
        
        IF (myaccount.size()>0) aw.owner__c = myaccount[0].id;
        aw.recordtypeid = [select id from recordtype where developername = : a_req.recordtype].Id;
        system.debug(aw.recordtypeid);
        aw.Age__c = (Integer)a_req.Age;
        system.debug(aw.age__c);
        aw.AgeMonth__c = a_req.agemonth;
        system.debug(aw.AgeMonth__c);
        aw.AnimalChipID__c = a_req.animalchipid;
        system.debug(aw.AnimalChipId__c);
        aw.AnimalChipID2__c = a_req.animalchipid2;
        system.debug(aw.AnimalChipID2__c);
        aw.Animal_Name__c   =a_req.animalname;
        system.debug(aw.Animal_Name__c);
        aw.Animal_Sex__c = a_req.animalsex;
        system.debug(aw.Animal_sex__c);
        aw.Animal_Type__c =a_req.animaltype;
        system.debug(aw.Animal_type__c);
        aw.Breed__c = a_req.breed;
        system.debug(aw.Breed__c);
        aw.Colour__c = a_req.color ;
        
        aw.Contact_with_other_horses__c = a_req.contactwithotherhorses;
        aw.Removed_from_Owner__c = a_req.removedfromowner;
        aw.Share_opt_in__c = a_req.shareoptin;
        aw.Deceased__c = a_req.decesased;
        aw.ShowPDFCertificateLink__c = a_req.showpdflink;
        system.debug(aw.ShowPDFCertificateLink__c);
        
        aw.dob__c = a_req.dob;
        aw.Height_hh__c = a_req.height;
        aw.Notes__c = a_req.notes;
        system.debug(aw.notes__c);
        
        
        aw.Weight__c = a_req.weight;
        system.debug(aw.weight__c);
        insert aw;
        system.debug(aw);
        mylist.add(aw);
        system.debug(mylist);
    //    Insert awrapper.mylist;
        res.addHeader('Content-Type','application/json');
          res.StatusCode = 201;
        //  awrapper_resp.responseBody = Blob.valueOf(JSON.serialize(a_req,true));
        //awrapper_resp.name = a_req.name;
        
        
        awrapper_resp.recordtype = a_req.recordtype;
        awrapper_resp.Age = a_req.Age;
        awrapper_resp.animalownersfdcid = a_req.animalownersfdcid;
        awrapper_resp.agemonth = a_req.agemonth;
        awrapper_resp.animalchipid = a_req.animalchipid;
        awrapper_resp.animalchipid2 = a_req.animalchipid2;
        awrapper_resp.animalsex = a_req.animalsex;
        awrapper_resp.breed = a_req.breed;
        awrapper_resp.color = a_req.color;
        awrapper_resp.contactwithotherhorses    =a_req.contactwithotherhorses;
        awrapper_resp.decesased = a_req.decesased;
        awrapper_resp.dob =a_req.dob;
        awrapper_resp.height = a_req.height;
        awrapper_resp.notes = a_req.notes ;
        awrapper_resp.removedfromowner = a_req.removedfromowner;
        awrapper_resp.shareoptin = a_req.shareoptin;
        awrapper_resp.showpdflink = a_req.showpdflink;
        awrapper_resp.weight = a_req.weight;
        awrapper_resp.message = 'Load Success';
        system.debug('StatusCode' +awrapper_resp);
        system.debug(awrapper_resp);
        String JSONMsg1= JSON.serialize(awrapper_resp);
        system.debug(JSONMsg1);
        system.debug(res.statusCode);
        awrapper_resp.message ='Your vaccination record inserted successfully';
        awrapper_resp.status = 'Success';
        system.debug('Response Code'+res.statusCode);
        IF (res.statusCode==201)
        {
        system.debug('Successfully Inserted');
        res.addHeader('Content-Type','application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(awrapper_resp,true));
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
       // errortable.Details__c = JSON.serialize(a_resp);
        errortable.Details__c = JSON.serialize(awrapper_resp);
        errortable.Status__c = 'Failure';
        insert errortable;
        return null;
        }
        
        return mylist;
  
  }

    
 
  global class animalwrapperreq{
     
  public string animalname;
  public string animaltype;
  public string animalownersfdcid;
  public Integer Age;
  public Integer agemonth;
  public string animalchipid;
  public string animalchipid2;
  public string animalsex;
  public string recordtype;
  public string breed;
  public string color;
  public boolean contactwithotherhorses;
  public boolean decesased;
  public Date dob;
  public Decimal height;
  public boolean removedfromowner;
  public boolean shareoptin;
  public Decimal weight;
  public string notes;
  public boolean showpdflink;
  
  global animalwrapperreq(){
         
     }
  }
  
  
  global class animalwrapperresp{
  public string animalname;
  public string animaltype;
  public string animalownersfdcid;
  public Integer Age;
  public Integer agemonth;
  public string recordtype;
  public string animalchipid;
  public string animalchipid2;
  public string animalsex;
  public string breed;
  public string color;
  public boolean contactwithotherhorses;
  public boolean decesased;
  public Date dob;
  public Decimal height;
  public boolean removedfromowner;
  public boolean shareoptin;
  public Decimal weight;
  public string notes;
  public boolean showpdflink;
  public  string message;
  public  Integer errorcode;
  public string status;
  global animalwrapperresp(){
      
  }
  }

    
    

}