/*******************************************************
    @module      NavajoTranslatorController
    @brief       Controller for NavajoTranslator component. Contails first level of validations, initializations for component, button actions.

    @revision   2020-07-21  Rajnikanth
    	Created.

*******************************************************/
({
    /*******************************************************
    @function    openModal
    @brief       Opens Navajo Component, resets all attributes,loads case record and lot record details.

    *******************************************************/
    openModal : function(component,event,helper){
        component.set("v.isOpen",true);
        // Clear all String variables
        component.set("v.manufactureDate",'');
        component.set("v.expiryDate",'');
        component.set("v.manufactureDate",'');
        component.set("v.description",'');
        component.set("v.usage",'');
        component.set("v.operatingMode",'');
        component.set("v.materialNumber",'');
        component.set("v.inputValue",'');
        component.set("v.resultTextToCase",'');
        // clear all arrays
        component.set("v.chemistries",[]);
        component.set("v.cancellationLabels",[]);
        component.set("v.errorCodeValues",[]);
        component.set("v.translatedResults",[]);
        // clear all booleans
        component.set("v.showWarningToast",false);
        component.set("v.showLotInput",false);
        component.set("v.showNextButton",false);
        component.set("v.lotNumberFound",false);
        component.set("v.lotExpired",false);
        component.set("v.gotLotInfo",false);
        component.set("v.showResults",false);
        component.set("v.showCancellationResults",false);
        component.set("v.showThisTable",false);
        component.set("v.showCancellationTable",false);
        component.set("v.makeReadOnly",false);
        // call initial method
        helper.getCaseInfo(component,component.get("v.recordId"));
    },

    /*******************************************************
    @function    closeModal
    @brief       Closes Navajo Component

    *******************************************************/
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
    },

    /*******************************************************
    @function    closeToast
    @brief       Closes Toast Messages

    *******************************************************/
    closeToast : function(component,event,helper){
        component.set("v.showWarningToast", false);
    },


    /*******************************************************
    @function    toggleCaseDetails
    @brief       Show or Hide case details on UI Screen

    *******************************************************/
    toggleCaseDetails : function(component,event,helper){
        var acc = component.find('caseDetails');
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');
            $A.util.toggleClass(acc[cmp], 'slds-hide');
        }
    },

    /*******************************************************
    @function    loadErrorCodes
    @brief       generates input error code arrays

    *******************************************************/
    loadErrorCodes : function(component,event,helper){
        var chemistry = event.getSource().get('v.label');
        var resultValue;
        var errorCode1;
        var errorCode2;
        var errorCodes = component.get("v.errorCodeValues");
        var hexRegex = /^[A-Fa-f0-9]$/ ;
        var inputName = event.getSource().get('v.name');
        var inputValue = event.getSource().get('v.value');
        var lastChar = inputValue.substr(inputValue.length - 1);
        if(!lastChar.match(hexRegex)) inputValue=inputValue.slice(0,-1);
        event.getSource().set('v.value',inputValue.toUpperCase());
        if(inputName==='result') resultValue = inputValue;
        if(inputName==='errorCode1') errorCode1 = inputValue;
        if(inputName==='errorCode2') errorCode2 = inputValue;
        if(chemistry=='ALB') chemistry = 'ALB_BCG';
        var existingErrorCode ;
        for(var i =0; i < errorCodes.length ; i++){
            if(errorCodes[i].chemistry === chemistry){
                existingErrorCode = errorCodes[i];
                break;
            }
        }
        if(existingErrorCode!== undefined){
            if(inputName==='result') existingErrorCode['result'] = resultValue;
            if(inputName==='errorCode1') existingErrorCode['errorCode1'] = errorCode1;
            if(inputName==='errorCode2') existingErrorCode['errorCode2'] = errorCode2;
        }
        else{
            existingErrorCode = {
                'chemistry':chemistry,
                'result':resultValue,
                'errorCode1':errorCode1,
                'errorCode2':errorCode2
            }
            errorCodes.push(existingErrorCode);
        }
        component.set("v.errorCodeValues",errorCodes);
    },

    /*******************************************************
    @function    processErrorCodes
    @brief       send error code arrays to helper

    *******************************************************/
    processErrorCodes : function(component,event,helper){
        var errorCodes = component.get("v.errorCodeValues");
        (component.get("v.operatingMode")==='suppression') ? helper.getTranslatedMessages(component,errorCodes ) : helper.getCancelltionMessages(component,errorCodes );
    },

    /*******************************************************
    @function    updateCaseRecord
    @brief       updates case record with translation results and lot#

    *******************************************************/
    updateCaseRecord : function(component,event,helper){
        var recId = component.get("v.recordId");
        var translationDetails = component.get("v.resultTextToCase");
        var lotNum = component.get("v.lotNumber");
        (lotNum != undefined) ? helper.addDetailsToCase(component,recId,translationDetails,lotNum) : helper.addDetailsToCase(component,recId,translationDetails,'');
    },

    /*******************************************************
    @function    getCancellationLabels
    @brief       retrieves cancellation metadata records

    *******************************************************/
    getCancellationLabels : function(component,event,helper){
        helper.getCancellationRows(component);
    },

    /*******************************************************
    @function    handleNextButton
    @brief       Validates lot#, retrieve either cancellation metadata records or chemistires

    *******************************************************/
    handleNextButton : function(component,event,helper){
        var lotNumber = component.get("v.lotNumber");
        if(lotNumber==undefined || lotNumber==''){
            component.set("v.showNextButton",false);
            component.set("v.showLotInput",false);
            var msg = 'No Lot# provided. Opening in cancellation mode.'
            helper.setToastMessages(component,msg,'warning');
            //fetch cancellation rows
            helper.getCancellationRows(component);
        }else{
            helper.getLotInfo(component);
        }
    },

    /*******************************************************
    @function    loadCancellationErrorCodes
    @brief       generates error code arrays for cancellation

    *******************************************************/
    loadCancellationErrorCodes : function(component,event,helper){
        var errorCodes = component.get("v.errorCodeValues");
        var inputName = event.getSource().get('v.name');
        var inputValue = event.getSource().get('v.value');
        var label ;
        var mergeValues = false ;
        var errorValue ='';
        var QCFlagValue ='' ;
        var firstValue ='';
        var secondValue ='' ;
        var singleValue ='';
        var column;
        var hexRegex = /^[A-Fa-f0-9]$/ ;
        var lastChar = inputValue.substr(inputValue.length - 1);
        if(!lastChar.match(hexRegex)) inputValue=inputValue.slice(0,-1);
        event.getSource().set('v.value',inputValue.toUpperCase());
        if(inputName.includes('+') && !inputName.includes('QC Flags')){
            var labelsCombined = inputName.split('+')[0];
            column = inputName.split('+')[1];
            var labels = labelsCombined.split('/');
            if(labels.length == 2){
                if(column=='column1') firstValue = inputValue;
                if(column=='column2') secondValue = inputValue
                if(column=='column1' || column =='column2') {
                    label = labels[0].trim();
                    mergeValues=true;                    
                }
                if(column=='column3') firstValue = inputValue;
                if(column=='column4') secondValue = inputValue
                if(column=='column3' || column =='column4') {
                    label = labels[1].trim();
                    mergeValues=true;
                }
            }
            if(labels.length == 4){
                if(column=='column1') {
                    singleValue = inputValue;
                    label = labels[0].trim();
                }
                if(column=='column2') {
                    singleValue = inputValue;
                    label = labels[1].trim();
                }
                if(column=='column3') {
                    singleValue = inputValue;
                    label = labels[2].trim();
                }
                if(column=='column4') {
                    singleValue = inputValue;
                    label = labels[3].trim();
                }
            }
        }
        if(inputName.includes('QC Flags')) {
            label = 'QC Flags';
            QCFlagValue = inputValue;
        }
        if(inputName ==='errorcode'){
            label = inputName;
            errorValue = inputValue;
        }
        var CancellationErrorCodes ;
        for(var i = 0 ; i < errorCodes.length ; i++){
            if(errorCodes[i].label == label){
                CancellationErrorCodes = errorCodes[i]
                break;
            }
        }
        if(CancellationErrorCodes !== undefined){
            if(firstValue !='') CancellationErrorCodes['firstValue'] = firstValue;
            if(inputValue =='' && (column=='column1' || column=='column3')) CancellationErrorCodes['firstValue'] = '0000';
            if(secondValue !='')CancellationErrorCodes['secondValue'] = secondValue; 
            if(inputValue =='' && (column=='column2' || column=='column4')) CancellationErrorCodes['secondValue'] = '0000';
            CancellationErrorCodes['errorCodeValue'] = errorValue;
            CancellationErrorCodes['QCFlagValue'] = QCFlagValue;
            CancellationErrorCodes['singleValue'] = singleValue;
            CancellationErrorCodes['mergeValues'] = mergeValues;
        }
        else{
            CancellationErrorCodes = {
                'label':label,
                'firstValue':firstValue,
                'secondValue':secondValue,
                'singleValue' : singleValue,
                'errorCodeValue':errorValue,
                'QCFlagValue':QCFlagValue,
                'mergeValues':mergeValues
            }
            errorCodes.push(CancellationErrorCodes);
        }
        component.set("v.errorCodeValues",errorCodes);
    },

    /*******************************************************
    @function    goBackToInputScreen
    @brief       brings error code input screen after translations

    *******************************************************/
    goBackToInputScreen : function(component,event,helper){
        component.set("v.makeReadOnly",false);
        component.set("v.translatedResults",[]);
        if(component.get("v.operatingMode")=='cancellation'){
            component.set("v.showCancellationTable",true);
            component.set("v.showCancellationResults",false);
        }
        if(component.get("v.operatingMode")=='suppression'){
            component.set("v.showThisTable",true);
            component.set("v.showResults",false);
        }
    },
})