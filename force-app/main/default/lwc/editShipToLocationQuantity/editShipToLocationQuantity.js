import { LightningElement, api, track } from 'lwc';

import Quantity from '@salesforce/label/c.Ship_to_Quantity';
import ProductName from '@salesforce/label/c.Ship_to_Product_Name';
import CommitmentQuantity from '@salesforce/label/c.Ship_to_Commitment_Quantity';
import CommitmentValue from '@salesforce/label/c.Ship_to_Commitment_Value';

export default class EditShipToLocationQuantity extends LightningElement {
  label = {
    Quantity,
    ProductName,
    CommitmentQuantity,
    CommitmentValue
  };

  @api quoteLines;
  @api baseQuantity = 1;
  @api quantityOverrides;
  @api initialOverQty;
  @api shipToAdd;
  @api displayOverQty;
  @track correctQty;

  hasRendered = false;

  handleQtyOverride(event) {
    const qtyOverrideEvent = new CustomEvent('qtyoverride', {
      detail: { quantity: event.detail.value, quoteLineId: event.target.label }
    });

    this.dispatchEvent(qtyOverrideEvent);
  }

  renderedCallback() {
    if (this.displayOverQty) {
      if (this.quoteLines) {
        let quoteLineList = JSON.parse(JSON.stringify(this.quoteLines));
        let keyList = [];

        quoteLineList.forEach((element) => {
          keyList.push(this.shipToAdd + element.Id);
        });

        let overrideDic = JSON.parse(JSON.stringify(this.initialOverQty));
        keyList.forEach((e) => {
          if (overrideDic[e] !== undefined) {
            this.correctQty = overrideDic[e].Quantity;
          }
        });
        if (this.correctQty === undefined) {
          this.correctQty = this.baseQuantity;
        }
      }
    } else {
      this.correctQty = this.baseQuantity;
    }
  }

  get hasQuantityCommitment() {
    return this.quoteLines && this.quoteLines.some((ql) => ql.CPQ_Commitment_Quantity__c && ql.CPQ_Commitment_Quantity__c > 0);
  }

  get hasValueCommitment() {
    return this.quoteLines && this.quoteLines.some((ql) => ql.CPQ_Commitment_Value__c && ql.CPQ_Commitment_Value__c > 0);
  }
}