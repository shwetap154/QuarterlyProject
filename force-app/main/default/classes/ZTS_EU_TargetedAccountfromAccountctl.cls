/****************************************************************************************************************************************** 
 * Class Name       : ZTS_EU_TargetedAccountfromAccountctl
 * Description      : Replaced the standard TA record creation from new button on Account related list. 
 *                    Controller for "ZTS_EU_TargetedAccountfromAccount.vfp" (SC-008159)                                 
 * Created By   : Cognizant
 * Created Date : March 5th, 2021
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra(Cognizant)        03/05/2021          Created 
*****************************************************************************************************************************************/

public class ZTS_EU_TargetedAccountfromAccountctl {
    
    public ZTS_EU_Campaign_Account__c campAccnt {set;get;}
    List<ZTS_EU_Campaign_Account__c> listTargetedAcc;
    public String accId {set;get;}
    public boolean isUSAccount = false;
    
    public ZTS_EU_TargetedAccountfromAccountctl(ApexPages.StandardController controller) {
        campAccnt = new ZTS_EU_Campaign_Account__c();
        listTargetedAcc = new List<ZTS_EU_Campaign_Account__c>();
        accId = ApexPages.currentPage().getParameters().get('accId');
        campAccnt.ZTS_EU_Account__c = accId;
        String market = [Select Id,ZTS_EU_Market__c from Account where Id =:accId][0].ZTS_EU_Market__c;
        If (market == 'United States')
        {
            isUSAccount = true;
        }
    }
    
    public PageReference createTA(){
        ZTS_EU_Campaign_Account__c targetedAcc = new ZTS_EU_Campaign_Account__c();
        targetedAcc.ZTS_EU_Campaign__c = campAccnt.ZTS_EU_Campaign__c;
        if(campAccnt.ZTS_EU_Account__c != null){
            targetedAcc.ZTS_EU_Account__c = campAccnt.ZTS_EU_Account__c;
        }
        else { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Account'));}
        targetedAcc.ZTS_EU_Member_Status__c = campAccnt.ZTS_EU_Member_Status__c;
        
        listTargetedAcc = [Select Id, Name, ZTS_EU_Account__c, ZTS_EU_Campaign__c, ZTS_EU_Member_Status__c From ZTS_EU_Campaign_Account__c 
                       where ZTS_EU_Account__c =:campAccnt.ZTS_EU_Account__c AND ZTS_EU_Campaign__c =: campAccnt.ZTS_EU_Campaign__c AND ZTS_EU_Member_Status__c = 'Removed'];
        system.debug('List of existing TA-->'+listTargetedAcc);
        if(isUSAccount == true)
        {
            controlTriggers.execute_ZTS_US_Campaign_Account_Trigger = false;//This will restrict auto campaign member creation on Targeted account creation for US records, Added by Aritra SC-008159
        }
        if (listTargetedAcc.size()>0)
        {
            for(ZTS_EU_Campaign_Account__c ca: listTargetedAcc)
            {
                ca.ZTS_EU_Member_Status__c = 'Added';
            }
            Database.update(listTargetedAcc);
        }
        else{
            Database.insert(targetedAcc);
        }
        PageReference pg = new PageReference('/apex/ZTS_EU_AddContactToCampaign?fromAccount=true&campId='+campAccnt.ZTS_EU_Campaign__c+'&accIds='+ campAccnt.ZTS_EU_Account__c);
        return pg.setRedirect(true);
        
    }
    
    

}