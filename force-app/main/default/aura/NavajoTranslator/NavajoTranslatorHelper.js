/*******************************************************
    @module      NavajoTranslatorHelper
    @brief       Helper for NavajoTranslator component. Contails apex method invocations, processing translated results, set toast messages and operating modes.

    @revision   2020-07-21  Rajnikanth
    	Created.
	@modifications
   				2021-12-21  Nilanjan(Cognizant) 	Added markup to show HEM/LIP/ICT/RQC details on Error translation modal(SC-008782)
*******************************************************/

({
    /*******************************************************
    @function    getLotInfo
    @brief       calls apex controller method to fetch lot# details

    @param       component
    @return type lot details from apex class.

    *******************************************************/
    getLotInfo : function(component) {
        var lotNumber = component.get("v.lotNumber");
        var lotMethod = component.get("c.getLotDetails");
        var materialNumber = component.get("v.caseRecord.Primary_Consumable__r.Product_External_ID__c");
        lotMethod.setParams({
            "lotNumber":lotNumber,
            "materialNum":materialNumber
        });
        lotMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state !== "SUCCESS"){
                var errorMessage = 'Error fetching lot details. Please try again';
                this.setToastNotifications(component,errorMessage,'error','dismissible');
            }else{
                var result = response.getReturnValue();
                if(result != undefined){
                    if(result.lotRecordId !== null){
                        component.set("v.lotNumberFound",true);
                        component.set("v.gotLotInfo",true);
                        component.set("v.manufactureDate",result.lotManufactureDate);
                        component.set("v.expiryDate",result.lotExpiryDate);
                        component.set("v.description",result.lotDescription);
                        component.set("v.usage",result.lotUsage);
                    }
                    if(result.isLotExpired){
                        component.set("v.lotExpired",true);
                        var warningMessage = "This Lot is expired."
                        this.setToastMessages(component,warningMessage,'warning');
                    }
                    if(result.noRotorFound){
                        component.set("v.lotNumberFound",false);
                        var warningMessage = "Unknown Lot Number. "
                        if(materialNumber=='' || materialNumber==undefined) warningMessage +="No material found on Case record."
                        this.setToastMessages(component,warningMessage,'warning');
                        component.set("v.showNextButton",false);
                    }else
                    if(result.rotorMismatch){
                        var warningMessage = "The Lot # provided doesn't match Primary Consumable selected on the case. "
                        this.setToastMessages(component,warningMessage,'warning');
                    }
                    this.setOperatingModes(component,
                                       (component.get("v.caseRecord").Primary_Error_Code__r.Name.substring(0,3)==='SXN') ? 'suppression' :'cancellation' );                    
                }
            }
        });
        $A.enqueueAction(lotMethod);
    },
    
    /*******************************************************
    @function    getCaseInfo
    @brief       calls apex controller method to fetch case details

    @param       component
    @param       caseId : case record id from component
    @return type N/A

    *******************************************************/
    getCaseInfo : function(component, caseId){
        var caseMethod = component.get("c.getCaseDetails");
        caseMethod.setParams({
            "caseId":caseId
        });
        caseMethod.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var caseRec = response.getReturnValue();
                component.set("v.caseRecord",caseRec);  
               // if(component.get("v.caseRecord.Primary_Consumable__r.Chemistries__c") ==='' && component.get("v.caseRecord").Primary_Error_Code__r.Name.substring(0,3)==='SXN'){
                    
            if((component.get("v.caseRecord").Primary_Error_Code__r!= null && component.get("v.caseRecord.Primary_Consumable__c") !=null)){
               if(component.get("v.caseRecord.Primary_Consumable__r.Chemistries__c") ==null && component.get("v.caseRecord").Primary_Error_Code__r.Name.substring(0,3)==='SXN'){
                    var msg = 'No chemistries defined for '+caseRec.Primary_Consumable__r.Product_External_ID__c+' . Please add chemistries to the product. ';
                    this.setToastMessages(component,msg,'error');   
                }else{
                    component.set("v.chemistries",component.get("v.caseRecord.Primary_Consumable__r.Chemistries__c").split(';'));
                }
            }

                if(component.get("v.caseRecord.Primary_Lot_Num__c")===undefined){
                    var toastMessage = "No lot# provided. Please enter lot# or proceed with cancellation mode. "
                    this.setToastMessages(component,toastMessage,'Error');
                    component.set("v.showLotInput",true);
                    component.set("v.showNextButton",true);
                }else{
                    this.getLotInfo(component);
                }
                
            }
        });
        $A.enqueueAction(caseMethod);
    },
    
    /*******************************************************
    @function    setToastMessages
    @brief       sets static toast messages inside component.

    @param       component
    @param       message   : toast message to display
    @param       toastType : type of toast (warning/success/error)

    *******************************************************/
    setToastMessages : function(component, message, toastType){
        var iconType = 'utility:warning';
        var slds = 'slds-notify slds-notify_toast slds-theme_warning';
        if(toastType==='error'){
            iconType = 'utility:error';
            slds = 'slds-notify slds-notify_toast slds-theme_error';
        }
        if(toastType === 'success'){
            iconType = 'utility:success';
            slds = 'slds-notify slds-notify_toast slds-theme_success';
        }
        if(message==='No Lot# provided'){
            message = "No Lot# provided. Enter Lot# on Case or proceed with cancellation mode."
        }
        component.set("v.showWarningToast", true);
        component.set("v.toastHeadMsg",message);
        component.set("v.toastType", toastType);
        component.set("v.utilityIconType", iconType);
        component.set("v.divForToast", slds);
    },
    
    /*******************************************************
    @function    getTranslatedMessages
    @brief       calls apex method to translate suppression error codes

    @param       component
    @param       inputErrorCodes    : chemistry error codes from navajo component controller
    @return type translationResults : translated results from apex controller
    *******************************************************/
    getTranslatedMessages : function(component,inputErrorCodes){
        var inputDetails_String = [];
        for(var i=0;i<inputErrorCodes.length; i++) inputDetails_String.push(JSON.stringify(inputErrorCodes[i]));
        var translationMethod = component.get("c.getTranslationDetails");
        translationMethod.setParams({
            "errorCodeInputDetails":inputDetails_String
        });
        translationMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var translationResults = response.getReturnValue();
                component.set("v.showResults",true);
                component.set("v.makeReadOnly",true);
                var resultText = '';
                var allResults = [];
                if(translationResults.displayLabels !== undefined){
                    for(var i = 0; i < translationResults.displayLabels.length; i++ ){
                        var eachChemistry = {};
                        var label = translationResults.displayLabels[i];
                        eachChemistry['displayLabel'] = label;
                        resultText += label +'\n';
                        var specificMessages = [];
                        if(translationResults.labeltoSpecificMessages[label] != undefined) specificMessages = translationResults.labeltoSpecificMessages[label];
                        eachChemistry['specificMessage'] = specificMessages;
                        for (var m = 0;  m < specificMessages.length ; m++) resultText += specificMessages[m] +'\n';
                        var genericMessage = '';
                        if(translationResults.labeltoGenericMessages[label] != undefined)  genericMessage = translationResults.labeltoGenericMessages[label];
                        eachChemistry['genericMessage'] = genericMessage;
                        resultText += genericMessage +'\n';
                        allResults.push(eachChemistry);
                    }
                }
                component.set("v.translatedResults",allResults);
                //Nilanjan Ganguly Added the below part for SC-008782--->
                inputErrorCodes.forEach((item)=>{
                    
                    if(item.chemistry=='HEM/LIP/ICT')
                    {
                        let appVals= item.chemistry + ': ' + item.result +'/'+ item.errorCode1 + '/' + item.errorCode2 ;
                        resultText += '\n' + appVals;
                	}
                    if(item.chemistry=='RQC')
                	{
                        let appVals= item.chemistry + ': ' + item.result ;
                        resultText += '\n' + appVals;
               	   }
                })
                console.log('CASE RESULT TEXT==>', resultText);
               //(EOC) Nilanjan Ganguly Added the below part for SC-008782-->
                component.set("v.resultTextToCase",resultText);
            }
        });
        $A.enqueueAction(translationMethod);
    },
    
    /*******************************************************
    @function    addDetailsToCase
    @brief       calls apex method to add translation results to case record

    @param       component
    @param       caseId  			  : case id from component
    @param       translationResults               : translation results component screen
    @param       lotNum				  : Lot number from component screen
    @return type N/A
    *******************************************************/
    addDetailsToCase : function(component,caseId,translationResults, lotNum){
        var updateAction = component.get("c.updateCaseWithErrorDetails");
        updateAction.setParams({
            "caseId" : caseId,
            "translationResults"  : translationResults,
            "lotNum" : lotNum
        });
        updateAction.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state==='SUCCESS'){
                // case update
                // toast message
                if(response.getReturnValue()){
                    var msg = 'Case updated with details.';
                    this.setToastNotifications(component,msg,'success','dismissible');
                    $A.get('e.force:refreshView').fire();
                }else{
                    var msg ='Error in updating case with translation details.';
                    this.setToastNotifications(component,msg,'error','dismissible');
                }
            }
        });
        $A.enqueueAction(updateAction);
    },
    
    /*******************************************************
    @function    addDetailsToCase
    @brief       calls apex method to retrieve cancellation labels metadata

    @param       component
    @return type cancellation labels from apex method.

    *******************************************************/
    getCancellationRows : function(component){
        var cancellationDataMethod = component.get("c.fetchCancellationLabels");
        cancellationDataMethod.setCallback(this,function(response){
            if(component.isValid() && response.getState()==='SUCCESS'){
                component.set("v.operatingMode",'cancellation');
                component.set("v.showCancellationTable",true); 
                var cancelLabels = [];
                var cancellationLabelRecords = response.getReturnValue();
                for(var i =0 ; i<cancellationLabelRecords.length ; i++){
                    var labelRecord = cancellationLabelRecords[i];
                    cancelLabels.push(labelRecord['Cancellation_Label__c']);
                }                
                component.set("v.cancellationLabels",cancelLabels);
            }
        });
        $A.enqueueAction(cancellationDataMethod);
        
    },
    
    /*******************************************************
    @function    getCancelltionMessages
    @brief       calls apex method to translate cancellation error codes

    @param       component
    @param       inputErrorCodes : cancellation error codes from navajo controller.

    *******************************************************/
    getCancelltionMessages : function(component,inputErrorCodes){
        var inputDetails_String = [];
        for(var i=0;i<inputErrorCodes.length; i++) inputDetails_String.push(JSON.stringify(inputErrorCodes[i]));
        var translationMethod = component.get("c.getCancellationErrorDetails");
        translationMethod.setParams({
            "errorCodeInputDetails":inputDetails_String
        });
        translationMethod.setCallback(this, function(response) {
            var state = response.getState();
            var translationResults = response.getReturnValue();
            var resultText = '';
            var allResults = [];
            if(translationResults != null){
                var labal_to_ValueMap = translationResults.labelToMessage;
                var keys = Object.keys(labal_to_ValueMap);
                for(var i in keys){
                    var key = keys[i];
                    var errorInfo ={
                        'name' :'' ,
                        'label' : key,
                        'value' : labal_to_ValueMap[key]
                    }
                    resultText += errorInfo['label'] + '\n';
                    resultText += errorInfo['value'] + '\n';
                    allResults.push(errorInfo);
                }
                var QCMessages = [];
                for(var i = 0; i < translationResults.QCMessages.length; i++ ) QCMessages.push(translationResults.QCMessages[i]);
                if(QCMessages.length > 0){
                    var QCLabel = translationResults.QCLabel;
                    var QCResults ={
                        'name':'Flag',
                        'label' : QCLabel,
                        'value' : QCMessages
                    }
                    resultText += QCResults['label'] + '\n';
                    resultText += QCResults['value'] + '\n';
                    allResults.push(QCResults);
                }
                
                var SystemMessages = [];
                for(var i = 0; i < translationResults.SystemMessages.length; i++ ) SystemMessages.push(translationResults.SystemMessages[i]);
                if(SystemMessages.length > 0){
                    var SysLabel = translationResults.SysLabel;
                    var SystemResults ={
                        'name':'Flag',
                        'label' : SysLabel,
                        'value' : SystemMessages
                    }
                    resultText += SystemResults['label'] + '\n';
                    resultText += SystemResults['value'] + '\n';
                    allResults.push(SystemResults);
                }
                if(translationResults.inputErrorCode != undefined){
                    var Label = translationResults.inputErrorCode;
                    var ErrorMsg = translationResults.errorInfoString;
                    var errorInfo ={
                        'name' : 'errorcode',
                        'label' : Label,
                        'value' : ErrorMsg
                    }
                    resultText += 'Input Error Code :' + '\n';
                    resultText += errorInfo['label'] + '\n';
                    resultText += errorInfo['value'] + '\n';
                    allResults.push(errorInfo);
                }
                component.set("v.cancellationResults",allResults);
                component.set("v.resultTextToCase",resultText);
            }
            component.set("v.showCancellationResults",true);
            component.set("v.makeReadOnly",true);
        });
        $A.enqueueAction(translationMethod);
    },
    
    /*******************************************************
    @function    setOperatingModes
    @brief       sets navajo operating mode (cancellation or suppression)

    @param       component
    @param       mode     : navajo operating mode (cancellation / suppression)

    *******************************************************/
    setOperatingModes : function(component,mode){
        if(mode==='suppression'){
            component.set("v.operatingMode",'suppression');
            component.set("v.showNextButton",false);
            component.set("v.showLotInput",false);
            component.set("v.showThisTable",true);
        }else{
            component.set("v.showNextButton",false);
            component.set("v.showLotInput",false);
            this.getCancellationRows(component);
            component.set("v.operatingMode",'cancellation');
            component.set("v.showCancellationTable",true);
        }
    },
    
    /*******************************************************
    @function    setToastNotifications
    @brief       displays toast notification after case record is updated
    @param       component,
    @param       message           : message to display
    @param       notificationType  : toast type
    @param       mode              : toast mode

    *******************************************************/
    setToastNotifications : function(component,message,notificationType,mode){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : mode,
            "type" : notificationType,
            "message": message
        });
        toastEvent.fire();
    },
    
})