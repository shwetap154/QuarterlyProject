({
    startChatbot: function (dialogProperties) {
        var chatAPI = window.embedded_svc;
        chatAPI.settings.displayHelpButton = false;
        chatAPI.settings.displayMinimizedChatHeader = false;

 

        // Start the chat with the specified dialog
        chatAPI.startChatWithPrechatFields(dialogProperties.prechatFields, function () {
            chatAPI.addCustomDetail('DialogId', dialogProperties.dialogId);
            chatAPI.setPrechatFieldsVisibility(true);
            chatAPI.openPrechatScreen();
        });
    }
})