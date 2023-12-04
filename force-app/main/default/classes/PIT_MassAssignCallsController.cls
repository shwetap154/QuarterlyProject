public with sharing class PIT_MassAssignCallsController {
    
    public PIT_Coaching_Guide__c coachingParentRec {get; set;}
    
    
    public class selectionElement {
    	public boolean selected            { get; set;}
    	public Call__c rec                 { get; set;}
    }
    
    public selectionElement[] foundEls     {get; set;}
    
    public PIT_MassAssignCallsController(){
    	Id coachingParentRecId = ApexPages.currentPage().getParameters().get('id');
    	coachingParentRec = [select Id, PIT_Colleague__c, PIT_Coach__c from PIT_Coaching_Guide__c where Id = :coachingParentRecId]; 
    	foundEls = new selectionElement[]{};
    	Call__c[] fEls = [select Id, ZTS_EU_Account__c, ZTS_EU_Status__c, ZTS_EU_Start_Date_Time__c, ZTS_EU_End_Date_Time__c, ZTS_EU_Duration__c, Name, ZTS_EU_Account__r.Name from Call__c where PIT_Coaching_Guide__c = null and CreatedById = :coachingParentRec.PIT_Colleague__c];
    	if(fEls.size() > 0){
            for(Call__c c1 : fEls){
                selectionElement rec1 = new selectionElement();
                rec1.selected = false;
                rec1.rec = c1;
                foundEls.add(rec1);	
    		}
    	}
    }
    
    public PageReference assignCalls(){
        try{
            Call__c[] cals2upd = new Call__c[]{};
            for(selectionELement e1 : foundEls){
                if(e1.selected){
                    e1.rec.PIT_Coaching_Guide__c = coachingParentRec.Id;
                    e1.rec.ZTS_EU_Account__c = e1.rec.ZTS_EU_Account__c;
                    cals2upd.add(e1.rec);
                }
            }
            if(cals2upd.size() > 0){
               update cals2upd;
            }
        } catch (exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error while processing your request. Details: ' + e.getMessage()));
            return null;
        }
    	return goBack();
    }
    
    
    public PageReference goBack(){
        PageReference acctPage = new ApexPages.StandardController(coachingParentRec).view();
        acctPage.setRedirect(true);
        return acctPage;
    }
    
    public static void addEntryToMap(Map<Id, Integer> mIdCoachingGuide2Change, Id parRecId, Integer val){
    	if(mIdCoachingGuide2Change.containsKey(parRecId)){
    		mIdCoachingGuide2Change.put(parRecId, mIdCoachingGuide2Change.get(parRecId) + val);
    	} else {
    		mIdCoachingGuide2Change.put(parRecId, val);
    	}
    }
}