/*******************************************************************************************************************************************
* File Name     :  PIT_BudgetAllocationControllerTest
* Description   :           
* @author       :  Cloudsense Inc.
* Modification Log
===================================================================================================
* Ver.    Date          Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     12/15         Laxmikanth             Created the Class.
*****************************************************************************************************************************************/

@isTest
public class PIT_BudgetAllocationControllerTest {

    
    static List<User> usrs=new List<User>();
    public static void createTestUser(){
    
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
        newuser.ZTS_EU_Market__c = 'United States';
        usrs.add(newuser);
        insert usrs;
    }
    
    public static testMethod void validateBudgetTBM(){
        createTestuser();
         ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Territory',ZTS_Species__c='Small Animal');
         cterr.ZTS_EU_Market__c = 'United States';
         insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;  
        
        ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(Name='TerrRBD11',ZTS_Field_Force_Name__c='FieldForceName1-',ZTS_EU_Description__c='Terr Desc1-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterr.Id);
        cterrChild.ZTS_EU_Market__c = 'United States';
        insert cterrChild;
        
        ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(Name='TerrRBD2',ZTS_Field_Force_Name__c='FieldForceName2-',ZTS_EU_Description__c='Terr Desc2-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterrChild.Id);
        cterrChild2.ZTS_EU_Market__c = 'United States';
        insert cterrChild2;
        
        ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr2; 
        
       PIT_Budget_Allocation__c bdgt2 = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterrChild.id);
       Insert bdgt2; 
        
       PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
       
       
       test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        budgetcontroller.curRec = usrTerr;
        budgetcontroller.updateAllocs();
        PIT_BudgetAllocationController.randomWithLimit(2);
        }
        test.stoptest();
    }
    
    public static testMethod void validateBudgetisAM(){
        createTestuser();
         ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Area',ZTS_Species__c='Small Animal');
         cterr.ZTS_EU_Market__c = 'United States';
         insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;  
        
        ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(Name='TerrRBD11',ZTS_Field_Force_Name__c='FieldForceName1-',ZTS_EU_Description__c='Terr Desc1-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterr.Id);
        cterrChild.ZTS_EU_Market__c = 'United States';
        insert cterrChild;
        
        ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(Name='TerrRBD2',ZTS_Field_Force_Name__c='FieldForceName2-',ZTS_EU_Description__c='Terr Desc2-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterrChild.Id);
        cterrChild2.ZTS_EU_Market__c = 'United States';
        insert cterrChild2;
        
        ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr2; 
        
       PIT_Budget_Allocation__c bdgt2 = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterrChild.id);
       Insert bdgt2; 
        
       PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
       
       
       test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        budgetcontroller.curRec = usrTerr;
        budgetcontroller.updateAllocs();
        PIT_BudgetAllocationController.randomWithLimit(2);
        }
        test.stoptest();
    }
    
    public static testMethod void validateBudgetisRegion(){
        createTestuser();
         ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal');
         cterr.ZTS_EU_Market__c = 'United States';
         insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;  
        
        ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(Name='TerrRBD11',ZTS_Field_Force_Name__c='FieldForceName1-',ZTS_EU_Description__c='Terr Desc1-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterr.Id);
        cterrChild.ZTS_EU_Market__c = 'United States';
        insert cterrChild;
        
        ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(Name='TerrRBD2',ZTS_Field_Force_Name__c='FieldForceName2-',ZTS_EU_Description__c='Terr Desc2-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterrChild.Id);
        cterrChild2.ZTS_EU_Market__c = 'United States';
        insert cterrChild2;
        
        ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr2; 
        
       PIT_Budget_Allocation__c bdgt2 = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterrChild.id);
       Insert bdgt2; 
        
       PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
       
       
       test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        budgetcontroller.curRec = usrTerr;
        budgetcontroller.updateAllocs();
        PIT_BudgetAllocationController.randomWithLimit(2);
        }
        test.stoptest();
    }
    
    public static testMethod void validateChildBudget(){
        createTestuser();
         ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrTBM',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal');
         cterr.ZTS_EU_Market__c = 'United States';
         insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;  
        
        ZTS_EU_Territory__c cterrChild=new ZTS_EU_Territory__c(Name='TerrRBD11',ZTS_Field_Force_Name__c='FieldForceName1-',ZTS_EU_Description__c='Terr Desc1-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterr.Id);
        cterrChild.ZTS_EU_Market__c = 'United States';
        insert cterrChild;
        
        ZTS_EU_Territory__c cterrChild2=new ZTS_EU_Territory__c(Name='TerrRBD2',ZTS_Field_Force_Name__c='FieldForceName2-',ZTS_EU_Description__c='Terr Desc2-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal', ZTS_EU_Parent_Territory__c = cterrChild.Id);
        cterrChild2.ZTS_EU_Market__c = 'United States';
        insert cterrChild2;
        
        ZTS_EU_Position__c usrTerr2=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterrChild.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr2; 
        
       PIT_Budget_Allocation__c bdgt2 = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterrChild2.id);
       Insert bdgt2; 
        
       PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
       
       
       test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        budgetcontroller.initLoad = false;
        budgetcontroller.impersId = usrs[0].Id;
        budgetcontroller.changeContext();
        budgetcontroller.curRec = usrTerr;
        budgetcontroller.updateAllocs();
        PIT_BudgetAllocationController.randomWithLimit(2);
        }
        test.stoptest();
    }
    
    public static testMethod void validateBudgetABM(){
     createTestuser();
         ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrABM',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Area',ZTS_Species__c='Small Animal');
         cterr.ZTS_EU_Market__c = 'United States';
         insert cterr;
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;
        PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
        test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        }
        test.stoptest();
    }
    
    public static testMethod void validateBudgetRBD(){
     createTestuser();
        PIT_BudgetAllocationController budgetcontroller = new PIT_BudgetAllocationController();
        
        ZTS_EU_Territory__c cterr=new ZTS_EU_Territory__c(Name='TerrRBD',ZTS_Field_Force_Name__c='FieldForceName-',ZTS_EU_Description__c='Terr Desc-',ZTS_EU_Type__c='Region',ZTS_Species__c='Small Animal');
        cterr.ZTS_EU_Market__c = 'United States';
        insert cterr;
        
        
        ZTS_EU_Position__c usrTerr=new ZTS_EU_Position__c(ZTS_EU_Employee__c=usrs[0].id,ZTS_PrimaryUser__c=true,ZTS_EU_Territory__c=cterr.id,ZTS_ChangeFlag__c=ZTS_EU_GlobalConstants.CHANGE_FLAG_STATUS_INSERT);
        insert usrTerr;
        
        
        
        PIT_Budget_Allocation__c bdgt = new PIT_Budget_Allocation__c(PIT_Budget__c=1000,PIT_Allocation_Type__c='Territory',PIT_Fiscal_Year__c= System.today().year(),PIT_Responsible__c=usrs[0].id,PIT_Consumed_Budget__c=500,PIT_Territory__c=cterr.id);
       Insert bdgt;
        test.startTest();
       System.runas(usrs[0]){
        PageReference pageRef = Page.PIT_BudgetAllocation;
        Test.setCurrentPage(pageRef);
        
        
        budgetcontroller.noAccess = false;
        budgetcontroller.getCurYear();
        budgetcontroller.getYears();
        bdgt.PIT_Budget__c=2000;
        update bdgt;
        }
        PIT_BudgetAllocationController.AllocationEntry ae = new PIT_BudgetAllocationController.AllocationEntry();
        ae.territoryId = cterr.Id;
        ae.territoryRespId = cterr.Id;
        test.stoptest();
    }

    public static testmethod void controllerTest(){
        PIT_BudgetAllocationController.AllocationEntry ae = new PIT_BudgetAllocationController.AllocationEntry();
        ae.lastName = 'test';
        ae.firstName = 'test';
        ae.position = 'test';
        ae.allocBelow = 1.0;
        ae.alocId = 'test';
        ae.selected = true;
        ae.subDataComplex = 'test';
        
        
        PIT_BudgetAllocationController.AllocationSubentry ase = new PIT_BudgetAllocationController.AllocationSubentry();
        ase.name = 'test';
        ase.allocation = 1.0;
        ase.consumed = 1.0;
        ase.remaining = 1.0;
        ase.Shipped = 1.0;
        ase.completed = 1.0;
        ase.AdjBudget = 1.0;
        ase.Adjustment = 1.0;
        PIT_BudgetAllocationController.AllocationSubentry ase2 = new PIT_BudgetAllocationController.AllocationSubentry();
        ase2.name = 'test';
        ase2.allocation = 1.0;
        ase2.consumed = 1.0;
        ase2.remaining = 1.0;
        ase2.Shipped = 1.0;
        ase2.completed = 1.0;
        ase2.AdjBudget = 1.0;
        ase2.Adjustment = 1.0;
        
        List<PIT_BudgetAllocationController.AllocationSubentry> aseList = new List<PIT_BudgetAllocationController.AllocationSubentry>();
        
        aseList.add(ase);
        aseList.add(ase2);
        
        ae.subAllocs = aseList;
        
        ae.getSubData();
    }
}