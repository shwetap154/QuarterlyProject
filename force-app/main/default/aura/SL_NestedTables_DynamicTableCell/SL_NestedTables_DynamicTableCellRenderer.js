({
    render: function(cmp, helper) {
        var ret = this.superRender();
        var isRef = cmp.get('v.currentField.isRef');
        var fieldType = cmp.get('v.currentField.fieldType');
        var cmpType;
        var attrs = {};
       
        if(isRef) {

            cmpType = 'c:SL_NestedTables_Link';
            attrs['currentField'] = cmp.get('v.currentField');
            attrs['cellValue'] = cmp.get('v.cellValue');
            attrs['lookupId'] = cmp.get('v.lookupId');

        } else {
            attrs.value = cmp.get('v.cellValue');
            //if()
            if(fieldType==='ICON' ){
                $A.createComponents([
                ["aura:HTML", {
                    "tag": "div",
                    "HTMLAttributes": {
                        
                    }
                }],
                ["lightning:buttonIcon", {
                        "iconName" : "utility:edit",
                        "value": cmp.get('v.cellValue'),
                        "onclick": cmp.getReference('c.editRecord'),
                        "variant" : "bare",
                        "class" : 'iconMargin'
                    }],
                ["lightning:buttonIcon", {
                        "iconName" : "utility:delete",
                        "value": cmp.get('v.cellValue'),
                        "onclick": cmp.getReference('c.confirmMsg'),
                         "variant" : "bare",
                         "class" : 'iconMargin'
                    }],
                ],
                function(Components, status, statusMsgLst) {
                    if(cmp.isValid()){
                            var divTag = Components[0];
                            var editIcon = Components[1];
                            var deleteIcon = Components[2];
                            var divBody =divTag.get("v.body");
                            divBody.push(editIcon);
                            divBody.push(deleteIcon);
                            divTag.set("v.body",divBody);

                             var body = cmp.get('v.body');
                             body.push(divTag);
                             cmp.set('v.body', body);
                    }
                });
                return ret;

            }
            if( fieldType==='ID' || fieldType==='COMBOBOX' || 
                fieldType==='ENCRYPTEDSTRING' || fieldType==='BASE64' || 
                fieldType==='PICKLIST' || fieldType === 'MULTIPICKLIST' || fieldType === 'TIME') {
                cmpType = 'ui:outputText';
                
            } else if(fieldType === 'LOCATION'){
                if(attrs.value){
                    cmpType='lightning:buttonIcon';
                    attrs.iconName ="utility:checkin";
                     attrs.variant= "bare";
                    attrs.onclick=  cmp.getReference("c.openMapModelBox"); 
                }
                

            }else if (fieldType === 'DATE') {
    
                cmpType = 'ui:outputDate';
                
            }else if (fieldType === 'DATETIME' ) {

                //attrs.value=$A.localizationService.formatDateTimeUTC(cmp.get('v.cellValue'), "MM/DD/YYYY hh:mm a");
                //cmpType = 'ui:outputRichText';
                cmpType = 'ui:outputDateTime';
                attrs.value = cmp.get('v.cellValue'); 
                attrs.format= 'M/DD/YYYY h:mm a';
                
            } else if (fieldType === 'BOOLEAN') {
                
                cmpType = 'ui:outputCheckbox';
                
            } else if (fieldType === 'CURRENCY') {
                
                cmpType = 'ui:outputCurrency';
                
            } else if (fieldType === 'DOUBLE' || fieldType === 'INTEGER') {
                
                cmpType = 'ui:outputNumber';
                
            } else if (fieldType === 'PERCENT') {
                cmpType = 'lightning:formattedNumber';
                attrs.style='percent';
                attrs.maximumFractionDigits = '2';
                var val = cmp.get('v.cellValue');
                if(val != null && val != undefined && val != 0){
                    attrs.value =  val/100;
                }else{
                    attrs.value = '0.00';
                }
            } else if (fieldType === 'EMAIL') {
                
                cmpType = 'ui:outputEmail';
                
            } else if (fieldType === 'PHONE') {
                
                cmpType = 'ui:outputPhone';
                
            } else if (fieldType === 'STRING' || fieldType === 'TEXTAREA') {
                var cellValue;
                if(cmp.get('v.cellValue')){
                    cellValue =cmp.get('v.cellValue').replace(/<\/p>/gm, ""); 
                    cellValue= cellValue.replace(/<p>/gm, "");
                    
                }
                $A.createComponents([
                ["aura:HTML", {
                    "tag": "div",
                    "HTMLAttributes": {
                        "class" : 'imgSize',
                        "onclick": cmp.getReference('c.handlePress'),
                        "Id" : cellValue
                    }
                }],
                ["lightning:formattedRichText", {
                        "class" : 'imgSize',
                        "value": cellValue
                    }]
                    ],
                    function(Components, status, statusMsgLst) {
                    if(cmp.isValid()){
                            var divTag = Components[0];
                            var textTag = Components[1];
                            var divBody =divTag.get("v.body");
                            divBody.push(textTag);
                            divTag.set("v.body",divBody);

                             var body = cmp.get('v.body');
                             body.push(divTag);
                             cmp.set('v.body', body);
                    }
                });
                return ret;
                // cmpType.push("ui:outputRichText");
                
            } else if (fieldType === 'URL') {
                attrs.label = cmp.get('v.cellValue');
                attrs.target='_blank';
                cmpType = 'ui:outputURL';
                
            }
            if(fieldType === 'DATE' && attrs.value) {
                attrs.format = 'M/DD/YYYY';
            }
        }
        if(cmpType){
           $A.createComponent(cmpType, attrs, function(newCmp, status, statusMsgLst) {
               if(cmp.isValid()){
                    var body = cmp.get('v.body');
                    body.push(newCmp);
                    cmp.set('v.body', body);
                }
            }); 
        }
        return ret;
        
    }
})