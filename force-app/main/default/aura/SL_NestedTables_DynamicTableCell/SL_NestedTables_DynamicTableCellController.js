({
    doInit : function(cmp, ev, help) {
        var currentField = cmp.get('v.currentField');
        var currentRecord = cmp.get('v.currentRecord');

        var cellValue='';
        var lookupId='';

        if(currentField.apiName.includes('.')) {
            var tempArry = currentField.apiName.split('.');
            var arrySize = tempArry.length;
            
            var tempObj;
            
            if(arrySize > 2) {
                for(var i=0;i<arrySize-1;i++) {
                    var curTempFld = tempArry[i];
                    
                    if(tempObj == null) {
                        tempObj = currentRecord[curTempFld];
                    } else {
                        tempObj = tempObj[curTempFld];
                    }
                    
                    if(i == arrySize-2 && tempObj != null && !currentField.isRef) {
                        cellValue = tempObj[tempArry[i+1]];
                    } else if(i == arrySize-2 && tempObj != null && currentField.isRef) {
                        cellValue = help.getRelName(currentField,currentRecord);
                        lookupId = tempObj[tempArry[i+1]];
                    }
                }
            } else {
                if(currentField.isRef) {
                    var relArry = currentField.lookupFieldName.split('.');
                    
                    if(relArry.length == 3) {
                        var tempRelObj = currentRecord[relArry[0]][relArry[1]];
                        
                        if(tempRelObj != null) {
                            cellValue = tempRelObj[relArry[2]];
                            lookupId = currentRecord[tempArry[0]][tempArry[1]];
                        }
                    } else {
                        cellValue = currentRecord[relArry[0]][relArry[1]];
                        lookupId = currentRecord[tempArry[0]][tempArry[1]];
                    }
                } else {
                    if( currentRecord != null ) {
                        cellValue = currentRecord[tempArry[0]][tempArry[1]];
                    }
                    
                }
            }
        } else if(currentRecord){
            if(currentField.isRef) {
                
                if(currentField.apiName == 'Id' || currentField.apiName == 'Name') {
                    cellValue = currentRecord[currentField.apiName];
                } else {
                    var tempArry = currentField.lookupFieldName.split('.');
                    var tempRelObj = currentRecord[tempArry[0]];
                    cellValue = tempRelObj != null ? currentRecord[tempArry[0]][tempArry[1]] : '';
                }
                lookupId = currentRecord[currentField.lkupRelAPI];
                
            } else {
                cellValue = currentRecord[currentField.apiName];
            }
        }
        
        cmp.set('v.cellValue',cellValue);
        cmp.set('v.lookupId',lookupId);
    },
    handlePress : function (cmp ,ev,help){
        cmp.set("v.isOpen",true);
        
    },
    closeModal : function (cmp ,ev,help){
        cmp.set("v.isOpen",false);
        cmp.set("v.isOpen1",false);
        cmp.set("v.isOpen2",false);
    },
    openMapModelBox : function(cmp ,ev,help) {
        cmp.set("v.isOpen1",true);
    },
    confirmMsg : function(cmp ,ev,help) {
        cmp.set("v.isOpen2",true);
    },
    deleteIt :function(cmp,ev,help){
        cmp.set("v.isOpen2",false);
        var message;
        var type="info";                 //error, warning, success, or info
        var act= cmp.get("c.deleteRecord");
        act.setParams({
            recordId : cmp.get("v.cellValue")
        }); 
        act.setCallback(this,function(response){
            var title = response.getState();
            if (title === "SUCCESS") {
                message=  'Record is Deleted Successfully.';
                type="success";
            }if(title === "ERROR"){
                message=  "Please contact Admin";
                type="error";
            }
            //toast message
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type" : type,
                "duration": 1000
            });
            toastEvent.fire();
            
        });
        $A.enqueueAction(act);
    },
    editRecord : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": component.get("v.cellValue")
        });
        editRecordEvent.fire();
    },
})