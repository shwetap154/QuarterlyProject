({
    doInit : function(component, event, helper) {

        // console.log('RESP>>>>'+component.get("v.displayDensity"));
		
        var record = component.get("v.record");        
        var rows = component.get("v.rows")[0];
        var col = component.get("v.col");
        var row = rows[col];
        var apiName = row.fieldPath;
        var mapDecLength = component.get('v.decimalFldLngth');
        var count = mapDecLength[apiName];
        var StrFormat='';
        
        //    console.log(' currency---> ', $A.get("$locale.currency"));
        if(row.type == 'CURRENCY'){
            let frmt = $A.get("$Locale.currencyFormat");
            //let frmEnd = '';
            if(frmt.indexOf(';') > -1){
                //frmEnd = frmt.substring(frmt.indexOf(';'),frmt.length);
                frmt = frmt.substring(0,frmt.indexOf(';'));
            }
            let frmSub = frmt.substring(frmt.indexOf('.'), frmt.length); 
            frmSub = frmSub.replace(/\.|0/g,'');
            for(let i = 0; i<count; i++){
                frmSub = '0' + frmSub;   
            }
            frmSub = '.'+frmSub;
            StrFormat = frmt.substring(0,frmt.indexOf('.'))+frmSub;
        }else {
            StrFormat = '#,##0.';
            for(let i = 0; i<count; i++){
                StrFormat += '0';
            }
        }
        component.set('v.formatVal',StrFormat);
        component.set('v.parentObj',row.parentObject);
        component.set('v.fieldPath',apiName);
        
        // help text
        component.set('v.helpText', (row.helpText != undefined && row.helpText != null && row.helpText != '') ? row.helpText : '');
        if(col.includes(".")){
            var splitstring = col.split('.');
            component.set('v.label', row.label);
            component.set('v.type', row.type);
            component.set('v.editable', row.editable);
            
            var obj = record[splitstring[0]];
            if(obj != null && obj != undefined ){
                var str2 = obj[splitstring[1]]; 
                component.set('v.value', str2);
                component.set('v.selectedID',obj['Id']);
                var addParentFieldName = str2;
            }else{
                component.set('v.value', '');
            }
        }else{
            if(row){
                //  For Current Objects(Contact)
                component.set('v.label', row.label);
                component.set('v.type', row.type);
                component.set('v.editable', row.editable);
                if(row.type == 'PERCENT'){
                    component.set('v.decimalCount', count);
                    if(record[col] != null && record[col] != undefined){
                        let val = record[col];
                        component.set('v.value', val/100 );
                    }

                }else if(row.type == 'TIME'){
                    if(record[col] != undefined && record[col] != null){
                        console.log('TIME>>>>>>>>>>>>>'+record[col]);
                        // var d = new Date(record[col]);
                        // console.log('TIME D>>>>>>>>>>>>>'+d);
                        // var utcdate = d.toISOString();
                        // console.log('TIME UTC>>>>>>>>>>>>>'+utcdate);
                        // var frstT = utcdate.indexOf('T');
                        // var time = utcdate.substring(frstT+1,utcdate.length);
                        // var time1 = utcdate.substring(frstT+1,utcdate.length-1);

                        // component.set('v.value', time );
                        // component.set('v.valueEdit', time1 );

                        var time = record[col];
                        var time1 = record[col];
                        time = time.substring(0, time.lastIndexOf('.'));

                        component.set('v.value', time );
                        component.set('v.valueEdit', time1 );

                    }else{
                        var time= "00:00:00.000";
                        component.set('v.valueEdit', time );
                    }
                
                }else{
                    component.set('v.value', record[col]);
                }
            }
            if(component.get("v.type") === 'MULTIPICKLIST'){
                var val = component.get('v.value');
                if(val !=null && val != undefined && val !=''){
                component.set('v.selectedItems',val.split(';'));                    
                }else{
                    component.set('v.selectedItems','');
                }
				
                helper.fetchPickListVal(component, col, row);
            }
            if(component.get("v.type") === 'PICKLIST' ) {
                if(row.isDependent == true){
                    helper.getDependentList(component, col, row);
                }else{
                    //LIB-536 Changes to populate the picklist Label vs api value
                    var val = component.get('v.value');
                    if(row.picklistVal && row.picklistVal.length>0)
                    {
                        var option;
                        var label = '';
                        for(var iIndex=0,len=row.picklistVal.length;iIndex<len;iIndex++)
                        {
                            option = row.picklistVal[iIndex];
                            if(option.value && option.value==val)
                            {
                                if(option.label)
                                {
                                    label = option.label;
                                }
                                break;
                            }
                        }
                        
                        component.set('v.valueLabel', label);
                    } 
                    else
                    {
                        component.set('v.valueLabel', '');
                    }
                    component.set('v.picklistOptions', row.picklistVal);
                }
            }
            // if(component.get("v.type") == 'STRING' && component.get("v.editable") == ){
            //     // component.get("v.value")
            // }
        }
        // LIB-574:  allow Read Only Mode
        if(component.get('v.isReadOnly')){
            component.set('v.editable',false);
        }
        

    },
    handleClick : function(component, event, helper) {
        var updateEvent = component.getEvent("SL_FL_evt_FieldEdited");
        updateEvent.setParams({
            "isFieldEdited" : true
        });
        updateEvent.fire();
    },
    onSelectChange : function(component, event, helper){
        var mapDep = component.get('v.mpFieldDependence');
        var selectCmp = component.find("picklist");
        component.set("v.value", selectCmp.get("v.value"));
        var record = component.get("v.record");
        var fieldName = component.get("v.col");

        record[fieldName] = selectCmp.get("v.value");
        var depField = mapDep[fieldName];
        if(depField != undefined && depField != null && depField !='' ){
            record[depField] = null;
        }
    },
    updateVal : function(component, event, helper){

        var updatedVal = event.getSource().get("v.value");
        if(updatedVal !== undefined){
            var record = component.get("v.record");
            var fieldName = component.get("v.col");
            record[fieldName] = updatedVal;
        }
    },
    lookDetail : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.currentTarget.id,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    timeField : function (component, event, helper) {
        var updatedVal = event.getSource().get("v.value");
        if(updatedVal !== undefined){
            var d = new Date();
            var time = updatedVal.split(':');
            d.setHours(time[0], time[1], 0);
            updatedVal =d.getTime();
            var record = component.get("v.record");
            var fieldName = component.get("v.col");
            record[fieldName] = updatedVal;
        }
        
    }
})