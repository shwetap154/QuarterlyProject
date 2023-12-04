/**
 * @description       : Interface for GigyaMarketSettingsSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public interface IGigyaMarketSettingsSelector extends fflib_ISObjectSelector {
  List<Gigya_Market_Setting__mdt> selectAll();
  List<Gigya_Market_Setting__mdt> selectByEnvironmentType(Boolean isSandbox);
}