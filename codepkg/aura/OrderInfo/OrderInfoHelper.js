({
	getTerritories : function(component, event) {
        
         var action = component.get("c.getUserTerritories");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.items', JSON.parse(response.getReturnValue()));
            }
            
        });
        $A.enqueueAction(action);
        
    },     
    loadSelectOptions: function(component, event, helper) {
        // Request from server
        var action = component.get("c.getCurrentUserTerritories");
        action.setCallback(this, function(result){
            var territories = result.getReturnValue();
            //alert('The territories are' + territories);
            component.set("v.options", territories);
             if(territories.length > 1 ){
                    component.set("v.isMultipleTerritories", true);                     
                 }
            
        });
        $A.enqueueAction(action);
    }, 
    
    getOrders : function(component, helper,isRefresh) {       
         var dtable = component.find('dt');       
		 
		var param =  {
            'extobject': component.get("v.extObject"),
            'recordId': component.get("v.recordId"),
            'sfObject': component.get("v.sfObject"), 
            'territoryName': component.get("v.territoryName"),
            'searchField':component.get("v.searchField"),
            'searchText':component.get("v.searchString"),
            'startDate':component.get("v.dataInValue"),
            'endDate':component.get("v.dataEndValue"),
            'OrderStatus':component.get("v.OrderTypeValue"),
            'isRefresh':isRefresh
		};       
   
		//dtable.getRecords(JSON.stringify(param));
		dtable.getRecords(param);
            
    },
    getOrderDetails : function(component, orderNumber) {       
         var ordDetails = component.find('odt');
        // alert('Order Number in helper is '+ orderNumber );
		ordDetails.getOrderDetails(orderNumber);
		
            
    },
    setDefaults : function(component) {       
    
		  component.set("v.territoryName", "");
          component.set("v.dataInValue", "");
          component.set("v.dataEndValue", "");
          component.set("v.searchString", "");
          var sel = component.find('field');
          sel.set("v.value","--Select--");
            
    },
    setFilterTerritoryCode : function(component) {       
    
		  component.set("v.territoryName", "");
          component.set("v.dataInValue", "");
          component.set("v.dataEndValue", "");
          component.set("v.searchString", "");
          var sel = component.find('field');
          sel.set("v.value","--Select--");
            
    },
    setFilterOrderStatus : function(component) {       
    
		  component.set("v.territoryName", "");
          component.set("v.dataInValue", "");
          component.set("v.dataEndValue", "");
          component.set("v.searchString", "");
          var sel = component.find('field');
          sel.set("v.value","--Select--");
            
    },
   
})