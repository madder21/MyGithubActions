({
	 fetchTask : function(component, event, helper) {
        helper.fetchTaskHelper(component, event, helper);
    },
    linkTask : function (component, event, helper) {
      
        let currentUrl = window.location + "";
        let lines  = component.find('linesTable').getSelectedRows();
        
        //console.log('lines **** '+JSON.stringify(lines));
        
         var updateTaskAction = component.get("c.updateTask");
         updateTaskAction.setParams({tasks: lines, urlCase: currentUrl });
        // updateTaskAction.setParams({urlCase: currentUrl });
         updateTaskAction.setCallback(this,  function(response) { 
             var state = response.getState();
             var responseValue =  response.getReturnValue();
             //refresh list
              helper.fetchTaskHelper(component, event, helper);
             var emptySelect = [];
              component.set('v.selectedRows', emptySelect);
             // this.setSelectedRows = [];
            // this.template.querySelector('lightning-datatable').selectedRows=[];
              
        });
         $A.enqueueAction(updateTaskAction);
	}
})