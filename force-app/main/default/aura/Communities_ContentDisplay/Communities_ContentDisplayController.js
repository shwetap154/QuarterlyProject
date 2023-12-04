({
    doInit: function(component, event, helper) {
        
        var allSpecies = [
            { label: 'Poultry', active: false, imageSrc: $A.get('$Resource.Communities_Poultry_Filter') },
            { label: 'Ruminants', active: false, imageSrc: $A.get('$Resource.Communities_Ruminants_Filter') },
            { label: 'Equine', active: false, imageSrc: $A.get('$Resource.Communities_Equine_Filter') },
            { label: 'Swine', active: false, imageSrc: $A.get('$Resource.Communities_Swine_Filter') },
            { label: 'Companion Animals', active: false, imageSrc: $A.get('$Resource.Communities_Companion_Animals_Filter') }
        ];
        
        component.set('v.allSpecies', allSpecies);
        
        var params = {
            componentName: 'Communities_ContentDisplay'
        };
        
        helper
        
        .callApex(component, 'c.retrieveContentRecords', params) // Call Apex Controller to query out Content Records
        .then(function(contentVersions) {
            component.set('v.contentVersions', contentVersions);
            helper.populateTableRows(component, contentVersions); // Call helper method to populate rows
        })
        .catch(function(err) {
            component.set('v.loading', false);
            component.set('v.errorMessage', 'There is an error loading the content records. Error: ' + JSON.stringify(err));
        });
        
        helper
        
        .callApex(component, 'c.getBaseURL') // Call Apex Controller to generate Base URL for download link
        .then(function(baseURL) {
            component.set('v.baseURL', baseURL);
        })
        .catch(function(err) {
            component.set('v.loading', false);
            component.set('v.errorMessage', 'There is an error getting the domain url. Error: ' + JSON.stringify(err));
        });
    },
    // When the Species Filter Icons are selected, update filters controlling Content Versions 
    onFilterChange: function (component, event, helper) {
        var params = event.getParams();
        var allSpecies = component.get('v.allSpecies');
        var contentVersions = component.get('v.contentVersions');
        var searchInput = component.get('v.searchInput').toLowerCase();
        
        // Find the Species label that was clicked and update its 'active' property to the event's active property (i.e. true)
        allSpecies.find(function (species) {
            return species.label === params.label;
        }).active = params.active;
        
        //  var speciesActive = allSpecies.some(function(species) {
      //  return species.active;
       // });
       // var currentFilters = helper.getCurrentFilter(allSpecies);
        
        component.set('v.allSpecies', allSpecies);
        var filteredContentVersionsList = helper.filterContentVersions(component, contentVersions, allSpecies, searchInput);
        helper.populateTableRows(component, filteredContentVersionsList);
    },
    
    // TPDEV-759-created by sweta kumari-----> Search Filter for content version 
    handleSearchTextChange: function (component, event, helper) {
        var searchInput = component.get('v.searchInput').toLowerCase();
        var contentVersions = component.get('v.contentVersions');
        var allSpecies = component.get('v.allSpecies');
        var filteredContentVersionsList = helper.filterContentVersions(component, contentVersions, allSpecies, searchInput); 
        helper.populateTableRows(component, filteredContentVersionsList);
    },
    
    // When the "Previous Page" and "Next Page" buttons are selected, return the correct number of Content Versions
    navigatePages: function(component, event, helper) {
        {
            var pageAction = event.currentTarget.getAttribute('name');
            var recordsToShow = component.get('v.recordsToShow');
            var filteredContentVersions = component.get('v.filteredContentVersions');
            var currentPage = component.get('v.currentPage');
            var contentVersionsToDisplay = [];
            
            if (pageAction == 'nextPage') {
                //i.e. page is moving from 2 to 3, show records 30 -> 44
                contentVersionsToDisplay = filteredContentVersions.slice(
                    currentPage * recordsToShow, //i.e. current page = 2 * 15 records -> 30
                    currentPage * recordsToShow + recordsToShow //i.e. 30 + 15 records = 45 (slice doesn't include last element)
                );
                
                currentPage++;
                component.set('v.contentVersionsToDisplay', contentVersionsToDisplay);
                component.set('v.currentPage', currentPage);
            } else {
                //i.e. page is moving from 3 to 2, show records 15 -> 29
                contentVersionsToDisplay = filteredContentVersions.slice(
                    Math.max(0, currentPage - 2) * recordsToShow, //i.e. current page = (3 - 2) = 1 * 15 -> 15
                    Math.max(0, currentPage - 2) * recordsToShow + recordsToShow //i.e. 15 + 15 = 30 (slice doesn't include last element)
                );
                
                currentPage--;
                component.set('v.contentVersionsToDisplay', contentVersionsToDisplay);
                component.set('v.currentPage', currentPage);
            }
        }
    }
});