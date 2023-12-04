import { LightningElement, wire, api,track } from 'lwc';
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class ActionPlanRelatedFiles extends LightningElement {
    @api filesList;
    actiondata;
  
    async DeleteFileHandler(event) {
        const fileId = event.target.getAttribute('data-fileid');
        console.log(fileId);
        await deleteRecord(fileId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record deleted",
                        variant: "success"
                    })
                )   
            })
        this.dispatchEvent(new CustomEvent("refresh"));
    }
}