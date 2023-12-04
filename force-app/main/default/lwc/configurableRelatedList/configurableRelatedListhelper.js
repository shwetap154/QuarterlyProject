/*
  @File Name          : configurableRelatedListhelper.js
  @Description        : This file contains the logic to define the information for the columns that will be displayed
                        on the datatable.
  @Author             : Slalom run:CRM
  @Group              : run:CRM
  @Last Modified By   : miguel.torres@slalom.com
  @Last Modified On   : 6/17/2020, 10:00:00 AM
*/

export const helper = {

    // helper function used to find the object with the most keys
    findKeyList(recordList) {

        const keySet = new Set([]);

        recordList.forEach(record => {

            const keyList = Object.keys(record);
            
            keyList.forEach(key => {
                keySet.add(key);
            })
        })

        return [... keySet];
    },

    makeColumns(labelNames, keyList) {
        
        const makeUrl = [];
        const columnList = []; 
        const percentList = [];
        const timeList = [];
        keyList.forEach(key =>{
            
            if (labelNames[key]){
                
                    let realType = labelNames[key].type;

                    realType = realType.toLowerCase();

                    if (realType === 'string' || realType === 'picklist' || realType === 'textarea'  ) realType = 'text'; 
                    if (realType === 'double' ) realType = 'number';
            
                    // datetime comes up as both date and datetime types.
                    // formats date time to display nicely in data table.
                    if (realType === 'datetime') {
                        let label = labelNames[key].label;
                        const column = { 
                            label: label, 
                            fieldName: key, 
                            type: 'date', 
                            typeAttributes: {
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric',
                              hour: '2-digit',
                              minute: '2-digit',
                              second: '2-digit',
                              hour12: true
                            },
                            cellAttributes: {alignment: 'left'},
                            sortable: true,
                            initialWidth: 200
                        }
                        columnList.push(column);
                    } else if (realType === 'date') {
                        realType = 'date-local'
                    // formates so that time displays nicely in data table
                    } else if (realType === 'time'){
                        timeList.push(key)
                        let label = labelNames[key].label;
                        const column = { 
                            label: label, 
                            fieldName: key, 
                            type: 'date', 
                            typeAttributes: {
                              hour: '2-digit',
                              minute: '2-digit',
                              hour12: true
                            },
                            cellAttributes: {alignment: 'left'},
                            sortable: true,
                            initialWidth: 200
                        }
                        columnList.push(column);
                    }
                    
                    // used for making the id referance to the name in datatable for a link to the record
                    if (realType === 'id' || realType === 'reference' ){
                        makeUrl.push(key)
                        let label = labelNames[key].label;
                        let theLabelName = '';
                        let isSortable = true;
                        label = label.replace("ID", "");
                        
                        if (realType === 'reference'){
                            isSortable = false;
                            var correctKey = key.slice(0, -1) + 'r';
                            theLabelName = correctKey + 'IdLabel';
                        
                        // edge case when dealing with Case records and making a link based on the auto number
                        } else if (realType === 'id' && label !== 'Case'){
                            theLabelName = 'ExternalId';
                            label = 'RefLabs Order';

                        } else {
                            theLabelName = 'CaseNumber';
                        }

                        // sets up url link for record in view in datatable
                        const column = {
                            label: label,
                            sortable:isSortable,
                            fieldName: key, type: 'url', 
                            cellAttributes: {alignment: 'left'},
                            typeAttributes: {label: {fieldName:theLabelName} , target: '_self'},
                            initialWidth: 200,
                        }
                        
                        columnList.push(column);

                    // checks each condition to make sure a column was not already made in datatable
                    } else if (key !== 'Name' && key !== 'CaseNumber' && realType !== 'datetime' && realType !== 'encryptedstring' && realType !== 'time'){
                        if (realType === 'percent'){percentList.push(key)}
                        const column = {label: labelNames[key].label, cellAttributes: {alignment: 'left'} , sortable: true, fieldName: key, type: realType, initialWidth: 200};
                        columnList.push(column);   
                    }

               }
            
        })

        return { makeUrl, columnList, percentList, timeList};
    }  
}