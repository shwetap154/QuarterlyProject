/**
 * @description       : Test Class for GigyaService
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 **/
@IsTest
private class GigyaServiceTest {
  private static testMethod void getAPIKeyTest_Success() {
    String apiKey = GigyaService.getAPIKey('ALPHA');
    System.assert(
      !String.isBlank(apiKey),
      'API Key should be returned for ALPHA Market from Custom Metadata Records'
    );
  }

  private static testMethod void getAPIKeyTest_Failure() {
    String apiKey = GigyaService.getAPIKey('FakeMarket');
    System.assert(
      String.isBlank(apiKey),
      'API Key should be blank for Fake Market which does not exist in Custom Metadata Records'
    );
  }
}