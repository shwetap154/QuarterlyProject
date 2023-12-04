/**
 * @description       : Test Class for ProfilesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
@IsTest
private class ProfilesSelectorTest {
  private static testMethod void selectByIdTest() {
    Id sysAdminId = [
      SELECT Id
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    List<Profile> profiles = ProfilesSelector.newInstance()
      .selectById(new Set<Id>{ sysAdminId });
    System.assertEquals(
      1,
      profiles.size(),
      'System Admin profile should be queried'
    );

    System.assertEquals('System Administrator',profiles[0].Name,'System Admin profile should be queried');
  }

  private static testMethod void selectAllTest() {
    List<Profile> profiles = ProfilesSelector.newInstance().selectAll();
    System.assertNotEquals(null, profiles, 'Query should return profiles');
    System.assertNotEquals(0, profiles.size(), 'Query should return profiles');
  }
}