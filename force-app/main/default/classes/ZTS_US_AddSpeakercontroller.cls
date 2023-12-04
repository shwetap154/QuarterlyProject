/****************************************************************************************************************************************** 
 * Class Name       : ZTS_US_AddSpeakercontroller
 * Description      : The class is used to do the following 
                      1. Add speakers to the event
                      2. Check for validation rules before saving the record
                      3. Redirect to add contact page
                                    
 * Created By   : Deloitte Consulting
 * Created Date : May 20th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Deloitte                05/20/2014          Created 
*****************************************************************************************************************************************/
public class ZTS_US_AddSpeakercontroller{

    public String eventCat                      {get;set;}
    public String evntId                        {get;set;}
    public ZTS_US_Speaker__c speaker            {get;set;}
    public List<SelectOption> listSpeakerVal    {get;set;}
    public String selectedSpeakerFee            {get;set;}
    public String selectedSpeakerVal            {get;set;}
    public String selectedFeeType               {get;set;}
    public Boolean isCorrectProfile             {get;set;}
    ZTS_Events__c event = new ZTS_Events__c();
    
    public ZTS_US_AddSpeakercontroller(ApexPages.StandardController controller){
        evntId = ApexPages.currentPage().getParameters().get('eventId');
        speaker = (ZTS_US_Speaker__c)controller.getRecord();
        List<ZTS_Events__c> listEvent = [select ZTS_US_Event_Category__c,Name,ZTS_US_Name__c,Copy_Start_Date__c from ZTS_Events__c where Id=: evntId AND ZTS_EU_Market__c != 'United States'];
        if(listEvent != null && listEvent.size() > 0){
            eventCat = listEvent[0].ZTS_US_Event_Category__c;
            event = listEvent[0];
        }
        speaker = new ZTS_US_Speaker__c();
        speaker.ZTS_US_Speaking_Date__c = event.Copy_Start_Date__c;
        speaker.ZTS_US_Event__c = evntId;
        listSpeakerVal = new List<SelectOption>{new SelectOption('None','--None--')};
        isCorrectProfile = true;
    }
    
    /* Save the Speaker record once appropriate values are selected from the page
    */
    public PageReference save(){
        try{
            // Two Speaker records with same Contact and Speaking Date cannot be created
            List<ZTS_US_Speaker__c> listSpeaker = [select ZTS_US_Speaker_Fee_Type__c, ZTS_US_Speaker_Fee__c,ZTS_US_Speaking_Date__c,ZTS_US_Contact__c from ZTS_US_Speaker__c
                                                    where ZTS_US_Speaking_Date__c=: speaker.ZTS_US_Speaking_Date__c and ZTS_US_Contact__c=: speaker.ZTS_US_Contact__c AND ZTS_EU_Market_from_Parent__c = 'United States'];
            if(listSpeaker != null && listSpeaker.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A speaker with same contact and speaking date already exists for the event '+
                                                            event.ZTS_US_Name__c+'. Please select a different contact or speaking date.'));
                return null;
            }
            
            if(selectedSpeakerVal != null && selectedSpeakerVal !='' && selectedSpeakerVal != 'None'){
                speaker.ZTS_US_Speaker_Fee_Type__c = selectedSpeakerVal.split('\\$')[1].split(' - ')[1];
                speaker.ZTS_US_Speaker_Fee__c = Decimal.valueOf(selectedSpeakerVal.split('\\$')[1].split(' - ')[0]);
            }else if(selectedFeeType == '' && selectedSpeakerFee == '' && selectedSpeakerVal == 'None'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected Contact does not have associated Speaker values. Please select another Contact'));
                return null;
            }
            insert speaker;
            PageReference pg = new PageReference('/'+evntId);
            pg.setRedirect(true);
            return pg;
        }catch(Exception e){
            system.debug('----------------exception caught---' + e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return null;
        }
    }
}