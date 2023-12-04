/**
 * @description       : Test Class for Org.cls
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             : Test Classes
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
@isTest
public class OrgTest {
  private static testMethod void testOrgMethods() {
    Organization thisOrg = [
      SELECT IsSandbox, OrganizationType
      FROM Organization
      LIMIT 1
    ];
    System.assertEquals(
      thisOrg.isSandbox,
      Org.isSandbox(),
      'IsSandbox should match current Org query'
    );
    System.assertEquals(
      thisOrg.OrganizationType,
      Org.OrganizationType(),
      'OrganizationType should match current Org query'
    );
  }

  private static testMethod void getProfileMapByName() {
    Map<String,Profile> mapProfiles = Org.getProfileMapByName();
    Map<String,Profile> mapProfiles2 = Org.getProfileMapByName();
    System.assertNotEquals(0, mapProfiles.size(), 'Profiles should be returned');
    System.assert(mapProfiles === mapProfiles2,'The map should be a singleton, each return should be the same map');
  }
}