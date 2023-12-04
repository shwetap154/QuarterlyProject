({
    handleSubmitClick: function (component, event, helper) {

        let button = event.getSource();
        button.set('v.disabled', true);

        const dealId = component.get('v.recordId');

        // submit
        helper.callApex(component, 'c.submit', {
            'dealId': dealId,
        })
        .then(function(response) {
            console.log('Response from APEX Controller', response);

            // SUCCESS
            if (response == '') {
                console.log("submit - SUCCESS!");
                helper.notifyUser('Success!', 'The Quotes were fixed and the Sales Reps were notified by email.', 'success');
            }
            // ERRROR
            else {
                console.log("submit - ERROR: " + response);
            }
        })
        .catch(function(err) {
            let message = err[0].message;
            console.error('submit - UNHANDLED ERROR: ' + message);
        });

        helper.closeModal();
    },

    handleCancelClick: function (component, event, helper) {
        helper.closeModal();
    }

})