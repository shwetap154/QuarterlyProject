/**
 * @description       : JS Class for Manage Apex Tests to invoke the main Override JS
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 06-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-09-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-01-2022   Ethan Hirsch @ Zoetis Inc      Update comments
**/
import { LightningElement, api } from "lwc";

export default class CopadoManageApexTestsOverride extends LightningElement {
  // Set recordId this way as it does not appear to be set correctly in HTML alone
  _recordId;
  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;

    if (this._recordId) {
      this.invoke();
    }
  }

  invoke() {
    let thisOverride = this.template.querySelector("c-copado-main-override");
    thisOverride.recordId = this.recordId;
    thisOverride.invoke();
  }
}