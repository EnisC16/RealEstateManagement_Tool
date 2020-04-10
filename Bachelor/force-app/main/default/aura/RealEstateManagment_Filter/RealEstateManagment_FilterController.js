({
    filterBtn : function(cmp, event, helper) {
        var appEvent = $A.get("e.c:RealEstate_FilterEvent");
        appEvent.setParams({
            'bathrooms' :  cmp.get('v.bathrooms'),
            'bedrooms' :  cmp.get('v.bedrooms'),
            'radius' :  cmp.get('v.radius'),
            'city' :  cmp.get('v.city'),
            'postalcode' :  cmp.get('v.postalcode'),
            'minPrice'  : cmp.get('v.minPrice'),
            'maxPrice'  : cmp.get('v.maxPrice')
        });
        appEvent.fire();
    },

    resetBtn : function(cmp, event, helper) {
        cmp.set('v.bathrooms',1);
        cmp.set('v.bedrooms',1);
        cmp.set('v.radius',10);
        cmp.set('v.city',null);
        cmp.set('v.postalcode',null);
        cmp.set('v.minPrice',null);
        cmp.set('v.maxPrice',null);

        var appEvent = $A.get("e.c:RealEstate_FilterEvent");
        appEvent.setParams({
            'bathrooms' :  1,
            'bedrooms' :  1,
            'radius' :  10,
            'city' :  null,
            'postalcode' :  null,
            'minPrice'  : null,
            'maxPrice'  : null
        });
        appEvent.fire();
    }
})
