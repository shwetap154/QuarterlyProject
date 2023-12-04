({
//    doInit: function() {},
    doInit : function(cmp, ev, help) {
        
        //var spinner = cmp.find('initSpinner');
		cmp.set('v.IsShowSpinner',true); // show spinner
        var fieldList = cmp.get('v.mainFieldList');
        var objName = cmp.get('v.mainObjectName');
        var sortFld = cmp.get('v.mainSortField');
        var sortDir = cmp.get('v.mainSortDirection');
        var pgSize = cmp.get('v.pgSize');
        var queryFilter = cmp.get('v.mainQueryFilter');
//        var relationshipField = cmp.get('v.relationshipField');
        var relationshipField = cmp.get('v.mainLookupFieldName');
        var parentRecordId = cmp.get('v.recordId');
        // var parentField = cmp.get('v.parentField');

        var parentField = cmp.get('v.mainLookupFieldName');

        
        var isFilterByParent = false;
        var nestedObjectName = cmp.get('v.nestedObjectName');
        var nestedFieldookupName = cmp.get('v.nestedLookUPFieldAPI');
        var nestedQueryFilter = cmp.get('v.nestedQueryFilter');
        
        cmp.set("v.currentRecords", new Array(pgSize));
		
        var action = cmp.get("c.dynQry");
        action.setParams({
            "fieldList": fieldList,
            "objName": objName,
            "sortFld": sortFld,
            "sortDir": sortDir,
            "queryFilter": queryFilter,
            "parentRecordId": parentRecordId,
            "relationshipField": relationshipField,
            "parentField": parentField,
            "filterByParent": isFilterByParent,
            "nestedObjectName": nestedObjectName,
            "nestedfieldName": nestedFieldookupName,
            "nestedQueryFilter": nestedQueryFilter
        }); 
        
        action.setCallback(this,function(response) {
            var state = response.getState();

            //$A.util.removeClass(spinner, "slds-hide");
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var tempRes = JSON.parse(res);
                var allRecs = tempRes.recs;
                
                if(cmp.get('v.isInfiniteScrollEnabled')) {
                    // Give enough space for the infinite scroll to work.
                    pgSize = pgSize + 5;
                    if(pgSize <= 20 ){
                        pgSize = 25;
                    }
                }

                var nextInfo = help.nextPg(allRecs, 1, pgSize);
                
                var fieldMapTemp = [];
                var errorMsg = '';
				console.log('==tempRes=>',tempRes);
                tempRes.fieldMap.forEach(function(record, index) {
                    if(record['invalidField'] == '')
                        fieldMapTemp.push(record);   
                    else
                        errorMsg += ', ' + record['invalidField'];
                });

                if(errorMsg != '') {
                    cmp.set("v.invalidFldMsg", 'Data for ' + errorMsg.slice(1) + (errorMsg.split(',').length > 2 ? ' columns' : ' column') + ' are not displayed. Please check the field API names in the table configuration.');
                }

                cmp.set("v.createAccess", tempRes.createAccess);
                cmp.set("v.mainSortDirection", tempRes.sortDir);
                cmp.set("v.mainSortField", tempRes.sortFld);
                cmp.set("v.allRecs", allRecs);
                cmp.set("v.currentRecords", nextInfo.currentRecords);
                cmp.set("v.totPgs", Math.ceil(allRecs.length/pgSize));
                cmp.set("v.fieldMap", fieldMapTemp);
                cmp.set("v.errMsg", tempRes.errMsg);
                cmp.set("v.mainObjectName", tempRes.titledObjectName);

                cmp.set("v.recordCount", allRecs.length);

                if(! cmp.get('v.mainSortField')){
                    var fieldMap =cmp.get("v.fieldMap");
                    for(var i=0; i<fieldMap.length; i++) {
                        if(fieldMap[i].fieldType != "TEXTAREA" && fieldMap[i].fieldType != "ICON" ) {
                            cmp.set("v.mainSortField",fieldMap[i].apiName);
                            break;
                        } 
                    }
                }
                if (!$A.util.isEmpty(cmp.get("v.mainColumnWidths"))) {
                    var colWidths = cmp.get("v.mainColumnWidths").split(",");
                    var fieldMap = cmp.get("v.fieldMap");

                    if (colWidths.length == fieldMap.length) {
                        for(var i = 0; i < fieldMap.length; i++) {
                            fieldMap[i].columnWidth = colWidths[i];
                        }
                    }

                    cmp.set("v.fieldMap", fieldMap);
                }
                var obj={};
                obj.apiName='Id'; 
                obj.fieldType='ICON'; 
                obj.isRef=false; 
                obj.label='Action';

                var columnSorting = {};
                fieldMapTemp.forEach(function(record, index) {
                    columnSorting[record.apiName] = '';    
                });
                cmp.set('v.columnFilters', columnSorting);
				cmp.set('v.IsShowSpinner',false); // Hide spinner
                //$A.util.addClass(spinner, "slds-hide");
            }
            else if(state === "INCOMPLETE") {

            }
            else if(state === "ERROR") {
                var errors = response.getError();

                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

//    setColumnWidths: function(cmp, evt, hlpr) {
//        var colWidths = cmp.get("v.mainColumnWidths").split(",");
//        var headerCols = document.getElementsByClassName("header_col");
//
//        console.log("# widths: " + colWidths.length);
//        console.log("# cols: " + headerCols.length);
//
//        if (colWidths.length !== headerCols
//    },

    lastPg: function(cmp, evt, help) {
        var allRecs = cmp.get('v.allRecs');

        var lastPg = cmp.get('v.totPgs');
        var pgSize = cmp.get('v.pgSize');

        var nextInfo = help.nextPg(allRecs, lastPg, pgSize);

        cmp.set('v.currentRecords',nextInfo.currentRecords);
        cmp.set('v.currPg',nextInfo.currPg);
    },

    nextPg: function(cmp,evt,help) {
        var allRecs = cmp.get('v.allRecs');

        var currPg = cmp.get('v.currPg');
        var pgSize = cmp.get('v.pgSize');

        var nextInfo = help.nextPg(allRecs, currPg + 1, pgSize);

        cmp.set('v.currentRecords',nextInfo.currentRecords);
        cmp.set('v.currPg',nextInfo.currPg);
    },

    prevPg: function(cmp,evt,help) {
        var allRecs = cmp.get('v.allRecs');

        var currPg = cmp.get('v.currPg');
        var pgSize = cmp.get('v.pgSize');

        var nextInfo = help.nextPg(allRecs, currPg - 1, pgSize);

        cmp.set('v.currentRecords',nextInfo.currentRecords);
        cmp.set('v.currPg',nextInfo.currPg);
    },

    firstPg: function(cmp,evt,help) {
        var allRecs = cmp.get('v.allRecs');
        var pgSize = cmp.get('v.pgSize');
        var nextInfo = help.nextPg(allRecs, 1, pgSize);
        cmp.set('v.currentRecords',nextInfo.currentRecords);
        cmp.set('v.currPg',nextInfo.currPg);
    },
})