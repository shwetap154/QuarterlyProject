/**
 * @description       : JS for rotation of Copado licenses. 
 *                      This class will make sure the current user has a Copado license before navigating them to the next page.
 * @author            : Morgan Marchese @ Zoetis Inc
 * @group             :
 * @last modified on  : 06-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                         Modification
 * 1.0   03-09-2022   Morgan Marchese @ Zoetis Inc   Initial Version
 * 1.1   06-01-2022   Ethan Hirsch @ Zoetis Inc      Code cleanup, add error handling, and code comments
 **/
import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from 'lightning/actions';
import checkLicense from "@salesforce/apex/CopadoGlobalAPIService.checkLicense";
import releaseLicense from "@salesforce/apex/CopadoGlobalAPIService.releaseLicense";
import assignLicense from "@salesforce/apex/CopadoGlobalAPIService.assignLicense";
import currentUserId from "@salesforce/user/Id";

export default class CopadoMainOverride extends NavigationMixin(
  LightningElement
) {
  @api sourceAction;
  @api recordId;
  redirectURL = "";

  @api async invoke() {
    let hasLicense = false;
    let licenseAvailable = false;
    let licenseAssigned = false;

    hasLicense = await checkLicense({ userId: currentUserId });

    if (hasLicense) {
      // Success
      this.navigateToPage();
    } else {
      // Acquire License
      licenseAvailable = await releaseLicense({ userId: currentUserId });

      if (licenseAvailable) {
        licenseAssigned = await assignLicense({ userId: currentUserId });

        if (licenseAssigned) {
          // Also Success
          this.navigateToPage();
        } else {
          // Error
          this.handleAssignmentFailure();
        }
      } else {
        // Error
        this.handleAssignmentFailure();
      }
    }
  }

  handleAssignmentFailure() {
    // Display Error 
    this.startToast('Assignment Failure', 
      'An error occurred granting you access to Copado. Please contact the deployment admin.', 
      'error');
    
    // Close the Screen Action
    // As of Summer '22, This currently doesn't work from a child component. It will work in Winter '23.
    // https://github.com/salesforce/lwc/issues/2722
    this.dispatchEvent(new CloseActionScreenEvent({bubbles: true, composed: true}));
  }

  startToast(title, msg, type) {
    let event = new ShowToastEvent({
      title: title,
      message: msg,
      variant: type,
    });
    this.dispatchEvent(event);
  }

  navigateToPage() {
    this.setURL(this.sourceAction);
    // Set the second parameter to true to remove this action from the browser history
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: this.redirectURL,
      },
    }, true);
  }

  setURL(actionSource) {
    if (actionSource == "AddApexTests") {
      this.redirectURL =
        "/apex/copado__AddTestClasses?scontrolCaching=1&id=" + this.recordId;
    } else if (actionSource == "ManageApexTests") {
      this.redirectURL =
        "/apex/copado__UserStoryApexTestResults?scontrolCaching=1&id=" +
        this.recordId;
    } else if (actionSource == "CommitWork") {
      this.redirectURL =
        "/apex/copado__GitCommitMain?variant=userstorycommit&userStoryId=" +
        this.recordId;
    } else if (actionSource == "ValidateChanges") {
      this.redirectURL =
        "/apex/copado__UserStoryPageWaitingFor?id=" +
        this.recordId +
        "&type=co_validation";
    } else {
      this.redirectURL = "/" + this.recordId;
    }
  }
}