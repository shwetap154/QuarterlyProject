/**
 * Created by jerridkimball on 2018-06-05.
 */
({
    doInit: function(cmp, evt, hlpr) {
//        var currentRecord = cmp.get("v.currentRecord");
//        var fieldMap = cmp.get("v.fieldMap");
//
//        for (var field of fieldMap) {
//            for (var prop in field) {
//                console.log(prop + ': ' + field[prop]);
//            }
//        }
//
//        console.log(fieldMap);
//        for (var index = 0; index < fieldMap.length; index++) {
//            console.log("fieldMap[" + index + "].columnWidth: " + fieldMap[index].columnWidth);

//            currentRecord[index].record.colWidth = fieldMap[index].colWidth;
//        }

//        for (var prop1 in currentRecord) {
//            console.log("prop: " + prop1);
//            for (var prop2 in currentRecord[prop1]) {
//                console.log("   prop: " + prop2);
//
//            }
//        }

//        for (var index = 0; index < fieldMap.length; index++) {
//            console.log("fieldMap[" + index + "].colWidth: " + fieldMap[index].colWidth);
//
//            currentRecord[index].record.colWidth = fieldMap[index].colWidth;
//        }
//List<UserRecordAccess> accessToRecord = [SELECT RecordId, HasDeleteAccess, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId()  AND RecordId = '500000000000001AAA'];

//        cmp.set("v.currentRecord", currentRecord);
          
    },

    handleFocus: function (cmp, evt, hlpr) {
        // try {
        // var action = cmp.get("c.getUserPemissions");
        // } catch (e) { console.log(e); }
        // //console.log("Record Id: " + cmp.get("v.currentRecord").record.Id);
        // //console.log("Record Id: " + cmp.get("v.currentRecord.record.Id"));

        // action.setParams({
        //     recordId: cmp.get("v.currentRecord.record.Id")
        // });

        // action.setCallback(this,function(response) {
        //     var state = response.getState();

        //     if (state === "SUCCESS") {
               
        //         var res = response.getReturnValue();

        //         // console.log("ura: " + res);
        //         // console.log("hasEditPermission: " + res.HasEditAccess);
        //         // console.log("hasDeletePermission: " + res.HasDeleteAccess);
        //         console.log('Test--->Permission',res.HasDeleteAccess);
        //         cmp.set("v.hasEditPermission", res.HasEditAccess);
        //         cmp.set("v.hasDeletePermission", res.HasDeleteAccess);
        //     }
        //     else if(state === "INCOMPLETE") {

        //     }
        //     else if(state === "ERROR") {
        //         var errors = response.getError();

        //         if(errors) {
        //             if(errors[0] && errors[0].message) {
        //                 console.log("Error message: " + errors[0].message);
        //             }
        //         }
        //         else {
        //             console.log("Unknown error");
        //         }
        //     }
        // });
        // $A.enqueueAction(action);
    },

    handleSelect: function (cmp, evt, hlpr) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        
        var selectedMenuItemValue = evt.getParam("value");

        if (selectedMenuItemValue == "edit") {
            hlpr.editRecord(cmp, evt, hlpr);
        }
        else if (selectedMenuItemValue == "delete") {
            hlpr.deleteRecord(cmp, evt, hlpr);
        }
        else {
            console.log("handleSelect: Unhandle menu item.");
        }
    },
})