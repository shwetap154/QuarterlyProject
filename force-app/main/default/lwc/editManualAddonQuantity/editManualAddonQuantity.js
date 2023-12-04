import { LightningElement, track, api } from 'lwc';

import NotMatchTargetQuantity from '@salesforce/label/c.Does_not_match_target_quantity';
import AddonGroupNumber from '@salesforce/label/c.Add_on_Group_Number';
import MaterialNumber from '@salesforce/label/c.Material_Number';
import Quantity from '@salesforce/label/c.Manual_Add_on_Quantity';
import Description from '@salesforce/label/c.Manual_Add_on_Description';
import TargetQuantity from '@salesforce/label/c.Target_Quantity';
import CurrentQuantity from '@salesforce/label/c.Current_Quantity';
import Price from '@salesforce/label/c.Manual_Add_on_Price';
import Addons from '@salesforce/label/c.Add_ons';

export default class EditManualAddonQuantity extends LightningElement {
  label = {
    NotMatchTargetQuantity,
    AddonGroupNumber,
    MaterialNumber,
    Quantity,
    Description,
    TargetQuantity,
    CurrentQuantity,
    Price,
    Addons
  };

  @api manualAddon;
  @api shipToLocations;

  @track currentQuantity = 0;
  @track includeAddon;
  @track isDisabled; 

  get currQuantityIcon() {
    return this.currentQuantity === this.manualAddon.Quantity ? 'utility:success' : 'utility:error';
  }

  get currQuantityClass() {
    return this.currentQuantity === this.manualAddon.Quantity ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_error';
  }

  get quantityErrorMessage() {
    return this.currentQuantity === this.manualAddon.Quantity ? '' : ' - ' + this.label.NotMatchTargetQuantity;
  }

  // If there is 0 or 1 ship-to, quantity is not editable
  get quantityNotEditable() {
    return !this.shipToLocations || this.shipToLocations.length < 2;
  }

  connectedCallback() {

    console.log('manualAddon mandatory: ', this.manualAddon.ManualAddonMandatory);
    this.currentQuantity = this.manualAddon.Quantity;

    if (this.manualAddon.ManualAddonMandatory) {
      this.includeAddon = true;
      this.isDisabled = true;
      this.onIncludeChange();
    } else {
      this.includeAddon = false;
      this.isDisabled = false;
    }
    
  }

  handleQuantityChange() {
    // Get all the inputs related to the group
    const inputs = Array.from(this.template.querySelectorAll('lightning-input')).filter((inp) => inp.type === 'number');

    // Calculate current Quantity
    const totalSelected = [...inputs].reduce((acc, input) => acc + (input.value ? parseInt(input.value, 0) : 0), 0);

    // For each ship to address, build an object with Ship To, Material and Quantity.
    let shipToAddonKeyQuantity = [];
    [...inputs].forEach((input) => {
      shipToAddonKeyQuantity.push({
        ShipToId: input.ariaLabel,
        AddonKey: this.manualAddon.Key,
        Quantity: input.value ? parseInt(input.value, 0) : 0
      });
    });

    console.log('shipToAddonKeyQuantity', shipToAddonKeyQuantity);

    let addonCopy = { ...this.manualAddon };
    this.currentQuantity = totalSelected;

    let eventArgs = {
      isValid: totalSelected === this.manualAddon.Quantity,
      groupId: 'aa' + this.manualAddon.MaterialNumber,
      shipToQuantity: shipToAddonKeyQuantity,
      addons: [addonCopy]
    };

    console.log('eventArgs', eventArgs);

    const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
    this.dispatchEvent(evnt);
  }

  onIncludeChange() {
    // Toggle the flag
    if (this.manualAddon.ManualAddonMandatory === false) {
      this.includeAddon = !this.includeAddon;
    }

    console.log('im here');

    // Get the inputs
    const inputs = Array.from(this.template.querySelectorAll('lightning-input')).filter((inp) => inp.type === 'number');

    let shipToAddonKeyQuantity;

    // If add-on will be included, set the target Quantity to the input
    if (this.includeAddon) {
      // Set current quantity as 0
      this.currentQuantity = this.manualAddon.Quantity;

      shipToAddonKeyQuantity = [
        {
          ShipToId: this.shipToLocations[0].Id,
          AddonKey: this.manualAddon.Key,
          Quantity: this.manualAddon.Quantity
        }
      ];
    } else {
      // If add-on won't be included, remove all the ship-to information

      // Set all the inputs as 0
      [...inputs].forEach((input) => {
        input.value = 0;
      });

      // Set current quantity as 0
      this.currentQuantity = 0;

      // For each ship to address, build an object with Ship To, Material and Quantity = 0
      shipToAddonKeyQuantity = [];
      [...inputs].forEach((input) => {
        shipToAddonKeyQuantity.push({
          ShipToId: input.ariaLabel,
          AddonKey: this.manualAddon.Key,
          Quantity: 0
        });
      });

      console.log('shipToAddonKeyQuantity', shipToAddonKeyQuantity);
    }

    // Create a shalow copy of the addon
    let addonCopy = { ...this.manualAddon };

    let eventArgs = {
      isValid: true,
      groupId: 'aa' + this.manualAddon.MaterialNumber,
      shipToQuantity: shipToAddonKeyQuantity,
      addons: [addonCopy]
    };

    const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
    this.dispatchEvent(evnt);
  }
}