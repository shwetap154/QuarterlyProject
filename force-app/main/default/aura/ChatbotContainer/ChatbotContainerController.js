({
    doInit: function (component, event, helper) {
        // Define the properties for the chatbot dialog
        var dialogProperties = {
            dialogId: 'YOUR_DIALOG_ID', // Replace with your Dialog ID
            chatTitle: 'Chat with Einstein Bot',
            prechatFields: [],
        };

 

        // Create the chatbot tab
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openTab({
                parentTabId: focusedTabId,
                url: '/lightning/cmp/c__ChatbotTab', // Change to your component's URL
                focus: true
            }).then(function (tabId) {
                // Set the properties of the chatbot dialog
                workspaceAPI.getTabInfo({
                    tabId: tabId
                }).then(function (tabInfo) {
                    var tabId = tabInfo.tabId;
                    workspaceAPI.refreshTab({
                        tabId: tabId,
                        includeAllSubtabs: false
                    }).then(function () {
                        workspaceAPI.focusTab({
                            tabId: tabId
                        });
                        helper.startChatbot(dialogProperties);
                    });
                });
            });
        });
    }
})