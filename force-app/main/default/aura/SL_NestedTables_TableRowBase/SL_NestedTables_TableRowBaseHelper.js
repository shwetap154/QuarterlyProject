/**
 * Created by jerridkimball on 2018-06-05.
 */
({
    /* From DynamicTable */
    deleteRecord: function(cmp, evt, hlpr){
        var action = cmp.get("c.deleteRecord");
        var currentRecord = cmp.getConcreteComponent().get("v.currentRecord.record");

        if (!confirm("Are you sure you want to delete this record?"))
            return;

        action.setParams({
            "recordId": currentRecord.Id
        });

        action.setCallback(this, function(response){
            var status = response.getState();
            var params = {};

            if (status === "SUCCESS") {
                params = {
                    title:   'Success',
                    message: 'Record was deleted successfully.',
                    type:    'success'
                };
            }
            else if(status === "ERROR") {
                var errors = response.getError();

                params = {
                    title:   'Error',
                    message: 'An error occurred. Please contact a System Administrator.',
                    type:    'error'
                };

                if (errors && errors[0] && errors[0].message) {
                    params.message = errors[0].message;
                }
            }
            else {
                params = {
                    title:   'Unknown',
                    message: 'The result of the deletion is unknown.',
                    type:    'warning'
                };
            }

            var toastEvent = $A.get("e.force:showToast");

            toastEvent.setParams(params);

            toastEvent.fire();
        });

        $A.enqueueAction(action);
    },

    editRecord: function(cmp, evt, hlpr) {
        var editRecordEvent = $A.get("e.force:editRecord");

        editRecordEvent.setParams({
            "recordId": cmp.getConcreteComponent().get("v.currentRecord.record.Id")
        });

        editRecordEvent.fire();
    },
})