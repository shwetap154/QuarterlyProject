({
    getRelName : function(currentField,currentRecord) {
        var relArry = currentField.lookupFieldName.split('.');
        var arrySize = relArry.length;
        var cellValue = '';
        
        if(arrySize > 2) {
            for(var i=0;i<arrySize-1;i++) {
                var tempObj;
                var curTempFld = relArry[i];
                
                if(tempObj == null) {
                    tempObj = currentRecord[curTempFld];
                } else {
                    tempObj = tempObj[curTempFld];
                }
                
                if(i == arrySize-2 && tempObj != null) {
                    cellValue = tempObj[relArry[i+1]];
                }
            }
        } else if(arrySize === 1) {
            cellValue = currentRecord[relArry[0]];
        } else {
            cellValue = currentRecord[relArry[0]];
            if(cellValue) {
                cellValue = cellValue[relArry[1]];
            } else {
                cellValue = '';
            }
        }
        return cellValue;
    }
})