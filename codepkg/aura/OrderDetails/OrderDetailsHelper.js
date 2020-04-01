({
	getOrderDetails: function(component, orderNumber) {
        
         //alert("The order number is " + cmp.get("v.pageReference").state.id) ;
       //component.set("v.isOpen", true);
       //component.set("v.isList", false);
        
       component.find("Id_spinner").set("v.class" , 'slds-show');

    
        
        component.set("v.orderNoteColumns", [         
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
      { label: "Note", fieldName: "note", type: "text",wrapText: true },
   

    ]);
   
      component.set("v.orderlineColumns", [         
     { label: "Line Item", fieldName: "productId", type: "text",wrapText: true, cellAttributes: { alignment: 'left' }},      
      { label: "Line Description", fieldName: "productDescription", type: "text",wrapText: true },
      { label: "Line Status", fieldName: "statusDescription", type: "text",wrapText: true },
      {label: 'Quantity Ordered', fieldName: 'quantityOrdered', type: 'number', cellAttributes: { alignment: 'left' }},     
      { label: "Order Price", fieldName: "price", type: 'currency', cellAttributes: { alignment: 'left' }}, 
      { label: "Invoice Amount", fieldName: "invoiceAmount", type: 'currency', cellAttributes: { alignment: 'left' }},
      { label: "Gross Amount", fieldName: "listAmount", type: 'currency', cellAttributes: { alignment: 'left' }} ,
      { label: "Atp Date", fieldName: "atpDate", type: "date" },           

    ]);

    //component.set("v.rows", "");
    // cmp.set('v.isLoading', true);
    
    var action = component.get("c.getOrderDetails");
   
     action.setParams({
             "orderNumber": orderNumber
        }); 
        
        action.setCallback(this, function(result) {
            // hide spinner when response coming from server 
           component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                //alert("response is " + resultData.orderList);
              // alert("details response is " + resultData.orderDetails);
                
                var orderDetailData =  resultData.objorderDetails;                
                component.set("v.Order", orderDetailData);
                
                var orderlineData =  JSON.parse(resultData.orderLines);
                var orderlineDataCount = Object.keys(orderlineData).length;
               // Object.keys(json).length
                component.set("v.orderlineData", orderlineData);
                component.set("v.orderlineDataCount", orderlineDataCount);
                var orderNoteData =  JSON.parse(resultData.orderNotes);
                var orderNoteDataCount = Object.keys(orderNoteData).length;
                component.set("v.orderNoteData", orderNoteData);
                component.set("v.orderNoteDataCount", orderNoteDataCount);
               
               
            }
        });
        $A.enqueueAction(action);

   
        
        
    },
})