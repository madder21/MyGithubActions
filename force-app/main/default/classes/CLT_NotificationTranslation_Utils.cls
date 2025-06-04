/**
 * @author Sarah AYOUN (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is the handler of Apex Trigger NotificationTrigger on Object Notification__c
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 1.0		|2024/05/22			|.Sarah A	|.				    |.add of method replaceDynamicFields						
*/
public with sharing class CLT_NotificationTranslation_Utils {
    /*
     * @METHOD 	: setNotificationTranslations
     * @DESC 	: Return the notifications updated with the body and title translated to the user language if translation exist
     * @PARAM 	: notifications : list of notifications to translate
     * @RETURN 	: .
     */
    public static void setNotificationTranslations(List<Notification__c> notifications) {
        List<String> notifSettingIds = new List<String>();
        List<String> userToNotifyIds = new List<String>();
        for(Notification__c notif : notifications) {
            notifSettingIds.add(notif.NotificationManagementId__c);
            userToNotifyIds.add(notif.User__c);
        }

        Map<String, Map<String,String>> notificationTransaltionMap = getNotificationTransaltionMap(notifSettingIds);
        Map<String,String> usersLanguageMap = getUsersLanguageMap(userToNotifyIds);

        for(Notification__c notif : notifications) {
            String userLang = usersLanguageMap.containsKey(notif.User__c) ? usersLanguageMap.get(notif.User__c) : 'en_US';

            if(notificationTransaltionMap.containsKey(userLang + '_' + notif.Type__c + '_' + notif.Subtype__c)) {
                Map<String,String> notificationTranslationMap = notificationTransaltionMap.containsKey(userLang + '_' + notif.Type__c + '_' + notif.Subtype__c) ? 
                notificationTransaltionMap.get(userLang + '_' + notif.Type__c + '_' + notif.Subtype__c) :
                notificationTransaltionMap.get('en_US_' + notif.Type__c + '_' + notif.Subtype__c);

                if(notificationTranslationMap.containsKey('name')) {
                    notif.Title__c = notificationTranslationMap.get('name');
                }

                if(notificationTranslationMap.containsKey('message')) {
                    notif.Body__c = notificationTranslationMap.get('message');
                }
            }
        }
    }

    /*
     * @METHOD 	: getNotificationTransaltionMap
     * @DESC 	: Return a Map with all existing transaltions of notifications to translate
     * @PARAM 	: notificationMgmntIds : list of Ids of CLT_NotificationManagement__mdt to translate
     * @RETURN 	: a map with key as metadata and the value is map of translations of all existing translations
     */
    public static Map<String, Map<String,String>> getNotificationTransaltionMap(List<String> notificationMgmntIds) {
        Map<String, Map<String,String>> notificationTransaltionMap = new Map<String, Map<String,String>>();
        for(CLT_NotificationManagement__mdt notificationSetting : [SELECT Id,Type__c,Subtype__c,Name__c,Message__c,Translation__c
                                                                FROM CLT_NotificationManagement__mdt
                                                                WHERE Id IN :notificationMgmntIds]) {
            if(!String.isEmpty(notificationSetting.Translation__c)) {
                Map<String, Object> translationMap = (Map<String, Object>)JSON.deserializeUntyped(notificationSetting.Translation__c);
                for(String langCode : translationMap.keySet()) {
                    Map<String, String> translationMapObj = (Map<String, String>)JSON.deserialize(JSON.serialize(translationMap.get(langCode)) ,Map<String,String>.class);
                    notificationTransaltionMap.put(langCode + '_' + notificationSetting.Type__c + '_' + notificationSetting.Subtype__c, translationMapObj);
                }
            }
            if(!notificationTransaltionMap.containsKey('en_US_' + notificationSetting.Type__c + '_' + notificationSetting.Subtype__c)) {
                notificationTransaltionMap.put('en_US_' + notificationSetting.Type__c + '_' + notificationSetting.Subtype__c, new Map<String, String>{'name' => notificationSetting.Name__c, 'message' => notificationSetting.Message__c});
            }
    
        }        
        return notificationTransaltionMap;
    }

    /*
     * @METHOD 	: getUsersLanguageMap
     * @DESC 	: Return a Map of user Ids with their language
     * @PARAM 	: userToNotifyIds : list of Ids of users that have a notification related to them to translate
     * @RETURN 	: a map with key of user Id and value of the language configurate for him
     */
    public static Map<String,String> getUsersLanguageMap(List<String> userToNotifyIds) {
        Map<String,String> usersLanguageMap = new Map<String,String>();
        for(User u : [SELECT Id,LanguageLocaleKey FROM User WHERE Id IN :userToNotifyIds]) {
            usersLanguageMap.put(u.Id, u.LanguageLocaleKey);
        }
        return usersLanguageMap;
    }

    /*
     * @METHOD 	: replaceDynamicFields
     * @DESC 	: replace the dynamic fields, if are available in the title or body of the notifications
     * @PARAM 	: notifications : list of notifications to replace the dynamic fields with expected values if exist
     * @RETURN 	: .
     */
    public static void replaceDynamicFields(List<Notification__c> notifications) {
        Map<String, String> clientsMap = new Map<String, String>();
        List<Notification__c> notificationWithDynamicFields = new List<Notification__c>();

        for(Notification__c notif : notifications) {
            if((!String.isEmpty(notif.Body__c) && notif.Body__c.contains('{{clientName}}')) || (!String.isEmpty(notif.Title__c) && notif.Title__c.contains('{{clientName}}'))) {
                notificationWithDynamicFields.add(notif);
                if(!String.isEmpty(notif.Client__c)) {
                    clientsMap.put(notif.Client__c, '');
                }
            }
        }

        if(notificationWithDynamicFields.size() > 0) {
            for(Account client : [SELECT Id,Name FROM Account WHERE Id IN :clientsMap.keySet()]) {
                clientsMap.put(client.Id, client.Name);
            }

            for(Notification__c notif : notificationWithDynamicFields) {
                if(!String.isEmpty(notif.Body__c) && notif.Body__c.contains('{{clientName}}')) {
                    notif.Body__c = notif.Body__c.replace('{{clientName}}', !String.isEmpty(notif.Client__c) ? clientsMap.get(notif.Client__c) : '');
                }
                if(!String.isEmpty(notif.Title__c) && notif.Title__c.contains('{{clientName}}')) {
                    notif.Title__c = notif.Title__c.replace('{{clientName}}', !String.isEmpty(notif.Client__c) ? clientsMap.get(notif.Client__c) : '');
                }
            }
        }
    }
}