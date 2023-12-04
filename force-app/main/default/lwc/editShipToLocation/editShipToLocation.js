import { LightningElement, api, track, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';

import MARKET_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.max_Quantity_to_be_allowed__c';

import searchAccountShipToAddresses from '@salesforce/apex/CustomLookupController.searchAccountShipToAddresses';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ShipToAddress from '@salesforce/label/c.Ship_To_Address';
import RemoveShipToLocation from '@salesforce/label/c.Remove_Ship_To_Location';
import OffersAtLocation from '@salesforce/label/c.Offers_at_Location';
import OverrideQuantities from '@salesforce/label/c.Override_Quantities';
import OverrideQuantitiesOnlyAcillary from '@salesforce/label/c.Quantity_Override_only_Ancillaries';
import LookupErrorMessage from '@salesforce/label/c.Lookup_error_message';
import LookupErrorTitle from '@salesforce/label/c.Lookup_error';
import OnlySelectUpToItems from '@salesforce/label/c.only_select_up_to_items';
import PleaseMakeASelection from '@salesforce/label/c.Please_make_a_selection';
import MaxQuantityAllowedError from '@salesforce/label/c.max_Allowed_Quantity_Error';
import MinQuantityAllowedError from '@salesforce/label/c.min_Allowed_Quantity_Error';

export default class EditShipToLocation extends LightningElement {
  label = {
    ShipToAddress,
    RemoveShipToLocation,
    OffersAtLocation,
    OverrideQuantities,
    OverrideQuantitiesOnlyAcillary,
    LookupErrorMessage,
    LookupErrorTitle,
    OnlySelectUpToItems,
    PleaseMakeASelection,
    MaxQuantityAllowedError,
    MinQuantityAllowedError
  };

  @api shipTo;
  @api qtyValue; 
  @track quoteLines;
  @api index;
  @api quoteId;
  @api notifyViaAlerts = false;
  @api selectedIds;
  @api selectedShipToAddressIds = [];
  @api alreadySelected;
  @api displayOverrideQty;
  @api initialOverQty;
  @api recordId;
  @api isInValid = false;

  quantityOverrides = {};
  multiEntry = false;
  maxSelectionSize = 1;
  initialSelection = [];
  errors = [];
  maxQuantityAllowed = 1;
  maxLocationValue = 9;


  @api
  set shipToQuoteLines(value) {
    this.quoteLines = value;
    
    // Create the overrides for the 
    if (this.quoteLines && this.shipTo && this.shipTo.ShipToAddressId) {
      this.updateShipToQuantityOverrides(
        this.buildSpecificCommitmentOverrides(this.shipTo.BaseQuantity),
        true
      )
    }
  }

  get shipToQuoteLines() {
    return this.quoteLines;
  }
  
  @wire(getRecord, { recordId: '$recordId', fields: [MARKET_FIELD] })
  quote({error, data})
  {
      if(data)
      {
          console.log('CPQ: opp ' + JSON.stringify(data));
          this.maxQuantityAllowed =  getFieldValue(data, MARKET_FIELD);
          console.log('maxQuantityAllowed with method >>> ' + this.maxQuantityAllowed);
      
      }
      else if(error)
      {
          console.log('CPQ: error ' + JSON.stringify(error));
      }
  }


/*  getMarketMaxValue() {
          if(this.maxQuantityAllowed > 9 )
          {
            this.maxLocationValue = this.maxQuantityAllowed;
          }
       else {
        console.log('this.quote inside else block>> ');
          this.maxLocationValue  = 9;
      }
      return this.maxLocationValue;
  }*/

  @api isInputValid() {
    let inputFields = this.template.querySelectorAll('.validate');
    
    inputFields.forEach(inputField => {
        if(!inputField.checkValidity()) {
            inputField.reportValidity();
            console.log('inputField.reportValidity()  ' , inputField.reportValidity());
            this.isInValid = true;
            console.log('this.isInValid ' , this.isInValid);
        }
        else{
          this.isInValid = false;
        }
    });
    return this.isInValid;
}

  connectedCallback() {
    this.recordId = this.quoteId;
    const shipToCopy = { ...this.shipTo };
    if (shipToCopy.ShipToAddressId) {
      this.initialSelection = [
        {
          id: shipToCopy.ShipToAddressId,
          sObjectType: 'Address__c',
          icon: 'custom:custom24',
          title: shipToCopy.ShipToAddressName,
          subtitle: shipToCopy.ShipToAddressAccountName
        }
      ];
    } else {
      this.initialSelection = [];
    }
    this.displayOverrideQty = true;
    this.quantityOverrides = this.initialOverQty;
   this.qtyValue = shipToCopy.BaseQuantity.toString();
    //this.getMarketMaxValue();

    console.log('connectedCallback', JSON.stringify(this.quantityOverrides));
  }

  handleRemoveShipToLocation() {
    //console.log('handleRemoveShipToLocation > index: ' + this.index);

    const event = new CustomEvent('locationremoved', {
      detail: { Id: this.shipTo.Id, index: this.index }
    });

    // Fire the event from c-tile
    this.dispatchEvent(event);
  }

  handleQuantityChange(event) {
    const temp = { ...this.shipTo };
    temp.BaseQuantity = event.detail.value;
    console.log(">>> 1 " ,temp.BaseQuantity );
    this.shipTo = temp;
    this.qtyValue = event.detail.value.toString();
    console.log(">>> 2 " , this.qtyValue);
    console.log(">>> 3  " , this.shipTo);
    const specificCommitmentOverrides = this.buildSpecificCommitmentOverrides(event.detail.value);

    const qtyEvent = new CustomEvent('qtychange', {
      detail: {
        quantity: event.detail.value, 
        Index: this.index,
        overridesToRemove: this.getOverrideKeysForAncillaries(),
        overridesToUpdate: specificCommitmentOverrides,
      }
    });

    // Reset the overrides and initialize it with the specific commitment quantities
    this.setShipToQuantityOverrides(specificCommitmentOverrides);
    
    this.displayOverrideQty = false;
    this.dispatchEvent(qtyEvent);
  }


  getOverrideKeysForAncillaries() {
    let overrideKeysToRemove = [];

    // Iterate thru key-value pairs in the object
    Object.entries(this.quantityOverrides).forEach(([key, override]) => {
      // If the override is associated to a line that's not an specific commitment, it should be removed.
      if (this.quoteLines.some(ql => ql.Id === override.QuoteLineId && ql.Is_Ancillary__c)) {
        overrideKeysToRemove.push(key);
      }
    });

    return overrideKeysToRemove;
  }

  /**
   * Builds an array with the Override information related to the Specific Commitment lines.
   * @param {Number} baseQuantity 
   */
  buildSpecificCommitmentOverrides(baseQuantity) {

    return this.quoteLines 
            ? this.quoteLines
                .filter((ql) => ql.Specific_Commitment__c === true)
                .map(specCommLine => this.buildOverride(specCommLine.Id, baseQuantity * specCommLine.CPQ_Commitment_Quantity__c))
            : [];
  }

  /**
   * Change Quantity Override event handler.
   * @param {*} event 
   */
  handleQtyOverride(event) {
    this.updateShipToQuantityOverrides([this.buildOverride(event.detail.quantity, event.detail.quoteLineId)], true);
  }

  /**
   * Initializes the Quantity Override object
   * @param {*} overridesArray Initial array
   */
  setShipToQuantityOverrides(overridesArray) {
    const overridesCopy = {};

    if (overridesArray) {
      overridesArray.forEach(override => {
        overridesCopy[override.Key] = override;
      });
    }

    this.quantityOverrides = overridesCopy;
  }

  /**
   * Updates the Quantity Override Object.
   * @param {*} overridesArray Overrides to update
   * @param {*} fireEvent Indicates if event should be fired or not
   */
  updateShipToQuantityOverrides(overridesArray, fireEvent) {

    //console.log('updateShipToQuantityOverrides', overridesArray);

    if (overridesArray && overridesArray.length > 0) {
      const overridesCopy = { ...this.quantityOverrides };

      overridesArray.forEach(override => {
        overridesCopy[override.Key] = override;
      });

      this.quantityOverrides = overridesCopy;

      if (fireEvent) {
        this.fireShipToOverrideEvent(overridesArray);
      }
    }    
  }

  /**
   * Fires the 'on ship-to Quantity Override event'
   * @param {*} overridesArray 
   */
  fireShipToOverrideEvent(overridesArray) {
    const qtyOverrideEvent = new CustomEvent('shiptoqtyoverride', {
      detail: { overrides: overridesArray}
    });
    this.dispatchEvent(qtyOverrideEvent);
  }

  /**
   * Builds an Override Quantity object
   * @param {*} quoteLineId 
   * @param {*} quantity 
   */
  buildOverride(quoteLineId, quantity) {
    return {
      QuoteLineId: quoteLineId,
      ShipToId: this.shipTo.RecordId,
      ShipToAddressId: this.shipTo.ShipToAddressId,
      Quantity: quantity,
      Key: this.shipTo.ShipToAddressId + quoteLineId
    };
  }

  handleSearch(event) {   
    const target = event.target;
    searchAccountShipToAddresses({
      searchTerm: event.detail.searchTerm,
      quoteId: this.quoteId,
      selectedAddressIds: this.selectedShipToAddressIds
    })
      .then((results) => {
        target.setSearchResults(results);
      })
      .catch((error) => {
        this.notifyUser(this.label.LookupErrorTitle, this.label.LookupErrorMessage, 'error');
        // eslint-disable-next-line no-console
        console.error('Lookup error', JSON.stringify(error));
        this.errors = [error];
      });
  }

  handleSelectionChange(event) {
    const selection = this.template.querySelector('c-atg-lookup').getSelection();
    console.log({ ...selection });

    let selectionId = '';
    let addressName = '';

    if (selection.length > 0) {
      selectionId = selection[0].id ? selection[0].id : '';
      addressName = selection[0].title ? selection[0].title : '';
    }
    this.checkForErrors();

    // Assign the selected address
    const shipToCopy = {... this.shipTo};
    shipToCopy.ShipToAddressId = selectionId;
    this.shipTo = shipToCopy;

    if (!this.baseQuantity) {
      this.baseQuantity = 1;
    }

    const specificCommitmentOverrides = this.buildSpecificCommitmentOverrides(this.baseQuantity);
    
    const addrEvent = new CustomEvent('shiptoaddresschange', {
      detail: { 
        ShipToAddressId: selectionId,
        ShipToAddressName: addressName,
        Index: this.index,
        overridesToUpdate: specificCommitmentOverrides,
      }
    });
    this.dispatchEvent(addrEvent);

    // Reset the overrides and initialize it with the specific commitment quantities
    this.setShipToQuantityOverrides(specificCommitmentOverrides);
  }

  handleSelectionRemoved(event) {
    this.selectedShipToAddressIds = this.selectedShipToAddressIds.filter((id) => id !== event.detail);
    const removalEvent = new CustomEvent('selectionremoved', {
      detail: event.detail
    });
    this.dispatchEvent(removalEvent);
  }

  checkForErrors() {
    this.errors = [];
    const selection = this.template.querySelector('c-atg-lookup').getSelection();
    // Custom validation rule
    if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
      this.errors.push({ message: this.label.OnlySelectUpToItems.replace('#', this.maxSelectionSize) });
    }
    // Enforcing required field
    if (selection.length === 0) {
      this.errors.push({ message: this.label.PleaseMakeASelection });
    }
  }
  notifyUser(title, message, variant) {
    if (this.notifyViaAlerts) {
      // Notify via alert
      // eslint-disable-next-line no-alert
      alert(`${title}\n${message}`);
    } else {
      // Notify via toast
      const toastEvent = new ShowToastEvent({ title, message, variant });
      this.dispatchEvent(toastEvent);
    }
  }
}