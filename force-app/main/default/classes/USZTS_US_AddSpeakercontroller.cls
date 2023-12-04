/****************************************************************************************************************************************** 
 * Class Name       : USZTS_US_AddSpeakercontroller
 * Description      : The class is used to do the following 
                      1. Check for the Contact being added to the Speaker 
                      2. Based on the account, display appropriate values for Speaker Fee 
                      3. Save the speaker with the selected values
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 9th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Vidya Das               05/09/2014          Created 
*****************************************************************************************************************************************/
public class USZTS_US_AddSpeakercontroller{

    public String eventCat                      {get;set;}
    public String evntId                        {get;set;}
    public ZTS_US_Speaker__c speaker            {get;set;}
    public List<SelectOption> listSpeakerVal    {get;set;}
    public String selectedSpeakerFee            {get;set;}
    public String selectedSpeakerVal            {get;set;}
    public String selectedFeeType               {get;set;}
    public Boolean isCorrectProfile             {get;set;}
    public Boolean isSearched                   {get;set;}
    ZTS_Events__c event = new ZTS_Events__c();
    
    public USZTS_US_AddSpeakercontroller(ApexPages.StandardController controller){
        isSearched=false;
        evntId = ApexPages.currentPage().getParameters().get('eventId');
        speaker = (ZTS_US_Speaker__c)controller.getRecord();
        // This is the condition for Update/Edit
        if(speaker.id<>null){
            speaker=[Select id,ZTS_US_Contact__c,ZTS_US_Event__c,ZTS_US_Speaker_Fee__c,ZTS_US_Actual_Speaker_Fee__c,ZTS_US_Speaker_Fee_Type__c,ZTS_US_Speaking_Date__c from ZTS_US_Speaker__c where id=:speaker.id AND ZTS_EU_Market_from_Parent__c = 'United States'];
            evntId =speaker.ZTS_US_Event__c;
        }
        List<ZTS_Events__c> listEvent = [select ZTS_US_Event_Category__c,Name,ZTS_US_Name__c,Copy_Start_Date__c from ZTS_Events__c where Id=: evntId AND ZTS_EU_Market__c = 'United States'];
        if(listEvent != null && listEvent.size() > 0){
            eventCat = listEvent[0].ZTS_US_Event_Category__c;
            event = listEvent[0];
        }
        listSpeakerVal = new List<SelectOption>{new SelectOption('None','--None--')};
        isCorrectProfile = true;
        // This is the condition for New
        if(speaker.id==null){
            speaker = new ZTS_US_Speaker__c();
            speaker.ZTS_US_Speaking_Date__c = event.Copy_Start_Date__c;
            speaker.ZTS_US_Event__c = evntId;
        }
        else{
            populateValues();
            selectedSpeakerFee =string.valueof(speaker.ZTS_US_Speaker_Fee__c);               
            selectedFeeType   =speaker.ZTS_US_Speaker_Fee_Type__c   ;  
            
        }
        
    }
    
    /*****************
    * Method Name   : save
    * Description   : This method checks for all the validations before saving the Speaker record
    * Return Type   : PageReference
    * Parameters    : None
    ******************/
    public PageReference save(){
        try{
            if(selectedSpeakerVal == null || selectedSpeakerVal == '' || selectedSpeakerVal == 'None' && selectedFeeType == '' && selectedSpeakerFee == '' && selectedSpeakerVal == 'None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Contact does not have associated Speaker values. Please select another Contact'));
                return null;
            }
            else if(selectedSpeakerVal != null && selectedSpeakerVal !='' && selectedSpeakerVal != 'None'){
                speaker.ZTS_US_Speaker_Fee_Type__c = selectedSpeakerVal.split('\\$')[1].split(' - ')[1];
                //speaker.ZTS_US_Speaker_Fee__c = Decimal.valueOf(selectedSpeakerVal.split('\\$')[1].split(' - ')[0]);
                        if(Decimal.valueOf(selectedSpeakerVal.split('\\$')[1].split(' - ')[0])<speaker.ZTS_US_Actual_Speaker_Fee__c){
                             // speaker.ZTS_US_Speaker_Fee__c = Decimal.valueOf(selectedSpeakerVal.split('\\$')[1].split(' - ')[0]);
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Speaker Fee cannot be > than the negotiated maximum speaker rate displayed - Please enter a fee <= to the maximum rate displayed'));                           
                        }
                else{
                              speaker.ZTS_US_Speaker_Fee__c =Speaker.ZTS_US_Actual_Speaker_Fee__c;
                              speaker.Maximum_Speaker_Fee__c = Decimal.valueOf(selectedSpeakerVal.split('\\$')[1].split(' - ')[0]);
                }
            }else if(selectedFeeType == '' && selectedSpeakerFee == '' && selectedSpeakerVal == 'None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Contact does not have associated Speaker values. Please select another Contact'));
                return null;
            }
            upsert speaker;
            PageReference pg = new PageReference('/'+evntId);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
    
    /*****************
    * Method Name   : populateValues
    * Description   : This method populates the picklist to be displayed for Speaker Fee when the logged in user has Small Animal Rep profile
    * Return Type   : void
    * Parameters    : None
    ******************/
    public void populateValues(){
    isSearched=true;
       for(Contact con : [select id, Elite_Speaker__c from Contact 
                                                        where id=: speaker.ZTS_US_Contact__c AND ZTS_EU_Market__c = 'United States'] ){
            if(con.Elite_Speaker__c == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.Speaker_Schedule_Message));
            }
           }
        listSpeakerVal = new List<SelectOption>();
        Set<ID> setProfileID = new Set<ID>();
        for(Profile prof: [select Id, Name from Profile where Name='US Small Animal Rep' OR Name='US Small Animal Manager' ]){
            setProfileID.add(prof.Id);
        }
        if(setProfileID.contains(UserInfo.getProfileId())){
            for(ZTS_US_Speaker_Fee__c  speakerFee : [select ZTS_US_Amount__c, ZTS_US_Speaker_Fee_Type__c from ZTS_US_Speaker_Fee__c 
                                                        where ZTS_US_Contact__c=: speaker.ZTS_US_Contact__c] ){
                if(!(speakerFee.ZTS_US_Speaker_Fee_Type__c.equalsIgnoreCase('Annual Cap') || speakerFee.ZTS_US_Speaker_Fee_Type__c.equalsIgnoreCase('Per Day Max'))){
                    listSpeakerVal.add(new SelectOption('$'+String.valueOf(speakerFee.ZTS_US_Amount__c)+' - '+speakerFee.ZTS_US_Speaker_Fee_Type__c, 
                                                        '$'+String.valueOf(speakerFee.ZTS_US_Amount__c)+' - '+speakerFee.ZTS_US_Speaker_Fee_Type__c));
                }
                if(speaker.id<>null&&speakerFee.ZTS_US_Amount__c==speaker.ZTS_US_Speaker_Fee__c&&speaker.ZTS_US_Speaker_Fee_Type__c ==speakerFee.ZTS_US_Speaker_Fee_Type__c){
                    selectedSpeakerVal='$'+String.valueOf(speakerFee.ZTS_US_Amount__c)+' - '+speakerFee.ZTS_US_Speaker_Fee_Type__c;
                }
                
            }
        }else{
            isCorrectProfile = false;
        }
        if(listSpeakerVal != null && listSpeakerVal.size() == 0)
            listSpeakerVal = new List<SelectOption>{new SelectOption('None','No values associated to the speaker')};
    }
}