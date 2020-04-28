({
    doInit : function(cmp, event, helper) {
        var recordId = cmp.get('v.recordId');
        console.log('recordId...',recordId);
        var action = cmp.get("c.getPropertyDetails");
        action.setParams({ 
            recordId : recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var property = response.getReturnValue();
                cmp.set('v.property', property);
            }
            else if (state === "INCOMPLETE") {
                console.log('incomplete');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    closeModel : function(cmp, event, helper) {
        cmp.set('v.recordId',null);
    },

    closeModel : function(cmp, event, helper) {
        cmp.set('v.recordId',null);
    }
})
