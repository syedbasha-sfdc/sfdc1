({
	doInit: function (component, event, helper) {      
        //helper.getData(component, helper);       
    },

    doAction : function(component, event, helper) {
        var params = event.getParam("arguments");
        if (params) {
            
            var param = params.param; 
            component.set("v.params", param);          
           
            helper.getlstData(component, helper,param);
        }
    } ,
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'view_details':
                helper.showRowDetails(component, row);
                break;
            case 'edit_status':
                helper.showRowDetails(component, row);
                break;
            default:
                helper.showRowDetails(row);
                break;
        }
    },
    
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        
        var param = component.get("v.params");       
       
         param.isRefresh = 'N';
         helper.getlstData(component, helper,param);
        
    },
     
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        
         var param = component.get("v.params");
        //alert('The current object is' + param.extobject);
       // alert("Search Field is " + searchField);
       
        switch (param.extobject) {                    
            case 'order':
                helper.getOrderColumns(component);
                component.set("v.keyField", "orderNumber");
                break;                    
        }
        
         param.isRefresh = 'N';
         helper.getlstData(component, helper,param);
        
        
    },
    
     
    
     
   
    
    
})