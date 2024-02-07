({
    doInit : function(component, event, helper) {
        // Initialize component attributes
        component.set("v.picklistDisabled", true);
        component.set("v.ParentId","");
        component.set("v.LetterheadFooter","");
        component.set("v.selectedRadio", "");
        component.set("v.picklistOptions", [{}]);
        component.set("v.htmlBody", "");
        component.set("v.selectedPicklist", "");
        component.set("v.radioOptions",[
            { label: 'Client', value: 'Client' },
            { label: 'SME', value: 'SME' },
        ]);
    },

    onRecordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;

        if (changeType === "CHANGED") {
            // Appeler une méthode helper pour recharger les options de la picklist
			helper.refreshPage();
            helper.loadPicklistOptions(component);
        }
    },

    handleRadioChange : function(component, event, helper) {
        component.set("v.selectedRadio", event.getSource().get("v.value"));
        helper.loadPicklistOptions(component);
    },

    fillEmailBody : function(component, event, helper) {
        helper.loadBodyHtml(component, component.get("v.selectedPicklist"));                   

    },

    handleChange : function(component, event, helper) {
        component.set("v.selectedPicklist", event.getParam("value"));
    },

})