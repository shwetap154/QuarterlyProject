public class PIT_NewCoachingGuideOverrideController {
	
    public PageReference redirectUser(){
    	String recId = ApexPages.currentPage().getParameters().get('ID');
    	if(string.isNotEmpty(recId )){
    		return new PageReference('https://zero.pitcher.com/coachingForm.php?ID=' + recId);	
    	} else {
        	return new PageReference('https://zero.pitcher.com/coachingForm.php');
    	}
    }
    
    public PIT_NewCoachingGuideOverrideController(ApexPages.StandardController ctl){
        
    }
    
}