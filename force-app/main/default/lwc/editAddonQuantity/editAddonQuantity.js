import { LightningElement, api, track } from 'lwc';

import QuantityOverMaxMessage from '@salesforce/label/c.Exceeds_Max_Quantity';
import AddonGroupNumber from '@salesforce/label/c.Add_on_Group_Number';
import MaterialNumber from '@salesforce/label/c.Material_Number';
import Quantity from '@salesforce/label/c.Manual_Add_on_Quantity';
import Description from '@salesforce/label/c.Manual_Add_on_Description';
import MaxQuantity from '@salesforce/label/c.Max_Quantity';
import CurrentQuantity from '@salesforce/label/c.Current_Quantity';
import Addons from '@salesforce/label/c.Add_ons';

export default class EditAddonQuantity extends LightningElement {
  label = {
    QuantityOverMaxMessage,
    AddonGroupNumber,
    MaterialNumber,
    Quantity,
    Description,
    MaxQuantity,
    CurrentQuantity,
    Addons
  };

  @api addonGroup;
  @api shipToLocations;
  @api groupIndex;

  @track currentQuantity = 0;

  get displayIndex() {
    return this.groupIndex + 1;
  }

  get currQuantityIcon() {
    return this.currentQuantity <= this.addonGroup.MaxQuantity ? 'utility:success' : 'utility:error';
  }

  get currQuantityClass() {
    return this.currentQuantity <= this.addonGroup.MaxQuantity ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_error';
  }

  get quantityErrorMessage() {
    return this.currentQuantity <= this.addonGroup.MaxQuantity ? '' : ' - ' + this.label.QuantityOverMaxMessage;
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

    console.log('shipToAddonKeyQuantity', shipToAddonKeyQuantity);

    const addonGroupCopy = { ...this.addonGroup };
    let totalSelected = 0;
    let addonsCopy = [];

    for (const addon of addonGroupCopy.RelatedAddons) {
      const addonCopy = { ...addon };
      addonCopy.Quantity = addonKeyQuantity[addon.Key];
      addonsCopy.push(addonCopy);

      // Calculate the total for the group to do the validation
      totalSelected += addonKeyQuantity[addon.Key];
    }

    addonGroupCopy.RelatedAddons = addonsCopy;

    this.addonGroup = addonGroupCopy;
    this.currentQuantity = totalSelected; //this.addonGroup.RelatedAddons.reduce((acc, currValue) => acc + currValue.Quantity, 0);

    let eventArgs = {
      isValid: totalSelected <= this.addonGroup.MaxQuantity,
      groupIndex: this.groupIndex + 1,
      groupId: this.addonGroup.GroupId,
      addons: addonsCopy,
      shipToQuantity: shipToAddonKeyQuantity
    };

    console.log('eventArgs', eventArgs);

    const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
    this.dispatchEvent(evnt);
  }

  parseQuantity(strQuantity) {
    return isNaN(strQuantity) ? 0 : parseInt(strQuantity, 0);
  }
}