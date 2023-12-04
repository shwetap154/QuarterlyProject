({
  doInit: function(component, event, helper) {
    var params = { componentName: 'Communities_ContentNewsFeed' };

    //Retrieve Content Version records
    helper
      .callApex(component, 'c.retrieveContentRecords', params)
      .then(function(contentVersions) {
        component.set('v.contentVersions', contentVersions);
        component.set('v.loading', false);
      })
      .catch(function(err) {
        component.set('v.loading', false);
        component.set('v.errorMessage', 'There is an error loading the content records. Error: ' + err);
      });

    // Generate Base URL for download link
    helper
      .callApex(component, 'c.getBaseURL')
      .then(function(baseURL) {
        console.log('This is the Base URL: ' + baseURL);
        component.set('v.baseURL', baseURL);
      })
      .catch(function(err) {
        component.set('v.loading', false);
        component.set('v.errorMessage', 'There is an error getting the domain url. Error: ' + err);
      });
  }
});