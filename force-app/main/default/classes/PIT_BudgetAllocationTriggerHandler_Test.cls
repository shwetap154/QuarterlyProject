@isTest
public class PIT_BudgetAllocationTriggerHandler_Test{
    static List<User> usrs=new List<User>();
        public static void createTestUser(){
        Test.startTest();
        Profile profiles=[Select Id From Profile Where Name='US Small Animal Rep'];
        User newuser=new User();
        newuser.profileid=profiles.Id;
        newuser.email='testem@deneme.com';
        newuser.username='testem@deneme1.com';
        newuser.lastname='testem';
        newuser.alias='testem';
        newuser.languagelocalekey='en_US';
        newuser.localesidkey='en_US';
        newuser.timezonesidkey='America/Los_Angeles';
        newuser.localesidkey='en_US';  
        newuser.EmailEncodingKey='ISO-8859-1';
        newuser.PIT_Coaching_Group__c='TBM';
        newuser.zts_eu_market__c = 'United States';
        usrs.add(newuser);
        insert usrs;
}
public static testMethod void onBeforeInserttest(){
    list<PIT_Budget_Allocation__c> objBudalloc = new  list<PIT_Budget_Allocation__c>();
    List<ZTS_EU_Position__c> usrterry = new List<ZTS_EU_Position__c>();
    createTestuser();
    ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',
                                                        ZTS_Field_Force_Name__c='FieldForceName-',
                                                        ZTS_EU_Description__c='Terr Desc-',
                                                        ZTS_Type__c='Area',
                                                        ZTS_Species__c='Small Animal',
                                                        ZTS_EU_Market__c = 'United States');
    insert cterr;


    ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(
                                                        Name='TerrRBD11',
                                                        ZTS_Field_Force_Name__c='FieldForceName1-',
                                                        ZTS_EU_Description__c='Terr Desc1-',
                                                        ZTS_Type__c='Region',
                                                        ZTS_Species__c='Small Animal', 
                                                        ZTS_EU_Parent_Territory__c = cterr.Id,
                                                        ZTS_EU_Market__c = 'United States'
                                                        );
    insert cterrChild;

    ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(
                                                        Name='TerrRBD2',
                                                        ZTS_Field_Force_Name__c='FieldForceName2-',
                                                        ZTS_EU_Description__c='Terr Desc2-',
                                                        ZTS_Type__c='Region',
                                                        ZTS_Species__c='Small Animal', 
                                                        ZTS_EU_Parent_Territory__c = cterrChild.Id,
                                                        ZTS_EU_Market__c = 'United States');
    insert cterrChild2;

    ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
    insert usrTerr2; 

    PIT_Budget_Allocation__c bdgt2 = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterrChild.id);
    Insert bdgt2; 

    PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
    insert  bdgt;

    bdgt.PIT_External_ID__c = String.valueOf(bdgt.PIT_Territory__c) + String.valueOf(bdgt.PIT_Fiscal_Year__c);
    objBudalloc.add(bdgt);
    Update  objBudalloc;

    ZTS_EU_Position__c usrTerr = new ZTS_EU_Position__c(ZTS_EU_Territory__c=cterr.id,ZTS_PrimaryUser__c=true,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
    insert usrTerr;
    
    usrTerr.ZTS_EU_Employee__c = usrs[0].id;
    usrterry.add(usrTerr);
    update usrterry;

    PIT_BudgetAllocationTriggerHandler PITbudlt = new PIT_BudgetAllocationTriggerHandler();
    PITbudlt.onBeforeInsert(objBudalloc);
    PITbudlt.onBeforeUpdate(objBudalloc);
    //PIT_BudgetAllocationTriggerHandler.updateBudgetOwner(usrterry);

}
}