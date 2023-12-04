({
    fetchPickListVal: function(component, col, row) {
        var allValues;
        if(row.isDependent == true){
            var controlFld = row.controllingField;
            var record = component.get("v.record");
            var val = record[controlFld];
            allValues = row.picklistVal[val];
        }else{
            allValues = row.picklistVal;   
        }
        var upDateVal = [];
        var arrValues = component.get('v.selectedItems');
        var i;
        var len = allValues.length;
        for (i = 0; i < len; i++) {
            var item= allValues[i];
            if(arrValues.indexOf(item['value']) != -1){
                item['selected'] = true;
            }else{
                item['selected'] = false;
            }
            upDateVal.push(item);
        }
        component.set('v.picklistOptions', upDateVal);
        
        //LIB-536 Changes to populate the picklist Label vs api value
        var values = [];
        if(component.get('v.value') != undefined){
        	var val = component.get('v.value');
           	values = val.split(';');
        }    
        var labels = [];
        var option;
        var label = '';
        for(var iIndex=0,len=upDateVal.length;iIndex<len;iIndex++)
        {
            option = upDateVal[iIndex];
            if(values.indexOf(option.value)>-1)
            {
                if(option.label)
                {
                    labels.push(option.label);
                }
                else
                {
                    labels.push(option.value);
                }
            }
        }
        
        if(labels.length>0)
        {
            component.set('v.valueLabel', labels.join(', '));
        }
        else
        {
            component.set('v.valueLabel', '');
        }
    },
    getDependentList : function(component, col, row) {
        //controllingField
        var controlFld = row.controllingField;
        var record = component.get("v.record");
        var val = record[controlFld];
        component.set('v.picklistOptions', row.picklistVal[val]);
        //picklistVal
    }
})