@IsTest
private class PicklistsServiceTest {
  
    @IsTest
    private static void getActivePicklists_TEST() {
    Set<String> values = PicklistsService.getActivePicklistValues(
      'Case',
      'Type'
    );
    System.assert(
      !values.isEmpty(),
      'We should get back the Active Picklist Values'
    );
  }

  @IsTest
  private static void getAllPicklists_TEST() {
    Set<String> values = PicklistsService.getAllPicklistValues(
      'Case',
      'Type'
    );
    System.assert(
      !values.isEmpty(),
      'We should get back Picklist Values'
    );
  }
}