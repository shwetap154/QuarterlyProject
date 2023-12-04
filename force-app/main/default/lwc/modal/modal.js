/******************************************************************************************************************************************
 * Class Name   : Modal
 * Description  : Lightning web component modal framework
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 20 March 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     03/20/2020          Created.
 *****************************************************************************************************************************************/

import { LightningElement, api } from 'lwc';

export default class Modal extends LightningElement {

    @api recordId;

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    // Use alerts instead of toast to notify user
}