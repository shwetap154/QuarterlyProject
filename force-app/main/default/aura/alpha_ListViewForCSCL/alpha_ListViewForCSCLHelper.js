({  
    
    //get Industry Picklist Value
    getIndustryPicklist: function(component, event) {
        var action = component.get("c.getIndustry");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var industryMap = [];
                for(var key in result){
                    industryMap.push({key: key, value: result[key]});
                }
                component.set("v.industryMap", industryMap);
            }
        });
        $A.enqueueAction(action);
    },
      
//get Month Picklist Value
    getMonthPicklist: function(component, event) {
        var action = component.get("c.getMonth");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                var monthMap = [];
                for(var key in result){
                    monthMap.push({key: key, value: result[key]});
                }
                component.set("v.monthMap", monthMap);
            }
        });
        $A.enqueueAction(action);
    },

   //get Year Picklist Value
    getYearPicklist: function(component, event) {
        var action = component.get("c.getYear");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                var yearMap = [];
                for(var key in result){
                    yearMap.push({key: key, value: result[key]});
                }
                component.set("v.yearMap", yearMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    geturl : function(component) {

        var action = component.get("c.getbaseURL")

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
             var url = response.getReturnValue() + "/";
             component.set("v.urlname", url);
            }
        });
   		$A.enqueueAction(action);
    }
})