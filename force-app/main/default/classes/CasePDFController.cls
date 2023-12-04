/**
* @description       : Logic for current open Case Record and related record field values show into PDF format.
* @author            : Jagadeeswararo G
* @group             : 
* @last modified on  : 11-21-2023
* @last modified by  : Jagadeeswararo G
* Modifications Log
* Ver   Date         Author                      Modification
**/
public with sharing class CasePDFController {
    public Id CaseId {get; private set;}
    //Case Fields
    public String CaseNumber {get; private set;}
    public string PVWorksID {get; private set;}
    public Date DateFirstReceived {get; private set;}
    public Date DateFirstValid {get; private set;}
    public string CaseOwner {get; private set;}
    public string Type {get; private set;}
    public string SubType {get; private set;}
    public string Status {get; private set;}
    public Boolean NoMoreInformationExpected {get; private set;}
	//Contacts Fields
    Public Boolean PrimaryReporter {get; private set;}
    public string Caserole {get; private set;}
    public string AccountName {get; private set;}
    public string ContactName {get; private set;}
    public string PrimaryAddress {get; private set;}//standard contact
    public string PrimaryAddressId{get; private set;}
    public string communeId{get; private set;}
    public string communStr{get; private set;}
    public string citylup{get; private set;}
    public string Phone {get; private set;}
	//Patient
    public string Species {get; private set;}
    public string Sex {get; private set;}
    public string Breed {get; private set;}
    public Date DateofBirth {get; private set;}
    public Decimal Age {get; private set;}
    //Patient Details
    public Decimal TotalExposed {get; private set;}
    public Decimal TotalReacted {get; private set;}
    public Decimal TotalDied {get; private set;}
    public Decimal TotalUnderTreatment {get; private set;}
	//Product 
    public string CaseProduct {get; private set;}
    public string ProductRole {get; private set;}
    public string ProductLotNumber {get; private set;}
    public Date StartDate {get; private set;}
    public string DoseUnit {get; private set;}
    public string ProblemProductType {get; private set;}
    public string LOEReason {get; private set;}
    public string AttendingVetsSuspicionLevel {get; private set;}
    public string PreviousExposure {get; private set;}
    public string PreviousReaction {get; private set;}
    public string ReasonforUse {get; private set;}
	//veddra Event Section
    public string VedDRACoding {get; private set;}
    public DateTime VedStartDate {get; private set;}
    public DateTime EndDate {get; private set;}
    public string Ongoing {get; private set;}
    public string Preferred {get; private set;}
    public Decimal DurationDays {get; private set;}
    public Decimal Timetoonsetfirstdose {get; private set;}
	//Local Assessment Details
    public string Localassessment {get; private set;}
    public string Isitserious {get; private set;}
    public string Reportability {get; private set;}
    //Company Assessment Details
    public string ComIsitserious {get; private set;}
    public string EventNarrative {get; private set;}
	//Case_Contact__c
    public Boolean PriRep {get; private set;} 
    public String ConRol {get; private set;}
    public String ConNam {get; private set;}
    //caseproduct
    public String CasPrdName {get; private set;}
    public String ProdRol {get; private set;}
    public String ProdLot {get; private set;}
    public Date StarDt {get; private set;}
    public String DosUnt {get; private set;}
    public String ProdPrbType {get; private set;}
    public String LoeReas {get; private set;}
    public String AttVetSusp {get; private set;}
    public String PrevExp {get; private set;}
    public String PrevRea {get; private set;}
    public String ResForUse {get; private set;}
    
    //List
    public List<Case> casRec = new List<Case>();
    List<ZTS_US_Case_Animal__c> casAnmLst=new List<ZTS_US_Case_Animal__c>();
    List<Case_Contact__c> casConLst=new List<Case_Contact__c>();
    List<ZTS_US_Case_Product__c> casProdLst=new List<ZTS_US_Case_Product__c>();
    List<ZTS_US_Assessment__c> casAssessLst=new List<ZTS_US_Assessment__c>();
    List<ZTS_US_Case_Animal__c> casPatienLst=new List<ZTS_US_Case_Animal__c>();
    List<ZTS_US_VedDRA_Event__c> casVeddLst=new List<ZTS_US_VedDRA_Event__c>();
    
    public CasePDFController(){
        Id CaseId = Id.valueOf(ApexPages.CurrentPage().getparameters().get('id'));
           
        casRec=getCasCP(CaseId);
        casPatienLst=getPatient(CaseId);
        casVeddLst=getVedd(CaseId);
        
        for(case c : casRec){
            //case 
            CaseNumber = c.CaseNumber;
        	PVWorksID = c.ZTS_EU_PV_Works__c;
            DateFirstReceived = c.ZTS_US_First_Received_Date__c;
            DateFirstValid = c.ZTS_US_Date_First_Valid__c;
            CaseOwner = c.Owner.Name;
            Type = c.Type;
            SubType =c.ZTS_EU_Sub_Type__c;
            Status = c.Status;
            NoMoreInformationExpected = c.ZTS_US_No_More_Information_Expected__c;
            ContactName = c.Contact.Name;
            AccountName = c.Account.Name;
            PrimaryAddressId = c.Contact.ZTS_EU_Primary_Address__c;
            Phone =c.Contact.Phone;
            if(c.Case_Animals__r.size()>0){
                casAnmLst.add(c.Case_Animals__r[0]);
            }
            if(c.Case_Contacts__r.size()>0){
                  casConLst.add(c.Case_Contacts__r[0]);
            }
            if(c.Case_Products__r.size()>0){
                casProdLst.add(c.Case_Products__r[0]);
            }
            if(c.Assessments__r.size()>0){
                casAssessLst.add(c.Assessments__r[0]);
            }
        }
        //added below
        for(ZTS_US_Case_Animal__c cp: casAnmLst){
                //casePatient (ZTS_US_Case_Animal__c)
                TotalExposed = cp.ZTS_US_Exposed__c;
                TotalReacted = cp.ZTS_US_Reacted__c;
                TotalDied = cp.ZTS_US_Died__c;
                TotalUnderTreatment = cp.ZTS_US_Under_Treatment__c;
            }
        for(Case_Contact__c cc : casConLst){
                //Case_Contact__c
                PrimaryReporter = cc.ZTS_US_Primary_Reporter__c;
                Caserole = cc.ZTS_US_Contact_Role__c;
                //ContactName = cc.Contact_Name__c;
                updAddress();
            }
            for(ZTS_US_Case_Product__c cpro : casProdLst){
                //caseproduct
                CaseProduct=cpro.Name;
                ProductRole=cpro.ZTS_US_Product_Role__c;
                ProductLotNumber=cpro.ZTS_US_Product_Lot__c;
                StartDate=cpro.ZTS_US_Start_Date__c;
                DoseUnit=cpro.ZTS_US_Dose_Unit__c;
                ProblemProductType=cpro.ZTS_US_Product_problem_type__c;
                LOEReason=cpro.ZTS_US_LOE_Reason__c;
                AttendingVetsSuspicionLevel=cpro.ZTS_US_Attending_Vet_Suspicion_Level__c;
                PreviousExposure=cpro.ZTS_US_Previous_Exposure__c;
                PreviousReaction=cpro.ZTS_US_Previous_Reaction__c;
                ReasonforUse=cpro.ZTS_US_Reason_for_use__c;
            }
            for(ZTS_US_Assessment__c ass : casAssessLst){
                Localassessment = ass.ZTS_US_Local_Assessment__c;
                Isitserious = ass.ZTS_US_Is_it_serious__c;
                Reportability = ass.ZTS_US_Reportability__c;
                ComIsitserious = ass.ZTS_US_Is_it_serious__c;
            }
          
        for(ZTS_US_Case_Animal__c pat: casPatienLst){
            Species = pat.ZTS_US_Animal__r.ZTS_US_Species__c;
            Sex = pat.ZTS_US_Animal__r.ZTS_US_Sex__c;
            Breed = pat.ZTS_US_Animal__r.ZTS_US_Breed__r.Name;
            DateofBirth = pat.ZTS_US_Animal__r.ZTS_US_Date_of_Birth__c;
            Age = pat.ZTS_US_Animal__r.ZTS_US_Age_text__c;
        }
        for(ZTS_US_VedDRA_Event__c ved:casVeddLst){
            VedDRACoding = ved.ZTS_US_VedDRA_Coding__r.Name;
  			VedStartDate = ved.ZTS_US_Start_Date__c;
    		EndDate = ved.ZTS_US_End_Date__c;
    		Ongoing = ved.ZTS_US_Ongoing__c;
    		Preferred = ved.Preferred_Term__c;
    		DurationDays = ved.ZTS_US_Duration__c;
    		Timetoonsetfirstdose = ved.ZTS_US_Time_to_onset_first_dose__c;
            EventNarrative = ved.ZTS_US_Event_Narrative__r.Name;
        }
     
    }
   
    public List<case> getCasCP(Id casId){
        List<case> c = [select CaseNumber,ZTS_EU_PV_Works__c,ZTS_US_First_Received_Date__c,ZTS_US_Date_First_Valid__c,Owner.Name,Type,
                        ZTS_EU_Sub_Type__c,Status,ZTS_US_No_More_Information_Expected__c,ZTS_US_Primary_Reporter__c,Account.Name,Contact.Name,Contact.Phone,Contact.ZTS_EU_Primary_Address__c,
                        (select ZTS_US_Exposed__c,ZTS_US_Reacted__c,ZTS_US_Died__c,ZTS_US_Under_Treatment__c from Case_Animals__r),
                        (select ZTS_US_Primary_Reporter__c,ZTS_US_Contact_Role__c,Contact_Name__c from Case_Contacts__r),
                        (select Name,ZTS_US_Product_Role__c,ZTS_US_Product_Lot__c,ZTS_US_Start_Date__c,ZTS_US_Dose_Unit__c,
                         ZTS_US_Product_problem_type__c,ZTS_US_LOE_Reason__c,ZTS_US_Attending_Vet_Suspicion_Level__c,ZTS_US_Previous_Exposure__c,
                         ZTS_US_Previous_Reaction__c,ZTS_US_Reason_for_use__c from Case_Products__r),(select ZTS_US_Local_Assessment__c,ZTS_US_Is_it_serious__c,ZTS_US_Reportability__c from Assessments__r)
						 from case where id =:casId];
        return c;
    }
   
    public List<ZTS_US_VedDRA_Event__c> getVedd(Id casId){//ZTS_US_VedDRA_Coding__c
       List<ZTS_US_VedDRA_Event__c> vedRec = [select ZTS_US_Event_Narrative__r.ZTS_US_Case__r.id, ZTS_US_VedDRA_Coding__r.Name,ZTS_US_Start_Date__c,ZTS_US_End_Date__c,ZTS_US_Ongoing__c,Preferred_Term__c,ZTS_US_Duration__c,ZTS_US_Time_to_onset_first_dose__c,ZTS_US_Event_Narrative__c,ZTS_US_Event_Narrative__r.Name from ZTS_US_VedDRA_Event__c where ZTS_US_Event_Narrative__r.ZTS_US_Case__r.id =: casId Limit 1];
        return vedRec;
    }
    public List<ZTS_US_Case_Animal__c> getPatient(Id casId){//ZTS_US_Breed__c      ZTS_US_Animal__r.ZTS_US_Breed__c
        List<ZTS_US_Case_Animal__c> pat = [select ZTS_US_Animal__r.ZTS_US_Species__c,ZTS_US_Animal__r.ZTS_US_Sex__c,ZTS_US_Animal__r.ZTS_US_Breed__r.Name,ZTS_US_Animal__r.ZTS_US_Date_of_Birth__c,ZTS_US_Animal__r.ZTS_US_Age_text__c from ZTS_US_Case_Animal__c where ZTS_US_Case__r.id =: casId];
        return pat;
    }
    public void updAddress(){
       State_Country__c commun;
        if(PrimaryAddressId!=null){
       Address__c addLst=[select Name,ZTS_EU_Address_Line_2__c,ZTS_EU_Address_Line_3__c,Address_Line_4__c,
                       ZTS_EU_Country__c,ZTS_EU_State_County__c,ZTS_EU_Commune_Lookup__c,ZTS_EU_District__c,
                       ZTS_EU_City__c,ZTS_EU_City_Country__c,Zip_Postal_Code__c,ZTS_EU_Brick_Code__c
                       from Address__c where Id =: PrimaryAddressId limit 1];
            
            communeId =addLst.ZTS_EU_Commune_Lookup__c;
            if(communeId!=null){
                commun= [select Name,(select Name,ZTS_EU_State_County__c from City_Country__r) from State_Country__c where Id =: communeId];//addLst.ZTS_EU_Commune_Lookup__c]; 
                string communStr =commun.Name;
                for(City_State__c ctyUp : commun.City_Country__r)
                string citylup =ctyUp.Name;
            }
        if(addLst!=null){
            if(addLst.Name!=null) 
                PrimaryAddress = addLst.Name;
            if(addLst.ZTS_EU_Address_Line_2__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.ZTS_EU_Address_Line_2__c;
            if(addLst.ZTS_EU_Address_Line_3__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.ZTS_EU_Address_Line_3__c;
            if(addLst.Address_Line_4__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.Address_Line_4__c;
            if(addLst.ZTS_EU_Country__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.ZTS_EU_Country__c;
            if(addLst.ZTS_EU_State_County__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.ZTS_EU_State_County__c;
            if(communStr!=null)
                PrimaryAddress = PrimaryAddress+' '+commun.Name;
            if(addLst.ZTS_EU_District__c!=null)
                PrimaryAddress = PrimaryAddress+' '+addLst.ZTS_EU_District__c;
            if(addLst.ZTS_EU_City__c!=null)
                PrimaryAddress =PrimaryAddress+' '+addLst.ZTS_EU_City__c;
            if(citylup!=null)
                 PrimaryAddress =PrimaryAddress+' '+citylup;
           /* if(addLst.ZTS_EU_City_Country__c!=null)
                PrimaryAddress =PrimaryAddress+' '+addLst.ZTS_EU_City_Country__c;*/
            if(addLst.Zip_Postal_Code__c!=null)
                PrimaryAddress =PrimaryAddress+' '+addLst.Zip_Postal_Code__c;
            if(addLst.ZTS_EU_Brick_Code__c!=null)
                PrimaryAddress =PrimaryAddress+' '+addLst.ZTS_EU_Brick_Code__c;
            
           
        }
        }
    }

}