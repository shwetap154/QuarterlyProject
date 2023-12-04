/**
 * @description       : Checks if current user is an Integration User
 * @author            : Unknown @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-25-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   06-25-2021   Unknown @ Zoetis Inc   Initial Version
**/
public class ZTS_US_UserProfileCheck {

    public static boolean isIntegrationUser(String userId){
        User usr=[SELECT Id,name,ProfileId from User where id =:userId];
        System.debug('$$$ usr: '+usr);
        Integer cnt=[SELECT count() from Profile where Name='Integration Profile' AND id=:usr.ProfileId];
        return cnt!=0?true:false;
    }
}