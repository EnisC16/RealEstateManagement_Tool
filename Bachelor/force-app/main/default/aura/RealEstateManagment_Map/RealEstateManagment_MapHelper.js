({
    getFilteredProperties : function(cmp, event, helper) {
        var action = cmp.get("c.getPropertyList");
        action.setParams({ 
            bathrooms : event.getParam('bathrooms'),
            bedrooms : event.getParam('bedrooms'),
            radius : event.getParam('radius'),
            city : event.getParam('city'),
            postalcode : event.getParam('postalcode'),
            minPrice : event.getParam('minPrice'),
            maxPrice  : event.getParam('maxPrice'),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                var properties = response.getReturnValue();
                cmp.set('v.properties', properties);
                cmp.set('v.zoomLevel', 14);
                //cmp.set('v.markersTitle', '');
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
 
    }
})
