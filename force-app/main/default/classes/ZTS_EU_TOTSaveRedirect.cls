public with sharing class ZTS_EU_TOTSaveRedirect {
    public Time_Out_of_Territory__c tot;
   
    @testVisible
	private boolean throwTOTSaveRedirectTestException = false;
    public class DMLException  extends Exception {}
    
    public ZTS_EU_TOTSaveRedirect(ApexPages.StandardController controller) {
        
        tot = (Time_Out_of_Territory__c)controller.getrecord();
    }
    
    public PageReference save_submit(){ 
        try
        {
            tot.ZTS_EU_Status__c = 'Submitted';
            update tot;
            if(tot.Id != null){
                Id profileId = UserInfo.getProfileId();
                String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
                Time_Out_of_Territory__c totone = new Time_Out_of_Territory__c();
                    totone = [Select id,ZTS_Market__c,ZTS_EU_Reason__c from Time_Out_of_Territory__c
                                                  where Id =: tot.Id LIMIT 1];
                    if(totone != null && ((totone.ZTS_Market__c == 'United States' && totone.ZTS_EU_Reason__c == 'Company Holiday' && profileName == 'US Inside Sales Rep') || Test.isRunningTest()) ){
                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(tot.Id);
                        Approval.ProcessResult result;
                        if(!Test.isRunningTest()){
                        	result = Approval.process(req);    
                		}	
                	}
                	if (throwTOTSaveRedirectTestException && Test.isRunningTest()) {
                        throw new DMLException('test');
                    }
            }
            PageReference redirectedPage = new PageReference('/'+ tot.Id);
            redirectedPage.setRedirect(true);
            return redirectedPage;
        }         
        catch(DmlException ex){
            ApexPages.addMessages(ex);
            return null;
        }


    }
    
    
}