({	/**
     * 
     */
	fetchTaskHelper : function(component, event, helper) {
    	component.set('v.mycolumns', [
        	{label: 'Date', fieldName: 'Subject', type: 'text', sortable: true},
            {label: 'Phone', fieldName: 'Customer_Phone_Number__c', type: 'Phone'},
            {label: 'Service Name', fieldName: 'Service_Name__c', type: 'text', sortable: true}
		]);
        
        var action = component.get("c.getTasks");
        action.setParams({});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				component.set("v.taskList", response.getReturnValue());
				var myList = component.get("v.taskList");
				if (myList && myList.length > 0) {
					component.set("v.displayCmp", true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})