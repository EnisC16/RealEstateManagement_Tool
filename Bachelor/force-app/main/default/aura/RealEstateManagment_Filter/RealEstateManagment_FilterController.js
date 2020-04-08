({
    filterBtn : function(cmp, event, helper) {
        var appEvent = $A.get("e.c:RealEstate_FilterEvent");
        appEvent.setParams({
            'bathrooms' :  cmp.get('bathrooms'),
            'bedrooms' :  cmp.get('bedrooms'),
            'radius' :  cmp.get('radius'),
            'city' :  cmp.get('city'),
            'postalcode' :  cmp.get('postalcode')
        });
        appEvent.fire();
    },

    resetBtn : function(cmp, event, helper) {
        var appEvent = $A.get("e.c:RealEstate_FilterEvent");
        appEvent.setParams({
            'bathrooms' :  null,
            'bedrooms' :  null,
            'radius' :  null,
            'city' :  null,
            'postalcode' :  null
        });
        appEvent.fire();
    }
})
