public with sharing class PAD { //Framework à utiliser ::::/
    private static PAD instance               = null;
    private static Id currentUserId           = null;
    private User currentUser                  = null;
    public Map<String, Boolean> triggerStatus = null;

    private void load() {
        currentUserId     = UserInfo.getUserId();
        list<User> users  = new list<User>([SELECT ByPassTriggers__c,name,ProfileId, Profile.Name  FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]);
        currentUser       = users.isEmpty() ? null : users[0] ;
        String bypassApex = users.isEmpty() ? null : users[0].ByPassTriggers__c ;
        triggerStatus = new Map<String, Boolean>();                
        if (byPassApex != null) {
            List<String> triggerList = bypassApex.split(';');            
            for (String triggerName : triggerList) {
                if (triggerName != null && triggerName != '') {
                    triggerStatus.put(triggerName, false);
                }
            }
        }
    }
                            
    public static PAD getInstance() {
        if (instance == null) { 
            instance = new PAD();
        }
        if (currentUserId != UserInfo.getUserId()) {     
            instance.load();
        }

        return instance;
    }
    
    public static void deactivateTrigger(String name) {
        getInstance().triggerStatus.put(name, false);
    }

    public static void activateTrigger(String name) {
        getInstance().triggerStatus.put(name, true);
    }
   
    public static boolean canRun(String name) {
        if (getInstance().triggerStatus.containsKey(name)) {
        System.debug('#### Classe PAD : le trigger ' + name + ' est-il exécutable? : ' + 
            			 getInstance().triggerStatus.get(name));
            return (getInstance().triggerStatus.get(name));
        }
        
        return true;
    }
    
    public static user getCurrentUser() {
        return getInstance().currentUser;
    }
}
