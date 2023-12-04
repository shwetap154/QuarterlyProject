import { LightningElement, api, wire, track } from 'lwc';
import getShipToLocations from '@salesforce/apex/EditShipToLocationsController.getShipToLocations';
import getQuoteLines from '@salesforce/apex/EditShipToLocationsController.getQuoteLines';
import saveShipToConfigurations from '@salesforce/apex/EditShipToLocationsController.saveShipToConfigurations';

import AddShipToLocation from '@salesforce/label/c.Add_Ship_To_Location';
import Save from '@salesforce/label/c.Ship_To_Page_Save';
import Cancel from '@salesforce/label/c.Ship_to_Page_Cancel';
import ConfigureShipToTitle from '@salesforce/label/c.Configure_Ship_to_Page_Title';
import AddressCannotBeNull from '@salesforce/label/c.Please_complete_lookup_field';

export default class ConfigureShipToLocationsAndQuantities extends LightningElement {
  label = {
    AddShipToLocation,
    Save,
    Cancel,
    ConfigureShipToTitle,
    AddressCannotBeNull
  };

  @api quoteId;
  @track shipToLocations = [];
  @api quoteLines;
  @track selectedShipToAddressIds = [];
  @track quantityOverrides = {};
  @api initialOverQty;
  @api isInValid;

  @track isLoading = true;

  @wire(getShipToLocations, { quoteId: '$quoteId' })
  wiredShipTos(value) {
    if (value.error) {
      console.log('ERROR: ', value.error);
    } else if (value.data) {
      this.shipToLocations = value.data;

      value.data.forEach((shipTo) => {
        this.selectedShipToAddressIds.push(shipTo.ShipToAddressId);

        shipTo.QuantityOverrides.forEach((qtyOverride) => {
          this.quantityOverrides[qtyOverride.Key] = {
            Id: qtyOverride.Id,
            QuoteLineId: qtyOverride.QuoteLineId,
            ShipToId: qtyOverride.ShipToId,
            ShipToAddressId: qtyOverride.ShipToAddressId,
            Quantity: qtyOverride.Quantity,
            Key: qtyOverride.Key
          };
        });
      });

      console.log('wiredShipTos', JSON.stringify(this.quantityOverrides));

      this.initialOverQty = this.quantityOverrides;
      this.isLoading = false;
    }
  }

  @wire(getQuoteLines, { quoteId: '$quoteId' })
  wiredQuoteLines(value) {
    if (value.error) {
      console.log('ERROR: ', value.error);
    } else if (value.data) {
      this.quoteLines = value.data;
    }
  }


  handleAddShipToLocationClick(event) {
    this.shipToLocations = this.shipToLocations.concat([
      {
        RecordId: '',
        BaseQuantity: 1,
        QuoteId: this.quoteId,
        ShipToAddressId: '',
        IsDefaultShipTo: false,
        Index: this.shipToLocations.length + 1
      }
    ]);

    console.log('Add new location > Overrides', this.quantityOverrides);
  }

  handleLocationRemoved(event) {
    const shipToLocationsCopy = [...this.shipToLocations];

    // Get the ship-to location to be removed using the index
    const shipTo = shipToLocationsCopy[event.detail.index];

    var addressIdsCopy = [...this.selectedShipToAddressIds];

    addressIdsCopy = addressIdsCopy.filter((id) => id !== shipTo.ShipToAddressId);
    this.selectedShipToAddressIds = addressIdsCopy;

    // Ship to override deletions that apply to this removed ship to will be handled in Apex
    this.shipToLocations = this.shipToLocations.filter((value, index) => index !== event.detail.index);

    // Remove the Overrides associated with this adress
    this.removeOverridesByShipToAddress(shipTo.ShipToAddressId);
  }

  handleShipToAddressChange(event) {
    const index = event.detail.Index;
    const shipToLocationsCopy = [...this.shipToLocations];
    const oldShipTo = shipToLocationsCopy[index];
    const newShipTo = {
      RecordId: this.shipToLocations[index].RecordId,
      BaseQuantity: this.shipToLocations[index].BaseQuantity,
      QuoteId: this.quoteId,
      ShipToAddressId: event.detail.ShipToAddressId,
      ShipToAddressName: event.detail.ShipToAddressName,
      IsDefaultShipTo: this.shipToLocations[index].IsDefaultShipTo,
      Index: this.shipToLocations[index].Index
    };
    if (event.detail.ShipToAddressId !== '') {
      this.selectedShipToAddressIds.push(event.detail.ShipToAddressId);
    }
    shipToLocationsCopy[index] = newShipTo;
    this.shipToLocations = shipToLocationsCopy;

    // Remove the Overrides related to the other ship-to address
    if (!!oldShipTo && !!oldShipTo.ShipToAddressId) {
      this.removeOverridesByShipToAddress(oldShipTo.ShipToAddressId);
    }

    // Populate the overrides related to Specific Commitment for the new ship-to address
    this.updateShipToOverrides(event.detail.overridesToUpdate);

    console.log('Address Changed > Overrides', JSON.stringify(this.quantityOverrides));
  }

  handleQtyChange(event) {
    const shipToLocationsCopy = [...this.shipToLocations];
    const index = event.detail.Index;

    const tempShipTo = {
      RecordId: this.shipToLocations[index].RecordId,
      BaseQuantity: event.detail.quantity,
      QuoteId: this.quoteId,
      ShipToAddressId: this.shipToLocations[index].ShipToAddressId,
      IsDefaultShipTo: this.shipToLocations[index].IsDefaultShipTo,
      ShipToAddressName: this.shipToLocations[index].ShipToAddressName,
      ShipToAddressAccountName: this.shipToLocations[index].ShipToAddressAccountName,
      Index: this.shipToLocations[index].Index
    };

    shipToLocationsCopy[index] = tempShipTo;
    this.shipToLocations = shipToLocationsCopy;

    // Remove Ancillary-related overrides
    this.removeOverridesByKey(event.detail.overridesToRemove);

    // Update specific commitment related overrides
    this.updateShipToOverrides(event.detail.overridesToUpdate);
  }

  handleQtyOverride(event) {
    if (event && event.detail &&  event.detail.overrides) {
      event.detail.overrides.forEach(override => {
        this.quantityOverrides[override.Key] = override;
      }); 
    }

    console.log('handleQtyOverride', JSON.stringify(this.quantityOverrides));
  }

  handleSelectionRemoved(event) {
    this.selectedShipToAddressIds = this.selectedShipToAddressIds.filter((id) => id !== event.detail);
    this.removeOverridesByShipToAddress(event.detail);

    
    console.log('handleSelectionRemoved', JSON.stringify(this.quantityOverrides));
  }

  handleCancel() {
    window.location.replace('/apex/sbqq__sb?id=' + this.quoteId);
  }

  handleSave() {
    console.log('handleSave', JSON.stringify(this.quantityOverrides));

    this.isLoading = true;
    const addressCannotBeNullError = this.label.AddressCannotBeNull;
    
    var childVar = this.template.querySelector("c-edit-ship-to-location").isInputValid();
    console.log('validity report inside parent' , childVar);
    if(childVar)
    {
        this.isLoading = false;
    }
    else{

    
    saveShipToConfigurations({
      updatedShipToLocations: this.shipToLocations,
      overrides: Object.values(this.quantityOverrides),
      quoteId: this.quoteId
    })
      .then((result) => {
        console.log('Apex result', result);
        //redirect URL passed back via apex
        window.location.replace(result);
        this.isLoading = false;
      })
      .catch((error) => {
        console.log('error: ', error.message);
        alert(addressCannotBeNullError);
        this.isLoading = false;
      });
  }
}

  /**
   * Removes all the Overrides associated with a Ship-to Address
   * @param {String} shipToAddressId 
   */
  removeOverridesByShipToAddress(shipToAddressId) {
    if (this.quantityOverrides) {
      // Array to stores the keys to be removed.
      let overrideKeysToRemove = [];

      // Iterate thru key-value pairs in the object
      Object.entries(this.quantityOverrides).forEach(([key, override]) => {
        // If the override is associated to the address, add the key 
        if (override.ShipToAddressId === shipToAddressId) {
          overrideKeysToRemove.push(key);
        }
      });
    }
  }

  /**
   * Updates the Override object based on the overrides passed as parameter
   * @param {*} overridesToUpdate 
   */
  updateShipToOverrides(overridesToUpdate) {  
    overridesToUpdate.forEach((override) => {
      this.quantityOverrides[override.Key] = override;
    });
  }

  /**
   * Remove the overrides from the object
   * @param {*} overrideKeysToRemove 
   */
  removeOverridesByKey(overrideKeysToRemove) {
    overrideKeysToRemove.forEach(key => {
      delete this.quantityOverrides[key];
    });
  }
}