import { LightningElement, track, api } from 'lwc';

import DeviceValueExceededMessage from '@salesforce/label/c.Exceeds_the_Device_value';
import AddonGroupNumber from '@salesforce/label/c.Add_on_Group_Number';
import MaterialNumber from '@salesforce/label/c.Material_Number';
import Quantity from '@salesforce/label/c.Manual_Add_on_Quantity';
import Description from '@salesforce/label/c.Manual_Add_on_Description';
import DeviceValue from '@salesforce/label/c.Device_Value';
import CurrentValue from '@salesforce/label/c.Current_Value';
import UnitPrice from '@salesforce/label/c.Add_on_Unit_Price';
import NetPrice from '@salesforce/label/c.Add_on_Net_Price';
import Addons from '@salesforce/label/c.Add_ons';

export default class EditRxDxAddonQuantity extends LightningElement {
  @api addonGroup;
  @api shipToLocations;
  @api groupIndex;
  @api currencyCode;

  @track currentValue = 0;

  label = {
    DeviceValueExceededMessage,
    AddonGroupNumber,
    MaterialNumber,
    Quantity,
    Description,
    DeviceValue,
    CurrentValue,
    UnitPrice,
    NetPrice,
    Addons
  };

  get displayIndex() {
    return this.groupIndex + 1;
  }

  get currValueIcon() {
    return this.currentValue <= this.addonGroup.MaxValue ? 'utility:success' : 'utility:warning';
  }

  get currValueClass() {
    return this.currentValue <= this.addonGroup.MaxValue ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_warning';
  }

  get valueErrorMessage() {
    return this.currentValue <= this.addonGroup.MaxValue ? '' : ' - ' + this.label.DeviceValueExceededMessage;
  }

  handleQuantityChange() {
    // Get all the inputs related to the group
    const inputs = Array.from(this.template.querySelectorAll('lightning-input'));

    // Calculate Material -> Quantity
    const addonKeyQuantity = [...inputs].reduce((acc, input) => {
      let addonKey = input.label;
      if (!acc[addonKey]) {
        acc[addonKey] = 0;
      }
      acc[addonKey] = acc[addonKey] + (input.value ? parseInt(input.value, 0) : 0);
      return acc;
    }, {});

    // For each ship to address, build an object with Ship To, Material and Quantity.
    let shipToAddonKeyQuantity = [];
    [...inputs].forEach((input) => {
      shipToAddonKeyQuantity.push({
        ShipToId: input.ariaLabel,
        AddonKey: input.label,
        Quantity: input.value ? parseInt(input.value, 0) : 0
      });
    });

    const addonGroupCopy = { ...this.addonGroup };
    let totalSelected = 0;
    let totalValue = 0.0;
    let addonsCopy = [];

    for (const addon of addonGroupCopy.RelatedAddons) {
      const addonCopy = { ...addon };
      addonCopy.Quantity = addonKeyQuantity[addon.Key];
      addonCopy.NetPrice = addonCopy.Quantity * addonCopy.UnitPrice;
      addonsCopy.push(addonCopy);

      // Calculate the total for the group to do the validation
      totalSelected += addonKeyQuantity[addon.Key];
      totalValue += addonCopy.NetPrice;
    }

    addonGroupCopy.RelatedAddons = addonsCopy;

    this.addonGroup = addonGroupCopy;
    this.currentValue = totalValue;
    this.currentQuantity = totalSelected; //this.addonGroup.RelatedAddons.reduce((acc, currValue) => acc + currValue.Quantity, 0);

    let eventArgs = {
      approvalDetails: {
        ApprovalRequired: this.currentValue > this.addonGroup.MaxValue,
        MaxValue: this.addonGroup.MaxValue,
        CurrValue: this.currentValue,
        Suffix: this.addonGroup.Suffix
      },
      isValid: true,
      groupIndex: this.groupIndex + 1,
      groupId: this.addonGroup.GroupId,
      addons: addonsCopy,
      shipToQuantity: shipToAddonKeyQuantity
    };

    const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
    this.dispatchEvent(evnt);
  }
}