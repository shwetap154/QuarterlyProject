import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getOrderRecord from '@salesforce/apex/alphaCreateOrder.getOrderRecord';
import prepareData from '@salesforce/apex/alphaCreateOrder.prepareData';
import saveOrder from '@salesforce/apex/alphaCreateOrder.saveOrder';
import updateOrder from '@salesforce/apex/alphaCreateOrder.updateOrder';
import updateOrderStatus from '@salesforce/apex/alphaCreateOrder.updateOrderStatus';
import getModeofTransport from '@salesforce/apex/alphaCreateOrder.getModeofTransport';
import adobeSendForSignature from '@salesforce/apex/alphaCreateOrder.adobeSendForSignature';
import changeOrderStatus from '@salesforce/apex/alphaCreateOrder.changeOrderStatus';
import sendForSignatureRemote from '@salesforce/apex/alphaCreateOrder.sendForSignatureRemote';
import basePath from '@salesforce/community/basePath';
import getFileFromAgreement from '@salesforce/apex/alphaCreateOrder.getFileFromAgreement';
import addProductOrder from '@salesforce/apex/alphaCreateOrder.addProductOrder';
import downloadFile from '@salesforce/apex/alphaCreateOrder.downloadFile';
import { getRecord } from 'lightning/uiRecordApi';



export default class AlphaCreateOrderForm extends NavigationMixin(LightningElement) {

    renderedCallback() {

        Promise.all([
            loadScript(this, Zoetis_Static_Resources + '/js/jquery.min.js'),
            loadScript(this, Zoetis_Static_Resources + '/js/zoetis_global_scripts.js'),
            loadStyle(this, Zoetis_Static_Resources + '/css/zoetis_global_styles.css'),
        ])
            .then(() => {
                //alert('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    @track modeOptions;
    @track orderData = '';
    @track loaded = false;
    @track showOtherDoc = false;
    @track openModal = true;
    @track supplyPoint;
    @track supplyPointValue = '';
    @track shipToAddrOptions;
    @track showPercentageFOC = false;
    @track showFOCQuantity = false;
    @track showDiscount = false;
    @track showDownload = false;
    @track showSendSignature = false; //Added by NamrataP [7/13] -- AdobeSign Implemetation
    @track showSubmit = false;
    @track showEdit = true;
    @track triggerSign = false;
    //@track esignPresent = true;
    @track isReadOnly = false;
    @track isEdit = false;
    @track contactOptions = '';
    @track modalClosedNoSelection = false;
    @track responValue = [];
    @api orderRecordId = '';
    @api mode = 'Create';
    @track isSaved = false;
    @track modalClosedNoSelection = false;
    // @track defaultSupplyPoint = '';
    supplyPointCurrency = [];
    @api supplypointgb = '';
    @api telrequired;
    @api showShippingDoc;
    @api showAttachments;
    @api showReqdeliveryDate;
    @track showAddProductModal = false;
    @track index = 0;
    @track id;
    @track name;
    @track downLoadOneFile;
    @track attachmentDetails;
    @track addProductRecord;
    @track loading = false;
    @track selectedProductId ;

    connectedCallback() {
        this.telrequired = true;
        this.showShippingDoc = true;
        this.showReqdeliveryDate = true;
        this.showAttachments = true;
        getModeofTransport().then(data => {
            // console.log('Incoming Data==>',data)
            //loading the mode of transport options..
            this.modeOptions = data.modeOfTransport.map((item) => {
                return { label: item, value: item };
            });
            //loading supply point options...
            //  
            let setObj = new Set();
            let suppvalue = data.lstMatPrice.reduce((acc, e) => {
                if (!setObj.has(e.Sales_Organization__c)) {
                    setObj.add(e.Sales_Organization__c, e)
                    acc.push(e)
                }
                return acc;
            }, []);

            this.supplyPoint = suppvalue.map((item) => {
                // if(item.Market__c == 'Belgium')
                // {
                //     this.defaultSupplyPoint =  item.Sales_Organization__c;
                // }  
                this.supplyPointCurrency.push({ supplypoint: item.Sales_Organization__c, currency: item.CurrencyIsoCode })
                return { label: item.Market__c, value: item.Sales_Organization__c };
            });
            if (suppvalue.length === 1 && !this.orderRecordId) {
                this.supplypointgb = suppvalue[0].Sales_Organization__c;
                this.handleSupplyPoint();

            }

        }).catch(err => {
            console.log("Error Occured: ", err);
        })
        console.log('Check Id', this.orderRecordId);
        //this code will fire for edit & view..    
        if (this.orderRecordId != '') {
            this.isReadOnly = (this.mode == 'Show') ? true : false;
            this.isEdit = (this.mode == 'Edit') ? true : false;
            this.showDownload = (this.isEdit) ? false : true;
            this.showSendSignature = (this.isEdit) ? false : true; //Added by NamrataP [7/13] -- AdobeSign Implemetation
            this.openModal = false;
            this.isSaved = true;
            // call server to get order data..
            getOrderRecord({ orderId: this.orderRecordId }).then((result) => {
                
                let temp = JSON.parse(JSON.stringify(result));
                console.log('temp===>' + JSON.stringify(temp));
                temp.lstOrdItm = temp.lstOrdItm.map((item) => {
                    return {
                        Id: item.Id,
                        discount: item.discount,
                        freeOfChargeQuantity: (item.percentageOfFreeCharge * item.quantity) / 100,
                        percentageOfFreeCharge: item.percentageOfFreeCharge,
                        prodName: item.prodName,
                        quantity: item.quantity,
                        reqDeliveryDate: item.reqDeliveryDate,
                        sapMaterialNo: parseInt(item.sapMaterialNo, 10).toString(),
                        totalprice: this.calculateOrderItemPrice(this.calculateFOCQuantity(item.percentageOfFreeCharge, item.quantity), item.quantity, item.unitPrice, temp.market, temp.country, item.discount),
                        unitPrice: item.unitPrice,
                        pricebookentryId: item.pricebookentryId,
                        uom: item.uom
                    }
                })
                console.log('Intial==>', temp.lstOrdItm);

                this.contactOptions = temp.lstContact.map((item) => {
                    return { label: item.Name, value: item.Id };
                })

                this.shipToAddrOptions = temp.shipToAddrOptions.map((item) => {
                    return { label: item.Full_Address__c, value: item.Id };
                })

                this.attachmentDetails = temp.attachmentDetails.map((item) => {
                    return {
                        name: item.name,
                        contentSize: item.contentSize,
                        contentType: item.contentType,
                        Id: item.Id,
                    }
                })
                this.orderData = temp;
                this.orderData.contactName = this.orderData.lstContact.filter((item) => { return item.Id == this.orderData.userId })[0].Name;
                this.orderData.Id = this.orderRecordId;
                this.shippingDocPrep();
                this.doSetFields(this.orderData.market);
                this.doShowhide(this.orderData.market, this.orderData.country);
                // If the order is already Submitted, don't show Send for Signature or Edit anymore
                if (this.orderData.status == 'Submitted') {
                    this.showSendSignature = false;
                    this.showEdit = false;
                }
                //If the Order Market is Panama or Costa Rica Show Submit button instead Send For Signature button
                if (this.orderData.market === 'Panama' || this.orderData.market === 'Costa Rica') {
                    this.showSendSignature = false;
                    if (this.orderData.status === "Draft") {
                        this.showSubmit = true;
                    }
                }                  
                this.orderData.grandTotal = this.calculateTotalPrice();
                // this.selTransmode =  this.orderData.modeOfTransport;
                // this.shipToAddr =  this.orderData.shipToAddr.Id; 
                this.loading = false;
                this.loaded = true;
            })

                .catch((err) => {
                    console.log('Error==>', err);
                })
        }
    }

    submitHandler(event) {
        let evt = new ShowToastEvent({
            title: "Submitting Order",
            message: "Please wait, your documents are being submitted",
            variant: "info",
        });
        this.dispatchEvent(evt);
        if (this.orderData.Id) {
            changeOrderStatus({ orderId: this.orderData.Id })
                .then(result => {
                    const insertSuccess = JSON.parse(JSON.stringify(result));
                    console.log('result===>', insertSuccess);
                    if (result) {
                        let evt = new ShowToastEvent({
                            title: "Success",
                            message: "Order Submitted Succesfully",
                            variant: "success",
                        });
                        this.dispatchEvent(evt);


                        // Redirect to Order Page after Successful Send to Adobe for ALPHA-102 (on JIRA)  
                        window.location.href = window.location.origin + basePath + '/orders';
                    } else {
                        let evt = new ShowToastEvent({
                            title: "Error",
                            message: "Error occurred while submitting Order",
                            variant: "error",
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    let evt = new ShowToastEvent({
                        title: "Error",
                        message: "Error occurred while submitting Order",
                        variant: "error",
                    });
                    this.dispatchEvent(evt);
                })
        }
    }


    shippingDocPrep = () => {
        let temp = this.orderData.lstShippingDocs.map((item) => {
            return {
                docType: item.docType,
                originalByCourier: item.originalByCourier,
                elecByEmail: item.elecByEmail,
                docRemarks: item.docRemarks,
                Id: item.Id,
                isOtherVisible: (item.docType == 'Other') ? true : false
            }
        })

        this.orderData.lstShippingDocs = temp;
    }

    
    //assuming this.orderData.market will have correct value
    //added a case for ALPHA market and made showDiscount to true for Maghreb, MiddleEast as part of TPDEV-711
    doShowhide = (market, country) => {
        switch (market) {
            case 'ALPHA' :
                this.showFOCQuantity = true;
                this.showDiscount = true;
                this.showPercentageFOC = true;
                break;
            case 'Maghreb':
                this.showPercentageFOC = true;
                this.showFOCQuantity = true;
                this.showDiscount = true;
                break;
            case 'Middle East':
                this.showPercentageFOC = true;
                this.showFOCQuantity = true;
                this.showDiscount = true;
                if (country == 'Israel')
                    this.showDiscount = true;
                break;
            case 'Israel':
                this.showDiscount = true;
                break;
        }

    }

    doSetFields = (market) => {
        switch (market) {
            case 'Panama':
                this.telrequired = false;
                this.showShippingDoc = false;
                this.showReqdeliveryDate = false;
                break;
            case 'Costa Rica':
                this.showReqdeliveryDate = false;
                this.telrequired = false;
                this.showShippingDoc = false;
                break;
        }

    }

    handleSupplyPoint(event) {
        if (this.supplypointgb !== '') {
            this.supplyPointValue = this.supplypointgb;
        }
        else {
            this.supplyPointValue = event.target.value;
        }


        if (this.supplyPointValue != '') {
            this.openModal = false;
            let curvalue = this.supplyPointCurrency.filter((item) => { return item.supplypoint == this.supplyPointValue })[0].currency;
            console.log('Selected currency-->', curvalue);

            prepareData({ selectedCurrencyCode: curvalue }).then((result) => {
                let temp = JSON.parse(JSON.stringify(result));

                console.log('Intial==>', result);

                temp.lstOrdItm = temp.lstOrdItm.filter((item) => {
                    return (item.SalesOrg == this.supplyPointValue);

                })
                temp.lstOrdItm = temp.lstOrdItm.map((item) => {
                    return {
                        Id: item.Id,
                        discount: (item.discount == undefined) ? 0 : item.discount,
                        percentageOfFreeCharge: (item.percentageOfFreeCharge == undefined) ? 0 : item.percentageOfFreeCharge,
                        freeOfChargeQuantity: this.calculateFOCQuantity(item.percentageOfFreeCharge, item.quantity),
                        prodName: item.prodName,
                        quantity: (item.quantity == undefined) ? 0 : item.quantity,
                        reqDeliveryDate: item.reqDeliveryDate,
                        sapMaterialNo: parseInt(item.sapMaterialNo, 10).toString(),
                        totalprice: (item.quantity == undefined) ? 0 : this.calculateOrderItemPrice(this.calculateFOCQuantity(item.percentageOfFreeCharge, item.quantity), item.quantity, item.unitPrice, temp.market, temp.country, item.discount),
                        unitPrice: item.unitPrice,
                        pricebookentryId: item.pricebookentryId,
                        uom: item.uom,
                        SalesOrg: item.SalesOrg,
                        supplyPoint: item.supplyPoint
                    }
                })

                this.contactOptions = temp.lstContact.map((item) => {
                    return { label: item.Name, value: item.Id };
                })

                this.shipToAddrOptions = temp.shipToAddrOptions.map((item) => {
                    return { label: item.Full_Address__c, value: item.Id };
                })

                this.orderData = temp;
                let fnl = this;
                this.orderData.SalesOrg = this.supplyPointValue;
                this.orderData.currencyValue = this.supplyPointCurrency.filter((item) => { return item.supplypoint == this.supplyPointValue })[0].currency;
                this.orderData.contactName = this.orderData.lstContact.filter((item) => { return item.Id == this.orderData.userId })[0].Name;
                this.shippingDocPrep();
                this.doShowhide(this.orderData.market, this.orderData.country);
                this.orderData.grandTotal = this.calculateTotalPrice();
                this.doSetFields(this.orderData.market);
                console.log('Result==>', this.orderData);
                this.loading= false;
                this.loaded = true;
            })
                .catch((err) => {
                    console.log('Error==>', err);
                })

        }

    }

    handleValueChange(event) {
        let ctrlName = event.currentTarget.dataset.name;
        let key = event.currentTarget.dataset.id;

        switch (ctrlName) {
            case 'quantity':
                this.orderData.lstOrdItm[key].quantity = event.target.value;
                this.orderData.lstOrdItm[key].freeOfChargeQuantity = this.calculateFOCQuantity(this.orderData.lstOrdItm[key].percentageOfFreeCharge,
                    this.orderData.lstOrdItm[key].quantity);

                this.orderData.lstOrdItm[key].totalprice = this.calculateOrderItemPrice(this.orderData.lstOrdItm[key].freeOfChargeQuantity, event.target.value, this.orderData.lstOrdItm[key].unitPrice, this.orderData.market, this.orderData.country, this.orderData.lstOrdItm[key].discount);
                this.orderData.grandTotal = this.calculateTotalPrice();
                break;
            case 'reqDeliveryDate':
                this.orderData.lstOrdItm[key].reqDeliveryDate = event.target.value;
                break;
            case 'transportMode':
                this.orderData.modeOfTransport = event.target.value;
                break;
            // case 'docType':
            //     this.orderData.docType = event.target.value;
            //     this.showOtherDoc = (this.orderData.docType == 'Others') ? true : false;
            //     break;
            case 'byCourier':
                this.orderData.lstShippingDocs[key].originalByCourier = (event.target.value == '') ? '0' : event.target.value;
                break;
            case 'elecEmail':
                this.orderData.lstShippingDocs[key].elecByEmail = event.target.checked;
                break;
            case 'otherdoc':
                this.orderData.lstShippingDocs[key].docRemarks = event.target.value;
                break;
            case 'purOrdNo':
                this.orderData.purchaseOrderNo = event.target.value;
                break;
            case 'tel':
                this.orderData.tel = event.target.value;
                break;
            case 'fax':
                this.orderData.fax = event.target.value;
                break;
            case 'shipToAddr':
                this.orderData.shipToAddr = this.orderData.shipToAddrOptions.filter((item => {
                    return item.Id == event.target.value;
                }))[0];
                break;
            case 'conOptions':
                let temp = this.orderData.lstContact.filter((item => {
                    return item.Id == event.target.value;
                }))[0];
                this.orderData.userId = temp.Id;
                break;
            case 'remarks':
                this.orderData.remarks = event.target.value;
                break;
        }
    }

    calculateOrderItemPrice = (focQuantity, quantity, unitPrice, market, country, discount) => {
        let orderItemPrice = 0;
        // Added if condition for orderItemPrice for Costarica and Panama as part of TPDEV-711
        if(market == 'CostaRica' || market == 'Panama') {
            orderItemPrice = (quantity * unitPrice);
        }
        else if (country == 'Israel' || market == 'Israel') {
            let discountedPrice = ((quantity * unitPrice) * discount) / 100;
            orderItemPrice = ((quantity * unitPrice) - discountedPrice);
        }
        else {
            // updated formula as per TPDEV-711
            orderItemPrice = (quantity*unitPrice )* (1 - discount/100);
        }
        return orderItemPrice;
    }

    calculateFOCQuantity = (percent, quantity) => {
        let focQuantity = 0;
        focQuantity = (quantity * percent) / 100;
        if (!isNaN(focQuantity)) {
            return focQuantity;
        }
        else {
            return 0;
        }
    }

    calculateTotalPrice = () => {
        let price = 0;
        this.orderData.lstOrdItm.forEach((item) => {
            if (!isNaN(item.totalprice)) {
                price = price + parseFloat(item.totalprice);
            }
        })
        // console.log(price);
        return price.toFixed(2);
    }

    handleEsign(event) {

        this.orderData.eSignature = event.detail.signature;
    }

    submitRecord = () => {
        if (this.orderData.Id == '') {
            this.orderData.status = "Submitted";
            this.saveRecord();
        }
        else {
            this.loaded = false;
            updateOrderStatus({ orderId: this.orderData.Id })
                .then((result) => {
                    console.log('save Success-->', result)
                    this.loaded = true;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Order record submitted successfully",
                        variant: 'success',
                    });
                    this.isReadOnly = true;
                }).catch((error) => {
                    console.log('Error--> ' + error.body.message)
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Error Occured submitting Order record",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
        }

    }
    makeEditable = () => {
        if (this.orderData.status != "Draft") {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Order can only be edited in DRAFT status",
                variant: 'error',
            });
            this.dispatchEvent(evt);

        }
        else {
            this.isReadOnly = false;
            this.isEdit = true;
        }

    }

    saveRecord = () => {
        console.log('Saving data==>', this.orderData)
        if (this.validateFields()) {
            this.loaded = false;
            let payload = JSON.stringify(this.orderData);
            console.log('payload', payload);
            saveOrder({ payload: payload })

                .then((result) => {
                    console.log('save Success-->', result)
                    this.loaded = true;
                    this.orderData.Id = result;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Order record created successfully",
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.showDownload = true;
                    this.showSendSignature = true; //Added by NamrataP [7/13] -- AdobeSign Implemetation
                    this.isSaved = true;
                    this.isReadOnly = true;

                    //this is an intrim fix..
                    window.location.href = window.location.origin + basePath + '/orders';

                    // let saveEvent = new CustomEvent('saveorder',{
                    //     detail : { value : this.orderData.Id }
                    // });
                    // this.dispatchEvent(saveEvent);
                })
                .catch((error) => {
                    console.log('Error--> ' + error.body.message)
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Error Occured creating Order record",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
        }

    }

    updateRecord = () => {
      
        console.log('Saving data==>', this.orderData)
        if (this.validateFields()) {
            this.loaded = false;
            //this.orderData.purchaseOrderDate = Date.getFullYear() + '/'+ Date.getMonth() + '/'+ Date.getDate() ;
            let payload = JSON.stringify(this.orderData);
            updateOrder({ payload: payload })
                .then((result) => {
                    console.log('Update success-->', result)
                    this.loaded = true;
                    this.orderData.Id = result;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Order record Updated successfully",
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.showDownload = true;
                    this.isEdit = false;
                    this.isReadOnly = true;
                    this.showReqdeliveryDate = false;

                    //this is an intrim fix..
                    window.location.href = window.location.origin + basePath + '/orders';

                    // let updateEvent = new CustomEvent('updateorder',{
                    //     detail : { value : this.orderData.Id }
                    // });
                    // this.dispatchEvent(updateEvent);
                })
                .catch((error) => {
                    console.log('Error--> ' + error.body.message)
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: "Error Occured updating Order record",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })

        }

    }

    validateFields = () => {

        let errorStatus = true;
        errorStatus = this.template.querySelector('[data-name=\'tel\']').reportValidity();
        // console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\'purOrdNo\']').reportValidity() && errorStatus;
        // console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\'transportMode\']').reportValidity() && errorStatus;

        this.orderData.lstShippingDocs.forEach((item) => {
            if (item.docType == 'Other' && (item.originalByCourier > 0 || item.elecByEmail)) {
                let otherField = this.template.querySelector('[data-name=\"otherdoc\"]');
                console.log('Otherfield', item.docRemarks);
                if (item.docRemarks == '') {
                    console.log('inside if ', item.docRemarks);
                    otherField.setCustomValidity("Please enter the other document type");

                }
                else {
                    otherField.setCustomValidity("");
                }

                errorStatus = otherField.reportValidity() && errorStatus
            }

        })
        let productCodeFields = this.template.querySelectorAll('[data-name=\"quantity\"]');
        productCodeFields.forEach(field =>
            errorStatus = field.reportValidity() && errorStatus
        )
        let batchLotFields = this.template.querySelectorAll('[data-name=\"reqDeliveryDate\"]');
        batchLotFields.forEach(field => {
            let date2 = new Date(field.value);
            let date1 = new Date();
            let Difference_In_Time = date2.getTime() - date1.getTime();
            let Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            if (Difference_In_Days < 14) {
                field.setCustomValidity("Delivery Date can not be within 15 days");
                console.log('Error diff is less than 15', Difference_In_Days);
            }
            else {
                field.setCustomValidity("");
            }
            errorStatus = field.reportValidity() && errorStatus
        }
        )
        /*if(this.orderData.eSignature == '')
                {
                  this.esignPresent = false;
                    console.log("E-Signature is mandatory before every save and submit.");
                }*/ //Commented as part of Adobe changes 

        if (!errorStatus) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please fill all mandatory fields before saving order",
                variant: 'error',
            });
            this.dispatchEvent(evt);

        }
        return errorStatus;

    }
    closeModal = () => {
        this.openModal = false;
        this.showAddProductModal = false;
        this.addProductRecord = null;
        this.selectedProductId = null;
        let closeModalEvent = new CustomEvent('modalclosed', {
            detail: { value: true }
        });
        this.dispatchEvent(closeModalEvent);
    }
    download = () => {
        
        // Sending -Signed pdf when order status is Submitted as part of TPDEV-707
        if (this.orderData.Id) {
            if (this.orderData.status === 'Submitted') {
                // added for Panama and Costa Rica to download unsigned pdf
                if (this.orderData.market === 'Panama' || this.orderData.market === 'Costa Rica') {
					this.downloadPDF();
                }
                else{
                let oId = this.orderData.Id;
                //Fetching PDF file from Agreements
                getFileFromAgreement({ orderId: oId })
                    .then((result) => {
                        this.attachmentData = result;
                        if (this.attachmentData) {
                            let byteCharacters = atob(this.attachmentData);
                            let byteArrays = [];
                            // Processing the data in chunks of 512 characters.
                            for (let offset = 0; offset < byteCharacters.length; offset += 512) {
                                let slice = byteCharacters.slice(offset, offset + 512);
                                let byteNumbers = new Array(slice.length);
                                for (let i = 0; i < slice.length; i++) {
                                    byteNumbers[i] = slice.charCodeAt(i);
                                }
                                // Create a Uint8Array from the byte numbers and add it to the byteArrays.
                                let byteArray = new Uint8Array(byteNumbers);
                                byteArrays.push(byteArray);
                            }
                            // Creating a Blob from the byteArrays representing the PDF file.
                            let blob = new Blob(byteArrays, { type: 'application/pdf' });
                            console.log(blob);
                            let link = document.createElement('a');
                            link.href = URL.createObjectURL(blob);
                            link.target = '_blank';
                            var filename2 = 'Purchase Order ' + this.orderData.purchaseOrderNo + '- Signed.pdf';
                            link.download = filename2;

                            link.click();
                        }
                        else {
                            this.downloadPDF();
                        }
                    })
                    .catch((error) => {
                        console.log(error.message);
                    });
                }

            } else {

                this.downloadPDF();
                }
        }
            else {

                }
    }
    //Added by Saranya -- Download PDF if status is Draft or Signed pdf is not available
    downloadPDF() {
        //sending PDF when order status is Draft
        let pdfPage = window.location.origin + '/apex/alphaOrderPDF?id=' + this.orderData.Id + '&download=true'; 
        if (!window.ActiveXObject) {
            var save = document.createElement('a');
            save.href = pdfPage;
            save.target = '_blank';
            var filename = 'Purchase Order ' + this.orderData.purchaseOrderNo + '.pdf';
            save.download = filename;
            if (navigator.userAgent.toLowerCase().match(/(ipad|iphone|safari)/) && navigator.userAgent.search("Chrome") < 0) {
                document.location = save.href;
                // window event not working here
            } else {
                var evt = new MouseEvent('click');
                save.dispatchEvent(evt);
                (window.URL || window.webkitURL).revokeObjectURL(save.href);
            }
        }
        // for IE < 11
        else if (!!window.ActiveXObject && document.execCommand) {
            var _window = window.open(pdfPage, '_blank');
            _window.document.close();
            _window.document.execCommand('SaveAs', true, filename);
            _window.close();
        }
    }
    
  //Added by NamrataP [7/14/2021] -- Adobe Signature Implementation
    adobeSendForSignature = (event) => {
        event.target.disabled = true;
        let evt = new ShowToastEvent({
            title: "Sending Documents",
            message: "Please wait, preparing your Documents...",
            variant: "info",
        });
        this.dispatchEvent(evt);
        if (this.orderData.Id) {
            //let payload = JSON.stringify(this.orderData);
            console.log('RECORD---->' + this.orderData.Id);
            adobeSendForSignature({ orderID: this.orderData.Id })
                .then((result) => {
                    console.log('Sign success-->', result);
                    this.responValue = result.split('|');

                    if (result) {
                        evt = new ShowToastEvent({
                            title: "Sending Documents",
                            message: "Please wait, your documents are being sent to " + this.responValue[1],
                            variant: "info",
                        });
                        this.dispatchEvent(evt);
                        this.sendESign(this.responValue[0], this.responValue[1]);
                    }
                })
                .catch((error) => {
                    console.log('Error--> ' + error.body.message)
                    evt = new ShowToastEvent({
                        title: "Error",
                        message: "Error Occured while sending for signature",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    event.target.disabled = false;
                })
        } else {
            evt = new ShowToastEvent({
                title: "Error",
                message: "Order not found. Please save your Order before trying to sign.",
                variant: "error",
            });
            this.dispatchEvent(evt);
            event.target.disabled = false;
        }
    }

    sendESign = (resultId, conEmail) => {
        sendForSignatureRemote({ agreementId: resultId })
            .then((result) => {
                console.log('Response', result)
                var response = JSON.parse(result);
                if (response.success) {
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Documents Sent to " + conEmail + " for Signature",
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    // Redirect to Order Page after Successful Send to Adobe for ALPHA-102 (on JIRA)  
                    window.location.href = window.location.origin + basePath + '/orders';
                }
            })
            .catch((error) => {
                console.log('Error--> ' + error.body.message)
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Error Occured while sending for signature",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            })
    }

    //Added by Sweta Kumari--> add product button visible to the Order when we are editing
    addProduct() {
        this.showAddProductModal = true;
    }
    //When selecting from add product button to the Order when we are editing.
    handleProdChange(event) {
        let rec = JSON.parse(JSON.stringify(event.detail.selectedRecordId));
        if(!rec) {
            this.template.querySelector('c-alpha-custom-lookup').handleRemove(); 
            this.addProductRecord = null;
            this.selectedProductId = null ;
        }
        else {
            this.selectedProductId= rec.Id;
        }
    }
    //Save product from add product button to the Order when we are editing.
    saveUpdateRecord = () => {
        console.log('Check Order::',this.orderData);
        console.log('Check Order currencyValue::',this.orderData.currencyValue);
        console.log('Check Order PONumber::',this.orderData.purchaseOrderNo);
        if (!this.selectedProductId) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: "Please select an additional Product to add to the Order",
                variant: 'error',
            });

            this.dispatchEvent(evt); 
            return;
        }
        this.loading= true;
            addProductOrder({ productId:this.selectedProductId, selectedCurrencyCode:this.orderData.currencyValue })
            .then(result => {
                this.loading=false;
                    this.addProductRecord = JSON.parse(JSON.stringify(result));
                    this.addProductRecord.sapMaterialNo = parseInt(this.addProductRecord.sapMaterialNo, 10).toString();
                 for (let i = 0; i < this.orderData.lstOrdItm.length; i++) {
                    if (this.orderData.lstOrdItm[i].sapMaterialNo === this.addProductRecord.sapMaterialNo) { 
                        const evt = new ShowToastEvent({
                            title: "Product Already Selected",
                            message: "Product is already in the table. Please edit or delete existing entry.",
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);    
                    } 
                }
                this.addProductRecord.sapMaterialNo = parseInt(this.addProductRecord.sapMaterialNo, 10).toString();
                for (let i = 0; i < this.orderData.lstOrdItm.length; i++) {
                    if (this.orderData.lstOrdItm[i].sapMaterialNo === this.addProductRecord.sapMaterialNo) {
                        const evt = new ShowToastEvent({
                            title: "Product Already Selected",
                            message: "Product is already in the table. Please edit or delete existing entry.",
                            variant: 'error',
                        });
                        return this.dispatchEvent(evt);  
                    }   
                }
                this.orderData.lstOrdItm.push(this.addProductRecord);
                this.showAddProductModal = false;
                this.addProductRecord = null;
                this.selectedProductId = null;
                this.loading = false;
            }).catch(error => {
                 let toastEvent = new ShowToastEvent({
                    title: 'Error Downloading File',
                    message: "An unexpected error occured. Please try again. ",
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
               this.loading= false;
            });  
    }

    //TPDEV-710--Added by Sweta Kumari-->Download all attachments for an Order on Order Details 
    handleDownload(event) {
        let key = event.currentTarget.dataset.id;
        this.downLoadOneFile = key;
        downloadFile({ fileId: this.downLoadOneFile })
            .then(result => {
                const attachmentDetailsInfo = result;
                const ContentDocumentId = attachmentDetailsInfo[0].ContentDocumentId;
                const attachementTitleAndType = attachmentDetailsInfo[0].Title + "." + attachmentDetailsInfo[0].FileType;
                const url = `/sfc/servlet.shepherd/document/download/${ContentDocumentId}?operationContext=S1`;
                const link = document.createElement('a');
                link.href = url;
                link.download = attachementTitleAndType;
                link.click();
                URL.revokeObjectURL(url);
            })
            .catch(error => {
                let toastEvent = new ShowToastEvent({
                    title: 'Error Downloading File',
                    message: error.body.pageErrors[0].message,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
            })
    }
}