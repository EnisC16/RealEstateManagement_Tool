({
    doInit : function(cmp, event, helper){
        helper.getFilteredProperties(cmp, event, helper);
    },

    handleMarkerSelect : function(cmp, event, helper){
        cmp.set('v.recordId', null);
        var markerId = event.getParam("selectedMarkerValue");
        console.log('markerId',markerId);
        cmp.set('v.recordId', markerId);
    },

    filterProperties : function(cmp, event, helper) {
        helper.getFilteredProperties(cmp, event, helper);
    }
})
