({
	doAction : function(component, event, helper) {
        var params = event.getParam("arguments");
       
        if (params) {            
            helper.getOrderDetails(component, params.orderNumber );            
        }
    } ,
})