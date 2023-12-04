({
    callApex: function(component, methodName, params) {
        
        return new Promise(
            $A.getCallback(function(resolve, reject) {
                var action = component.get(methodName);
                
                if (params) {
                    action.setParams({
                        componentName: params['componentName']
                    });
                }
                
                action.setCallback(this, function(results) {
                    if (results.getState() === 'SUCCESS') {
                        resolve(results.getReturnValue());
                        
                        console.log("AllData"+ component.set('v.contentVersionsToDisplay', contentVersionsToDisplay));
                    } else if (results.getState() === 'ERROR') {
                        $A.log('Errors', results.getError());
                        reject(results.getError());
                    }
                });
                
                $A.enqueueAction(action);
            })
        );
    },
    
    /* getCurrentFilter: function(allSpecies) {
        var currentFilters = [];
        var activeSpecies = allSpecies.filter(function(species) {
            return species.active;
        })
        if(activeSpecies.length > 0){
            currentFilters = activeSpecies.map(function(species) {
                return species.label;
            }); 
        }
        if (currentFilters.length === 0) {
            return allSpecies.map(function(species) {
                return species.label;
            });
        }
        return currentFilters;
    }, */
    
    // onFilterChange and handleSearchTextChange both controller work as per condition of searchInput and species filter    
    filterContentVersions: function (component, contentVersions, allSpecies, searchInput) {
        var speciesFilters = allSpecies
        .filter(function (species) {
            return species.active;
        })
        .map(function (species) {
            return species.label;
        });
        
        var filteredContentVersions = contentVersions.filter(function (contentRecord) {
            var name = contentRecord.Title.toLowerCase();
            var applicableSpeciesList = contentRecord.Applicable_Species__c.split(';');
            
            var speciesFilterMatch = speciesFilters.length === 0 || applicableSpeciesList.some(function (species) {
                return speciesFilters.indexOf(species) !== -1;
            });
            
            var searchInputMatch = !searchInput || name.includes(searchInput) ;
            return speciesFilterMatch && searchInputMatch;
        });
        
        return filteredContentVersions;
    },
    
    populateTableRows: function(component, filteredContentVersions) {
        var recordsToShow = component.get('v.recordsToShow');
        var contentVersionsToDisplay = filteredContentVersions.slice(0, recordsToShow);
        var totalPageNumber = Math.ceil(filteredContentVersions.length / recordsToShow) || 1 ;
        component.set('v.filteredContentVersions', filteredContentVersions);
        component.set('v.contentVersionsToDisplay', contentVersionsToDisplay);
        component.set('v.loading', false);
        component.set('v.totalPageNumber', totalPageNumber);
        component.set('v.totalRecords', filteredContentVersions.length);
        component.set('v.currentPage', 1);
    }
});