({
    init : function(component, event) {
        var flow = component.find("flowData");
        flow.startFlow("iDevelop_Create_Benchmark");
    },
    handleStatusChange: function(component, event) {
        if (event.getParam("status") == "FINISHED") {
            // If a Benchmark was not created, navigate back a screen.
            // If it was created, it will navigate to the record
            var outputVariables = event.getParam("outputVariables");

            var createdBenchmark;
            for (var i = 0, len = outputVariables.length; i < len; i++) {
                if (outputVariables[i].name === "createdBenchmark") {
                    createdBenchmark = outputVariables[i].value;
                }
            }

            if (!createdBenchmark) {
                window.history.back();
            }
        }
    }
})