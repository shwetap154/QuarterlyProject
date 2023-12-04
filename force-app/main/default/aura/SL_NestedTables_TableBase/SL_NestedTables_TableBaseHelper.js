({ 
    loadMoreRecords : function(cmp, help) {
        var currRecs = cmp.get('v.currentRecords');
        var totRecs = cmp.get('v.allRecs');
        var pageSize = cmp.get('v.pgSize');
        var size1 = currRecs.length;
        
        for(var i = currRecs.length; i < (size1 + pageSize); i++) {
            if(i < totRecs.length)
                currRecs.push(totRecs[i]);
        }
        cmp.set('v.currPg', cmp.get('v.currPg') + 1);
        cmp.set('v.currentRecords',currRecs);
    },
    
//    handleFilters : function(cmp, allRecs, fltrVal, columnObj) {
//
//        var finalRecs = [];
//        var tempRecs = allRecs;
//        if(!$A.util.isEmpty(fltrVal)) {
//            fltrVal = fltrVal.toLowerCase();
//            tempRecs = allRecs.filter(function(currentRecord) {
//                var propArray = Object.getOwnPropertyNames(currentRecord);
//                for(var i = 0; i < propArray.length; i++) {
//                    // ignore salesforce attributes which is auto attached to sobjects
//                    if(propArray[i] === 'attributes') {
//                        continue;
//                    }
//                    var propertyVal = currentRecord[propArray[i]];
//
//                    if(typeof propertyVal === 'object'){
//                        // need to add code here for filtering based on relationship fields
//                        // instead we only search on the name of the object
//                        //hasOwnProperty is used to avoid error form location field .Location not having Name field
//                        if( propertyVal && propertyVal.hasOwnProperty('Name')){
//                            propertyVal = propertyVal.Name.toString().toLowerCase();
//                        }else{
//                            propertyVal = '';
//                        }
//                    }
//                    else {
//                        propertyVal = propertyVal.toString().toLowerCase();
//                    }
//
//                    if( propertyVal.indexOf(fltrVal) != -1){
//                        return true;
//                    }
//                }
//                return false;
//            }, this);
//        }
//
//        var fieldMap=cmp.get("v.fieldMap");
//        var that = this;
//        tempRecs.forEach(function(record, index){
//            var count=0;
//            var isMatch = false;
//            var tempKey='';
//            for(var key in columnObj) {
//                var recordValue = record[key];
//                var fieldType='';
//                if( count<fieldMap.length && fieldMap[count].isRef && fieldMap[count].lookupFieldName !== '') {
//                    getField = fieldMap[count].lookupFieldName;
//                    recordValue= that.getRelName(getField, record);
//                }
//                if(count<fieldMap.length){
//                    fieldType=fieldMap[count].fieldType;
//                }
//                count=count+1;
//                if(!columnObj[key] || columnObj[key].trim() == '') {
//                    isMatch = true;
//                    continue;
//                }
//                if(fieldType == 'DATE'){
//
//                    recordValue =$A.localizationService.formatDateTimeUTC(recordValue, "MM/DD/YYYY");
//
//                }else if(fieldType == 'DATETIME'){
//
//                    recordValue=$A.localizationService.formatDateTimeUTC(recordValue, "MM/DD/YYYY hh:mm a");
//
//                }
//                if( !isEmpty(recordValue) && columnObj[key] && recordValue.toString().toLowerCase().trim().indexOf(columnObj[key].toString().toLowerCase().trim()) > -1) {
//                    isMatch = true;
//                } else {
//                    isMatch = false;
//                    break;
//                }
//
//            }
//            if(isMatch) {
//                finalRecs.push(record);
//            }
//        });
//        function isEmpty(val){
//            return (val === undefined || val == null || val.length <= 0) ? true : false;
//        }
//
//        var fieldMap = cmp.get('v.fieldMap');
//        var sortFld = cmp.get('v.sortFld');
//        var sortDir = cmp.get('v.sortDir');
//        var pgSize = cmp.get('v.pgSize');
//        if(sortFld){
//            var sortedVals = this.sort(finalRecs, fieldMap, sortFld, sortDir, 1, pgSize);
//            cmp.set('v.currentRecords', sortedVals.currentRecords);
//            cmp.set('v.sortFld', sortedVals.sortFld);
//            cmp.set('v.sortDir', sortedVals.sortDir);
//            cmp.set('v.currPg', sortedVals.currPg);
//            cmp.set('v.totPgs', sortedVals.totPgs);
//            cmp.set('v.fltrRecs', sortedVals.fltrRecs);
//            cmp.set('v.glblFltrTimer', null);
//        }
//    },
    
//    /* Parameters:
//    allRecs: Array containing all records in the table
//    nxtPg: Integer of the next page of records to return
//
//    Returns: Object with the updated list of records to display on this page
//             and the new page number
//    */
    nextPg: function(allRecs, nextPg, pgSize) {
        var allRecsLength = allRecs.length;

        var start = (nextPg-1)*pgSize;
        var endPgIndex = nextPg*pgSize;
        var end = endPgIndex > allRecsLength ? allRecsLength : endPgIndex;
        var newList = allRecs.slice(start, end);
        return {"currentRecords": newList, "currPg": nextPg};
    },
//
//    // Sorts and filters records from allRecs and stores in fltrRecs
//    sort : function(filteredRecs, fieldMap, sortFld, sortDir, currPg, pgSize) {
//        var sortField = sortFld;
//        // If the field we are sorting on is a relationship, sort on the name
//        // not on the id
//        for(var i = 0; i < fieldMap.length; i++){
//            if(fieldMap[i].apiName === sortField) {
//                if(fieldMap[i].isRef && fieldMap[i].lookupFieldName !== '') {
//                    sortField = fieldMap[i].lookupFieldName;
//                }
//                break;
//            }
//        }
//        // we want to access helper function while sorting
//        var that = this;
//        filteredRecs.sort(function(recA, recB){
//            var recAVal = that.getRelName(sortField, recA);
//            var recBVal = that.getRelName(sortField, recB);
//
//            if(sortDir === 'ASC'){
//                //this is handling null value as well and populating them in the last
//                if(!recAVal || recAVal === null){
//                    return 1;
//                }
//                else if(!recBVal || recBVal === null){
//                    return -1;
//                }
//                else if(recAVal > recBVal){
//                    return sortDir === 'ASC' ? 1 : -1;
//                }
//                else if(recAVal < recBVal) {
//                    return sortDir === 'ASC' ? -1 : 1;
//                }
//                else return 0;
//            }else{
//                 //this is handling null value as well and populating them in the first
//                if(!recAVal || recAVal === null){
//                    return -1;
//                }
//                else if(!recBVal || recBVal === null){
//                    return 1;
//                }
//                else if(recAVal > recBVal){
//                    return sortDir === 'ASC' ? 1 : -1;
//                }
//                else if(recAVal < recBVal) {
//                    return sortDir === 'ASC' ? -1 : 1;
//                }
//                else return 0;
//            }
//        });
//        // We just want to recalc the current page, so pass currPg as is
//        // instead of incremented up or down
//        var nextInfo = this.nextPg(filteredRecs, currPg, pgSize);
//
//        var totPgs = Math.ceil(filteredRecs.length/pgSize);
//
//        return {
//            'fltrRecs': filteredRecs,
//            'currentRecords' : nextInfo.currentRecords,
//            'sortFld' : sortField,
//            'sortDir' : sortDir,
//            'totPgs' : totPgs,
//            'currPg' : nextInfo.currPg
//        };
//    },
    
    // Mostly copied from DynamicTableCellHelper.js, not sure of a better way to 
    // share helper code
//    getRelName : function(currentField,currentRecord) {
//        var relArry = currentField.split('.');
//        var arrySize = relArry.length;
//        var cellValue = '';
//
//        if(arrySize >= 2) {
//            for(var i=0;i<arrySize-1;i++) {
//                var tempObj;
//                var curTempFld = relArry[i];
//
//                if(tempObj == null) {
//                    tempObj = currentRecord[curTempFld];
//                }
//                else {
//                    tempObj = tempObj[curTempFld];
//                }
//
//                if(i == arrySize-2 && tempObj != null) {
//                    cellValue = tempObj[relArry[i+1]];
//                }
//            }
//        }
//        else if(arrySize === 1) {
//            cellValue = currentRecord[relArry[0]];
//        }
//        else {
//            cellValue = currentRecord[relArry[0]];
//            if(cellValue) {
//                cellValue = currentRecord[relArry[1]];
//            }
//            else {
//                cellValue = '';
//            }
//        }
//        return cellValue;
//    }
})