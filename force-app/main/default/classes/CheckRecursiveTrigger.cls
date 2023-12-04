/****************************************************************************************************************************************** 
 * Class Name   	: CheckRecursiveTrigger
 * Description    	: The class is used by the triggers to avoid recursive trigger for ZTS_GL_AllCustomEventsTrigger
 					  The trigger is recursive because a calendar event is created when an event is created. This results
 					  in running the update trigger 
 									
 * Created By   : Deloitte Consulting
 * Created Date : May 18th, 2014
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Sameep Agrawal           05/18/2014          Created
 * Saipraneeth				09/19/2018			Added Set: SetofIDs to avoid recursive trigger of ZTS_EU_Account_Trigger
 * Mohamed Seliman			02/10/2020			Added methods from US 
*****************************************************************************************************************************************/
public with sharing class CheckRecursiveTrigger 
{
    public static Set<Id> SetOfIDs = new Set<Id>();
	private static boolean run = true;
    private static boolean conaca =true;
    private static boolean conedu =true;
    public static boolean runOnce()
    {
	    if(run)
	    {
	     	run=false;
	     	return true;
	    }
	    else
	    {
	        return run;
	    }
    }
    
    public static boolean updateconaffonce()
    {
        
        if(conaca)
        {
            conaca=false;
            return true;
        }
        else
        {
            return conaca;
        }
    }
    public static boolean updateeduandcon()
    {
        
        if(conedu)
        {
            conedu=false;
            return true;
        }
        else
        {
            return conedu;
        }
    }
}