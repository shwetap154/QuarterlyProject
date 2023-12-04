import { LightningElement, api, track } from 'lwc';

import NotMatchTargetQuantity from '@salesforce/label/c.Does_not_match_target_quantity';
import AddonGroupNumber from '@salesforce/label/c.Add_on_Group_Number';
import MaterialNumber from '@salesforce/label/c.Material_Number';
import Quantity from '@salesforce/label/c.Manual_Add_on_Quantity';
import Description from '@salesforce/label/c.Manual_Add_on_Description';
import TargetQuantity from '@salesforce/label/c.Target_Quantity';
import CurrentQuantity from '@salesforce/label/c.Current_Quantity';
import Price from '@salesforce/label/c.Manual_Add_on_Price';
import Addons from '@salesforce/label/c.Add_ons';

export default class EditAutomaticAddonQuantity extends LightningElement {
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

  @api automaticAddon;
  @api shipToLocations;

  @track currentQuantity = 0;

  hasRendered = false;

  renderedCallback() {
    if (!this.hasRendered) {
      const inputs = Array.from(this.template.querySelectorAll('lightning-input'));
      if (inputs && inputs.length > 0) {
        inputs[0].value = this.automaticAddon.Quantity;
        this.currentQuantity = this.automaticAddon.Quantity;

        let shipToAddonKeyQuantity = [
          {
            ShipToId: inputs[0].ariaLabel,
            AddonKey: this.automaticAddon.Key,
            Quantity: this.automaticAddon.Quantity
          }
        ];

        console.log('shipToAddonKeyQuantity', shipToAddonKeyQuantity);

        let eventArgs = {
          isValid: true,
          groupId: 'aa' + this.automaticAddon.MaterialNumber,
          shipToQuantity: shipToAddonKeyQuantity
        };

        console.log('eventArgs', eventArgs);

        const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
        this.dispatchEvent(evnt);
      }

      this.hasRendered = true;
    }
  }

  get currQuantityIcon() {
    return this.currentQuantity === this.automaticAddon.Quantity ? 'utility:success' : 'utility:error';
  }

  get currQuantityClass() {
    return this.currentQuantity === this.automaticAddon.Quantity ? 'slds-badge slds-theme_success' : 'slds-badge slds-theme_error';
  }

  get quantityErrorMessage() {
    return this.currentQuantity === this.automaticAddon.Quantity ? '' : ' - ' + this.label.NotMatchTargetQuantity;
  }

  // If there is 0 or 1 ship-to, quantity is not editable
  get quantityNotEditable() {
    console.log('quantityNotEditable', !this.shipToLocations || this.shipToLocations.length < 2);
    return !this.shipToLocations || this.shipToLocations.length < 2;
  }

  handleQuantityChange() {
    // Get all the inputs related to the group
    const inputs = Array.from(this.template.querySelectorAll('lightning-input'));

    // Calculate current Quantity
    const totalSelected = [...inputs].reduce((acc, input) => acc + (input.value ? parseInt(input.value, 0) : 0), 0);

    // For each ship to address, build an object with Ship To, Material and Quantity.
    let shipToAddonKeyQuantity = [];
    [...inputs].forEach((input) => {
      shipToAddonKeyQuantity.push({
        ShipToId: input.ariaLabel,
        AddonKey: this.automaticAddon.Key,
        Quantity: input.value ? parseInt(input.value, 0) : 0
      });
    });

    this.currentQuantity = totalSelected;

    let eventArgs = {
      isValid: totalSelected === this.automaticAddon.Quantity,
      groupId: 'aa' + this.automaticAddon.MaterialNumber,
      shipToQuantity: shipToAddonKeyQuantity
    };

    console.log('eventArgs', eventArgs);

    const evnt = new CustomEvent('quantitychange', { detail: eventArgs });
    this.dispatchEvent(evnt);
  }
}