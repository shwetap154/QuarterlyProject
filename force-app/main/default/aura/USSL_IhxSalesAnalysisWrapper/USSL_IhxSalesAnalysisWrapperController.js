({
    doInit : function(component, event, helper) {
		var idStr = component.get("v.recordId");
		var urlParam;
		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.

            if (sParameterName[0] === 'c__prod') { 
				if (sParameterName[1] === undefined) {
					urlParam = '';
				} else {
					urlParam = sParameterName[1];
				}
            }
        }
        console.log('urlParam'+urlParam); 
		var urlStr = '/apex/IXHSalesAnalysis?Id=' + idStr + '&prod=' + urlParam;
		component.set("v.urlString",urlStr);
    }
})