({
	doInit: function(component, event, helper) { 
        
        var myPageRef = component.get("v.pageReference");
        var orderNumber = myPageRef.state.c__ordernumber; 
        var isRefresh = 'Y';
        if (orderNumber != null)
        {
           
            component.set("v.isOpen", true);
            component.set("v.isList", false);       
            helper.getOrderDetails(component, orderNumber );
        }
        else
        {
            helper.getTerritories(component, event, helper);
            helper.loadSelectOptions(component, event, helper);
            helper.getOrders(component, event,isRefresh) ;
        }
      
        
        
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    updatecount : function(component, event, helper) {
        
         var objChild = component.find('dt');
       // alert("Method Called from Child " + objChild.get('v.recordCount'));
        component.set("v.TotalRecords", objChild.get('v.recordCount'));
        
    },
    handleOptionSelected: function (component, event,helper) {
        //Get the string of the "value" attribute on the selected option
        //
        var selected = component.find("a_opt").get("v.value");
        
         //alert('current t is ' + selected);
        component.set("v.territoryName", selected);
       // var territory = component.get("v.territoryName"); 
       //alert('current t is ' + territory);
       var isRefresh = 'Y';
       helper.getOrders(component, event, isRefresh);
        
        
    },
    filterDataByTerritory: function(component, event, helper) {
        event.preventDefault();        
        component.set("v.territoryName", event.getParam('name'));
        var territory = component.get("v.territoryName");        
        if ((component.get("v.searchField") == 'tercode')||(component.get("v.searchField") == 'arcode'))
        {
            var sel = component.find('field');
            sel.set("v.value","--Select--");
            component.set("v.searchString", "");
            component.set("v.searchField","");            
        }        
        var isRefresh = 'Y';
        helper.getOrders(component, event, isRefresh);        
    },
    handleKeyUp : function (component, event, helper) {
        if(event.which == 13) {       
    
             var isRefresh = 'Y';
              helper.getOrders(component, event, isRefresh);
             if ((component.get("v.searchField") == 'tercode')||(component.get("v.searchField") == 'arcode'))
                {
                    helper.getTerritories(component, event, helper);
                }
              
        }
        
    },
    parentComponentEvent: function(component, event, helper) {         
        var message = event.getParam("message");        
        component.set("v.isOpen", true);
        var ordDetails = component.find('odt');
        ordDetails.getOrderDetails(message);       
    },
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.isOpen", false);
    },
     handleSelect: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");  
        component.set("v.OrderTypeValue", selectedMenuItemValue);        
        if (selectedMenuItemValue == 'C')
        {
            component.set("v.OrderType", "Closed Orders");            
        }
        else if (selectedMenuItemValue == 'X')
        {
            component.set("v.OrderType", "Cancelled Orders");
        }
        else if (selectedMenuItemValue == 'O')
        {
            component.set("v.OrderType", "Open Orders");
        }
        
         var isRefresh = 'Y';
        // helper.setDefaults(component);
         //helper.getTerritories(component, event, helper);
         helper.getOrders(component, event, isRefresh);
        
    },    
    onChangeField: function (component, event, helper) {
     
        var cValue = event.getSource().get("v.value");        
        component.set("v.searchField", cValue); 
        //component.set("v.territoryName", "");
   
        if (cValue == 'orderdate')
        {            
            component.set("v.displayDates", true);
            component.set("v.displaySearchBox", false);
           // component.set("v.dataInValue", "");
           // component.set("v.dataEndValue", "");
        }
        else
        {
            component.set("v.displayDates", false);
            component.set("v.displaySearchBox", true);
            // component.set("v.searchString", "");
            //component.set("v.searchInput", null);
        }
            
         //var isRefresh = 'Y';
          //helper.getTerritories(component, event, helper);
        //helper.getOrders(component, event, isRefresh);
        
    }
})