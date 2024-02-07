({
    // Méthode pour rafraîchir la page d'enregistrement
    refreshPage: function() {
        $A.get('e.force:refreshView').fire();
    },

    // Méthode pour charger les options de la picklist en fonction du type de modèle sélectionné
    loadPicklistOptions: function(component) {
        var action = component.get("c.getEmailTemplates");
        action.setParams({
            recordId: component.get("v.recordId"),
            templateType: component.get("v.selectedRadio")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var picklistOptions = result.map(item => {
                    return { label: item.Name, value: item.Id };
                });
                component.set("v.picklistOptions", picklistOptions);
                component.set("v.picklistDisabled", false);
            } else {
                console.log('Error loading picklist options');
            }
        });

        $A.enqueueAction(action);
    },

    // Méthode pour charger le corps HTML du modèle d'email sélectionné et configurer les actions rapides
    loadBodyHtml: function(component, templateId) {
        console.log('Sending templateId to Apex:', templateId);

        var action = component.get("c.getEmailTemplatesBody");
        action.setParams({ templateId: templateId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result && result.length > 0) {
                    var emailTemplate = result[0];
                    var htmlBody = emailTemplate.HtmlValue + emailTemplate.EnhancedLetterhead.LetterheadFooter;

                    component.set("v.htmlBody", emailTemplate.HtmlValue);
                    component.set("v.subject", emailTemplate.Subject);
                    component.set("v.LetterheadFooter", emailTemplate.EnhancedLetterhead.LetterheadFooter);

                    // Configuration des actions rapides via quickActionAPI
                    var actionAPI = component.find("quickActionAPI");
                    var fields = {
                        htmlBody: { value: htmlBody },
                        subject: { value: component.get("v.subject") }
                    };

                    var args = component.get("v.selectedRadio") == 'SME' ? 
                               { actionName: "Case.EmailSME", targetFields: fields } : 
                               { actionName: "Case.ClientEmail", targetFields: fields };

                    actionAPI.setActionFieldValues(args).then(function(result) {
                        console.log('Action fields set successfully:', result);
                    }).catch(function(error) {
                        console.log('Error in setting action fields:', error);
                    });
                }
            } else {
                console.log('Error loading email body:', response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    
    // Méthode pour afficher un message toast
    toast: function(component, message, type, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title || "Message",
            "type": type || "info",
            "message": message
        });
        toastEvent.fire();
    }
})