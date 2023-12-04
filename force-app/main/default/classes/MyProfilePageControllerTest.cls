/**
 * An apex class that updates details of a portal user.
   Guest users are never able to access this page.
 */
@IsTest 
public with sharing class MyProfilePageControllerTest {

    @IsTest
    static void testSave() {
        
        User usr = new User();
        usr = ZTS_EU_DataUtilityTest.createUserWithProfile('System Administrator', false);
        usr.FirstName = 'davidUser';
        usr.zts_eu_market__c = 'United States';
        insert usr;

        System.runAs(usr){
             // Modify the test to query for a portal user that exists in your org
            User currentUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.getIsEdit() == true);
            controller.cancel();
            System.assert(controller.getIsEdit() == false);
            
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));
            
            String randFax = Math.rint(Math.random() * 1000) + '5551234';
            controller.getUser().Fax = randFax;
            controller.save();
            System.assert(controller.getIsEdit() == false);
            
            currentUser = [Select id, fax from User where id =: currentUser.Id];
            System.assert(currentUser.fax == randFax);

        }
       
    }
}