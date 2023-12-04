/**
 * @description       : Interface for AddressesSelector
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 08-24-2021
 * @last modified by  : Morgan Marchese @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   07-14-2021   Morgan Marchese @ Zoetis Inc   Initial Version
 **/
public interface IProfilesSelector extends fflib_ISObjectSelector {
    List<Profile> selectById(Set<Id> idSet);
    List<Profile> selectAll();
  }