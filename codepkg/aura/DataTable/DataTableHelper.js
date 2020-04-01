({
     getlstData : function(component, helper,param) {
         
         var self = this;
        
         if (param.isRefresh =='Y')
        {           
            component.set("v.pageNumber", 1);
        }
        component.find("Id_spinner").set("v.class" , 'slds-show');
              
        var pageNumber = component.get("v.pageNumber").toString();
        var pageSize = component.get("v.pageSize").toString();

        // Get server action service
        const server = component.find('server');
        // Get server-side action
        const anAction = component.get('c.getListOfRecords');
        // Call server-side action
        server.callServer(
            anAction, // Action
            {
                'pageSize' : pageSize,            
                'pageNo' : pageNumber,
                'parameters' : JSON.stringify(param)
            }, // Action parameters
            false, // Toogles cache
            $A.getCallback(function(response) { // Success callback
                 
               // hide spinner when response coming from server 
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var resultData = response; 
                
                 if(resultData.isError){
                     var text = resultData.message;                    
                     self.handleShowErrorNotice(component,helper,text);                     
                 }
            
                var strColumns =  resultData.strDataTableColumns;
               
                component.set("v.mycolumns", strColumns);
               // component.set("v.dataSize", resultData.lstDataTableData.length);
                component.set("v.mydata", resultData.lstDataTableData);
                component.set("v.recordCount", resultData.intRecordCount);
                component.set("v.keyField", resultData.strkeyField);
                
                if(resultData.lstDataTableData.length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                
                var vx = component.get("v.method");
                //fire event from child and capture in parent
                $A.enqueueAction(vx);
                
            }),
            $A.getCallback(function(errors) { // Error callback
                 component.find("Id_spinner").set("v.class" , 'slds-hide');
                // In this example, we only display the first error message because we triggered the error ourself
                // In all other use cases make sure to display ALL error message or leave the default error handling do it
                //component.set('v.response', errors[0].message);
            }),
            false, // Keep built-in error handling
            false, // Toggles background
            false // Toggles abortable
        );

        
    },
    showRowDetails : function(component,row) {         
        var cmpEvent = component.getEvent("sampleCmpEvent"); 
        //Set event attribute value
        cmpEvent.setParams({"message" : row.orderNumber}); 
        cmpEvent.fire();      
        
    },
    handleShowErrorNotice : function(component,helper,text) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "title":"Error",
            "header": "Something has gone wrong!",
            "message": text,
            closeCallback: function() {
                //alert('You closed the alert!');
            }
        });
    },    
    handleShowWarningNotice : function(component, event, helper) {
        component.find('notifLib').showNotice({
            "variant": "warning",
            "title":"Error",
            "header": "Something has gone wrong!",
            "message": "Unfortunately, there was a problem updating the record.",
            closeCallback: function() {
                alert('You closed the alert!');
            }
        });
    },
    handleinfoToast : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant":"info",
            "title": "Notif library Success!",
            "message": "The record has been updated successfully."
        });
    },
    handlewarningToast : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant":"warning",
            "mode":"dismissable",
            "title": "Notif library Success!",
            "message": "The record has been updated successfully."
        });
    },
    handlesuccessToast : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant":"success",
            "title": "Notif library Success!",
            "mode":"sticky",
            "message": "The record has been updated successfully."
        });
    },
    handleerrorToast : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant":"error",
            "mode":"pester",
            "title": "Notif library Success!",
            "message": "The record has been updated successfully."
        });
    },
    
    getColumnAndAction : function(component) {
        var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'},
            {label: 'View', name: 'view'}
        ];
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Order Received Date', fieldName: 'AccountNumber', type: 'text'},
            {label: 'Industry', fieldName: 'Industry', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', type: 'phone'},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
    },
    getOrderColumns: function(component) {        
        component.set('v.mycolumns', [           
  {"label":"Order Number","type":"url","initialWidth":150,"typeAttributes":{"label": { "fieldName": 'orderNumber' }, target: '_self'},  "fieldName":"linkName"},
  {"label":"Order Received Date","type":"date-local","initialWidth":150,"fieldName":"orderDate"},
  {"label":"Order Amount","type":"currency","initialWidth":100,"fieldName":"amount"},
  {"label":"Currency","type":"text","initialWidth":100,"fieldName":"currencyCd"},  
  {"label":"Sold To Customer","type":"url","initialWidth":250,"typeAttributes":{"label": { "fieldName": 'soldToCustomerName' }, target: '_self'},  "fieldName":"AccountIdSoldTo"},  
  {"label":"Ship To Customer","type":"url","initialWidth":250,"typeAttributes":{"label": { "fieldName": 'shipToCustomerName' }, target: '_self'},  "fieldName":"AccountIdShipTo"},            
  {"label":"Customer PO Number","type":"text","initialWidth":250,"fieldName":"poNumber"},
  {"label":"Buying Agreement","type":"text","initialWidth":200,"fieldName":"buyingAgreement"},
  {"label":"Scheduled Ship Date","type":"date-local","initialWidth":150,"fieldName":"scheduledShipDate"},
  {"label":"Job Site","type":"text","initialWidth":100,"fieldName":"jobSite"},
  {"label":"Territory Code","type":"text","initialWidth":100,"fieldName":"sTerritoryCode"}      
        ]);
    },
    getOrderlineColumns: function(component) {        
        component.set('v.mycolumns', [         
     { label: "Line Item", fieldName: "productId", type: "text", cellAttributes: { alignment: 'left' }},      
      { label: "Line Description", fieldName: "productDescription", type: "text" },
      { label: "Line Status", fieldName: "statusDescription", type: "text" },
      {label: 'Quantity Ordered', fieldName: 'quantityOrdered', type: 'number', cellAttributes: { alignment: 'left' }},     
      { label: "Order Price", fieldName: "price", type: 'currency', cellAttributes: { alignment: 'left' }}, 
      { label: "Invoice Amount", fieldName: "invoiceAmount", type: 'currency', cellAttributes: { alignment: 'left' }},
      { label: "Gross Amount", fieldName: "listAmount", type: 'currency', cellAttributes: { alignment: 'left' }} ,
      { label: "Atp Date", fieldName: "atpDate", type: "date" },           

    ]);
    },
    getOrderNoteColumns: function(component) {        
        component.set('v.mycolumns', [         
      { label: "Note Type", fieldName: "noteType", type: "text", initialWidth: 150 },     
       {label: 'Date Time Entered', fieldName: 'dateTimeEntered', type: 'date',initialWidth: 200, typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            second: '2-digit',  
                                                                            hour12: true}},
      { label: "Entered By", fieldName: "enteredByName", type: "text",initialWidth: 200 },
      { label: "Note", fieldName: "note", type: "text" },
   

    ]);
    },        
     
    getData : function(component, helper,param) {
         alert('The parameters are' + param);
        var action = component.get("c.getListOfRecords");       
        var pageNumber = component.get("v.pageNumber").toString();
         
        action.setParams({            
            'pageNo' : pageNumber,
            'parameters' : param
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                if(resultData.length < component.get("v.pageSize")){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                //component.set("v.dataSize", resultData.length);
                component.set("v.data", resultData);
            }
        });
        $A.enqueueAction(action);
    },
     
    viewRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
     
    deleteRecord : function(component, event) {
        var action = event.getParam('action');
        var row = event.getParam('row');
         
        var action = component.get("c.deleteAccount");
        action.setParams({
            "acc": row
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var rows = component.get('v.data');
                var rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                component.set('v.data', rows);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been delete successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
     
    editRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },    
})