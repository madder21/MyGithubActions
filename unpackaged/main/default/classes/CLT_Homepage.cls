public with sharing class CLT_Homepage implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        Decimal versionNum = params.containsKey('versionNum') ? Decimal.valueOf(params.get('versionNum')) : 0;
        User user = getUser();
        Store__c userStore = getStore(user.StoreCode__c);
        return new HomepageWrapper(getPortfolioInfo(user.Id), getNews(user, userStore), getTransactionCombo(versionNum, user.Id, userStore.Id), getFeedbacks(user.Id));
    }

    public User getUser() {
        return [SELECT Id,LanguageLocaleKey,StoreCode__c
                FROM User 
                WHERE Id = :UserInfo.getUserId()];
    }

    public Store__c getStore(String storeCode) {
        List<Store__c> stores = [SELECT Id,Region__c,Country__c 
                                FROM Store__c 
                                WHERE SourceStoreId__c = :storeCode];
        if(stores.size() > 0) {
            return stores[0];
        }
        else {
            throw new BL_Exceptions.CLTException('404', 'no store with user\'s store code', 'no store with user\'s store code');
        }
    }

    public Map<String,Object> getPortfolioInfo(String userId){
        Map<String,Object> portfolioInfo = new Map<String,Object>();

        List<AggregateResult> totalSumClientSpent = [SELECT SUM(LifeTimePurchaseAmount__pc) sumLifetimeAmount
                                                        FROM Account
                                                        WHERE ClientAdvisor__pc = :userId];
        portfolioInfo.put('portfolio', (totalSumClientSpent.size() > 0 && totalSumClientSpent[0].get('sumLifetimeAmount') != null ?
                                        totalSumClientSpent[0].get('sumLifetimeAmount') : 0));
        
        List<AggregateResult> activeVicCount = [SELECT COUNT(Id) countVicClients
                                                FROM Account
                                                WHERE ClientAdvisor__pc = :userId AND LightCurrentCluster__pc = 'VIC'];
        portfolioInfo.put('activeVic', (activeVicCount.size() > 0 && activeVicCount[0].get('countVicClients') != null ?
                                        activeVicCount[0].get('countVicClients') : 0));

        List<AggregateResult> inactiveCount = [SELECT COUNT(Id) countInactiveClients
                                            FROM Account
                                            WHERE ClientAdvisor__pc = :userId AND LightCurrentCluster__pc = 'Inactive Client'];
        portfolioInfo.put('inactive', (inactiveCount.size() > 0 && inactiveCount[0].get('countInactiveClients') != null ?
                                        inactiveCount[0].get('countInactiveClients') : 0));

        List<AggregateResult> prospectsCount = [SELECT COUNT(Id) countProspectClients
                                            FROM Account
                                            WHERE ClientAdvisor__pc = :userId AND LightCurrentCluster__pc = 'Prospect'];
        portfolioInfo.put('prospect', (prospectsCount.size() > 0 && prospectsCount[0].get('countProspectClients') != null ?
                                        prospectsCount[0].get('countProspectClients') : 0));
        
        return portfolioInfo;
    }

    public Map<String, Object> getNews(User user, Store__c userStore) {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> newsResponse = new List<Map<String, Object>>();
        Map<Id, News__c> newsMap = new Map<Id, News__c>([SELECT Id,Highlighted__c,Link__c,ActionLabel__c,Title__c,Text__c,PublishStartDate__c,PublishEndDate__c,CreatedDate
                                                        FROM News__c
                                                        WHERE (PublishStartDate__c = NULL OR PublishStartDate__c <= TODAY) 
                                                            AND (PublishEndDate__c = NULL OR PublishEndDate__c >= TODAY)
                                                            AND ((Countries__c = NULL OR Countries__c INCLUDES (:userStore.Country__c)))
                                                            AND ((Region__c = NULL OR Region__c = :userStore.Region__c))
                                                        ORDER BY PublishStartDate__c DESC
                                                        LIMIT 5]);
        if(newsMap.size() <= 0) {
            return result;
        }
        
        Map<String, NewsContent__c> newsContentMap = new Map<String, NewsContent__c>();
        for(NewsContent__c nc : [SELECT Id,News__c,ContentLink__c,ContentTitle__c,ContentText__c 
                                FROM NewsContent__c 
                                WHERE News__c IN :newsMap.keySet() AND Language__c = :user.LanguageLocaleKey]) {
            newsContentMap.put(nc.News__c, nc);
        }

        for(News__c news : newsMap.values()) {

            newsResponse.add(new Map<String, Object> {
                'id' => news.Id,
                'highlighted' => news.Highlighted__c,
                'actionLabel' => !String.isEmpty(news.ActionLabel__c) ? news.ActionLabel__c : System.Label.CLT_defaultActionLabel,
                'link' => (newsContentMap.containsKey(news.id) && newsContentMap.get(news.id).ContentLink__c != NULL ? newsContentMap.get(news.id).ContentLink__c : news.Link__c),
                'title' => (newsContentMap.containsKey(news.id) && !String.isEmpty(newsContentMap.get(news.id).ContentTitle__c) ? newsContentMap.get(news.id).ContentTitle__c : news.Title__c),
                'text' => (newsContentMap.containsKey(news.id) && !String.isEmpty(newsContentMap.get(news.id).ContentText__c) ? newsContentMap.get(news.id).ContentText__c : news.Text__c),
                'startDate' => news.PublishStartDate__c,
                'endDate' => news.PublishEndDate__c,
                'createdDate' => news.CreatedDate
            });
        }

        result.put('news', newsResponse);
        result.put('documents', CLT_Utils.getDocuments((Set<String>)JSON.deserialize(JSON.serialize(newsMap.keySet()), Set<String>.class)));

        return result;
    }

    public List<Map<String, Object>> getTransactionCombo(Decimal versionNum, String userId, String storeId) {
        if(versionNum >= 2.13) {
            return getTransactionComboV2(userId);
        }
        else {
            return getTransactionCombo(userId, storeId);
        }
    }

    public List<Map<String, Object>> getTransactionCombo(String userId, String storeId) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        Map<String,Account> clientsMap = new Map<String, Account>(
                                [SELECT Id,FirstName,LastName,LastPurchaseDate__pc,LightCurrentCluster__pc,
                                    (SELECT TransactionDate__c, LocalOrTourist__c 
                                    FROM Transactions__r 
                                    WHERE TransactionDate__c = LAST_N_DAYS:13 AND Store__c = :storeId ORDER BY TransactionDate__c DESC LIMIT 1),
                                    (SELECT Id,CreatedDate 
                                    FROM Notes__r 
                                    WHERE CreatedDate = LAST_N_DAYS:13 AND CreatedById = :userId AND IsDeleted__c = FALSE),
                                    (SELECT Id,Outreach_Type__c,ActivityDate,CreatedDate
                                    FROM Tasks 
                                    WHERE CreatedDate = LAST_N_DAYS:13 AND OwnerId = :userId AND (Outreach_Type__c = NULL OR (Outreach_Type__c != NULL AND Outreach_Type__c NOT IN ('Gift','Event','Wishlist'))))
                                FROM Account
                                WHERE Last_Transaction_SA__pc = :userId AND 
                                    Id IN (SELECT Client__c 
                                            FROM Transaction__c 
                                            WHERE TransactionDate__c = LAST_N_DAYS:13 AND Store__c = :storeId)]);
        for(Account client : clientsMap.values()) {
            Integer doneCombo = 0;
            Date lastInteractionDate;
            Note__c note;
            Task task;
            Task outreach;
            Boolean isTourist = false;

            Date lastTransactionDate;
            for(Transaction__c currentTransaction : client.Transactions__r) {
                if(lastTransactionDate == null || (lastTransactionDate != null && currentTransaction.TransactionDate__c >= lastTransactionDate)) {
                    lastTransactionDate = currentTransaction.TransactionDate__c;
                    isTourist = currentTransaction.LocalOrTourist__c == 'Tourist' ? true : false; 
                }
            }

            for(Note__c currentNote : client.Notes__r) {
                if(currentNote.CreatedDate >= client.LastPurchaseDate__pc && (note == null || (note != null && currentNote.CreatedDate < note.CreatedDate))) {
                    note = currentNote;
                    doneCombo ++;
                    if(lastInteractionDate == null || (lastInteractionDate != null && currentNote.CreatedDate > lastInteractionDate)) {
                        lastInteractionDate = currentNote.CreatedDate.date();
                    }
                }
            }

            for(Task currentTask : client.Tasks) {
                if(!isTourist && currentTask.ActivityDate >= client.LastPurchaseDate__pc && currentTask.CreatedDate >= client.LastPurchaseDate__pc 
                    && String.isEmpty(currentTask.Outreach_Type__c) && (task == null || (task != null && currentTask.CreatedDate < task.CreatedDate))) {
                    task = currentTask;
                    doneCombo ++;
                    if(lastInteractionDate == null || (lastInteractionDate != null && currentTask.CreatedDate > lastInteractionDate)) {
                        lastInteractionDate = currentTask.CreatedDate.date();
                    }
                }
                else if(currentTask.ActivityDate >= client.LastPurchaseDate__pc && currentTask.CreatedDate >= client.LastPurchaseDate__pc 
                    && !String.isEmpty(currentTask.Outreach_Type__c) && (outreach == null || (outreach != null && currentTask.CreatedDate < outreach.CreatedDate))) {
                    outreach = currentTask;
                    doneCombo ++;
                    if(lastInteractionDate == null || (lastInteractionDate != null && currentTask.CreatedDate > lastInteractionDate)) {
                        lastInteractionDate = currentTask.CreatedDate.date();
                    }
                }
            }

            result.add(new Map<String, Object> {
                'clientId' => client.Id,
                'firstName' => client.FirstName,
                'lastName' => client.LastName,
                'lastPurchaseDate' => client.LastPurchaseDate__pc,
                'segment' => client.LightCurrentCluster__pc,
                'noteId' => (note != null ? note.Id : null),
                'taskId' => (task != null ? task.Id : null),
                'outreachId' => (outreach != null ? outreach.Id : null),
                'comboCompleted' => (((isTourist && doneCombo == 2) || doneCombo == 3) && lastInteractionDate.daysBetween(Date.today()) > 2 ? true : false),
                'lastInteractionDate' => lastInteractionDate,
                'isTourist' => isTourist
            });
        }  
        
        return result;
    }
    
    public List<Map<String, Object>> getTransactionComboV2(String userId) {
        List<String> comboClientsIds = new List<String>();
        List<String> comboTransactionsIds = new List<String>();
        for(Transaction__c t : [SELECT Id,Client__c, 
                                    (SELECT Id 
                                    FROM Transaction_Items__r 
                                    WHERE (NOT Product__r.StockKeepingUnit LIKE '2%') AND Product__r.macrofunction__c != 'REPARATION' 
                                        AND Type__c = 'Sale' AND ExclTaxAmount__c > 0)
                                FROM Transaction__c 
                                WHERE Client__r.Last_Transaction_SA__pc = :userId AND TransactionDate__c = LAST_N_DAYS:13 AND Client__c NOT IN 
                                        (SELECT Client__c FROM ClientSource__c WHERE (SourceCode__c LIKE '____'  OR SourceCode__c LIKE '%000000'))]) {
            if(t.Transaction_Items__r.size() > 0) {
                comboTransactionsIds.add(t.Id);
                comboClientsIds.add(t.Client__c);
            }
        }

        List<Map<String, Object>> result = new List<Map<String, Object>>();

        if(comboClientsIds.size() > 0) {
            Map<String,Account> clientsMap = new Map<String, Account>(
                                    [SELECT Id,FirstName,LastName,LastPurchaseDate__pc,FirstPurchaseDate__pc,LightCurrentCluster__pc,
                                        (SELECT TransactionDate__c, LocalOrTourist__c 
                                        FROM Transactions__r 
                                        WHERE Id IN :comboTransactionsIds AND TransactionDate__c = LAST_N_DAYS:13
                                        ORDER BY TransactionDate__c DESC LIMIT 1),
                                        (SELECT ReviewedInformation__c FROM Client_Insights__r WHERE LastReviewDate__c = LAST_N_DAYS:13),
                                        (SELECT Id,Outreach_Type__c,ActivityDate,CreatedDate
                                        FROM Tasks 
                                        WHERE CreatedDate = LAST_N_DAYS:13 AND OwnerId = :userId AND (Outreach_Type__c = NULL OR (Outreach_Type__c != NULL AND Outreach_Type__c NOT IN ('Gift','Event','Wishlist'))))
                                    FROM Account
                                    WHERE Last_Transaction_SA__pc = :userId AND 
                                        Id IN :comboClientsIds]);

            Map<String, List<String>> clientNotesMap = new Map<String, List<String>>();
            Map<String, Date> clientNotesLastDateMap = new Map<String, Date>();
            for(Client_Insight_History__c cih : [SELECT ModifiedField__c,ClientInsight__r.Client__c, ModifiedAt__c
                                                FROM Client_Insight_History__c
                                                WHERE ClientInsight__r.Client__c IN :clientsMap.keySet() AND ModifiedBy__c = :userId AND ModifiedAt__c = LAST_N_DAYS:13]) {
                if(!clientNotesMap.containsKey(cih.ClientInsight__r.Client__c)) {
                    clientNotesMap.put(cih.ClientInsight__r.Client__c, new List<String>());
                }
                if(cih.ModifiedAt__c >= clientsMap.get(cih.ClientInsight__r.Client__c).LastPurchaseDate__pc && !clientNotesMap.get(cih.ClientInsight__r.Client__c).contains(cih.ModifiedField__c)) {
                    clientNotesMap.get(cih.ClientInsight__r.Client__c).add(cih.ModifiedField__c);
                    if(!clientNotesLastDateMap.containsKey(cih.ClientInsight__r.Client__c) || (clientNotesLastDateMap.containsKey(cih.ClientInsight__r.Client__c) && clientNotesLastDateMap.get(cih.ClientInsight__r.Client__c) < cih.ModifiedAt__c)) {
                        clientNotesLastDateMap.put(cih.ClientInsight__r.Client__c, cih.ModifiedAt__c.date());
                    }
                }
            }
            for(Note_History__c noteH : [SELECT Note__r.Client__c, ModifiedAt__c
                                        FROM Note_History__c
                                        WHERE Note__r.Client__c IN :clientsMap.keySet() AND ModifiedBy__c = :userId AND ModifiedAt__c = LAST_N_DAYS:13]) {
                if(!clientNotesMap.containsKey(noteH.Note__r.Client__c)) {
                    clientNotesMap.put(noteH.Note__r.Client__c, new List<String>());
                }
                if(noteH.ModifiedAt__c >= clientsMap.get(noteH.Note__r.Client__c).LastPurchaseDate__pc) {
                    if(!clientNotesMap.get(noteH.Note__r.Client__c).contains('note-comment')) {
                        clientNotesMap.get(noteH.Note__r.Client__c).add('note-comment');
                    }
                    if(!clientNotesLastDateMap.containsKey(noteH.Note__r.Client__c) || (clientNotesLastDateMap.containsKey(noteH.Note__r.Client__c) && clientNotesLastDateMap.get(noteH.Note__r.Client__c) < noteH.ModifiedAt__c)) {
                        clientNotesLastDateMap.put(noteH.Note__r.Client__c, noteH.ModifiedAt__c.date());
                    }
                }
            }
            for(Account client : clientsMap.values()) {
                Boolean isFirstPurchase = client.FirstPurchaseDate__pc == client.LastPurchaseDate__pc ? true : false;
                Integer doneCombo = 0;
                Date lastInteractionDate;
                Boolean isReviewedInsights = false;
                Boolean note = false;
                Task task;
                Task outreach;
                Boolean isTourist = false;

                Date lastTransactionDate;
                for(Transaction__c currentTransaction : client.Transactions__r) {
                    if(lastTransactionDate == null || (lastTransactionDate != null && currentTransaction.TransactionDate__c >= lastTransactionDate)) {
                        lastTransactionDate = currentTransaction.TransactionDate__c;
                        isTourist = currentTransaction.LocalOrTourist__c == 'Tourist' ? true : false; 
                    }
                }

                for(Client_Insight__c ci : client.Client_Insights__r) {
                    Map<String, Object> reviewedInformationMap = !String.isEmpty(ci.ReviewedInformation__c) ? (Map<String, Object>)JSON.deserializeUntyped(ci.ReviewedInformation__c) : new Map<String, Object>();
                    if(reviewedInformationMap.containsKey(userId)) {
                        List<String> userReviewedDateList = ((String)reviewedInformationMap.get(userId)).split('-');
                        Date userReviewedDate = userReviewedDateList.size() == 3 ? Date.newInstance(Integer.valueOf(userReviewedDateList[2]), Integer.valueOf(userReviewedDateList[1]), Integer.valueOf(userReviewedDateList[0])) : Date.newInstance(2000, 1, 1);
                        if(userReviewedDate >= client.LastPurchaseDate__pc) {
                            isReviewedInsights = true;
                            note = true;
                            doneCombo ++;
                            if(lastInteractionDate == null || (lastInteractionDate != null && userReviewedDate > lastInteractionDate)) {
                                lastInteractionDate = userReviewedDate;
                            }
                        }
                    }
                }

                if(!isReviewedInsights && clientNotesMap.containsKey(client.Id) && ((isFirstPurchase && clientNotesMap.get(client.Id).size() >= 5) || (!isFirstPurchase && clientNotesMap.get(client.Id).size() >= 1) )) {
                    note = true;
                    doneCombo ++;
                    if(lastInteractionDate == null || (lastInteractionDate != null && clientNotesLastDateMap.get(client.Id) > lastInteractionDate)) {
                        lastInteractionDate = clientNotesLastDateMap.get(client.Id);
                    }
                }

                for(Task currentTask : client.Tasks) {
                    if(!isTourist && currentTask.ActivityDate >= client.LastPurchaseDate__pc && currentTask.CreatedDate >= client.LastPurchaseDate__pc 
                        && String.isEmpty(currentTask.Outreach_Type__c) && (task == null || (task != null && currentTask.CreatedDate < task.CreatedDate))) {
                        if(task == null) {
                            doneCombo ++;
                        }
                        task = currentTask;
                        if(lastInteractionDate == null || (lastInteractionDate != null && currentTask.CreatedDate > lastInteractionDate)) {
                            lastInteractionDate = currentTask.CreatedDate.date();
                        }
                    }
                    else if(currentTask.ActivityDate >= client.LastPurchaseDate__pc && currentTask.CreatedDate >= client.LastPurchaseDate__pc 
                        && !String.isEmpty(currentTask.Outreach_Type__c) && (outreach == null || (outreach != null && currentTask.CreatedDate < outreach.CreatedDate))) {
                        if(outreach == null) {
                            doneCombo ++;
                        }
                        outreach = currentTask;

                        if(lastInteractionDate == null || (lastInteractionDate != null && currentTask.CreatedDate > lastInteractionDate)) {
                            lastInteractionDate = currentTask.CreatedDate.date();
                        }
                    }
                }

                result.add(new Map<String, Object> {
                    'clientId' => client.Id,
                    'firstName' => client.FirstName,
                    'lastName' => client.LastName,
                    'lastPurchaseDate' => client.LastPurchaseDate__pc,
                    'segment' => client.LightCurrentCluster__pc,
                    'noteId' => (note ? true : null),
                    'taskId' => (task != null ? task.Id : null),
                    'outreachId' => (outreach != null ? outreach.Id : null),
                    'comboCompleted' => (((isTourist && doneCombo == 2) || doneCombo == 3) && lastInteractionDate.daysBetween(Date.today()) > 2 ? true : false),
                    'lastInteractionDate' => lastInteractionDate,
                    'isTourist' => isTourist
                });
            }
        }

        return result;
    }

    public List<Map<String,Object>> getFeedbacks(String userId) {
        List<Map<String,Object>> feedbacksWrapper = new List<Map<String,Object>>();
        for(due__Diduenjoy_Answer__c feedback : [SELECT Id,due__Score__c,due__Diduenjoy_Feedback__r.due__CreatedAt__c,
                                                    due__Diduenjoy_Feedback__r.due__Comment__c,due__Diduenjoy_Feedback__r.due__Account__c,
                                                    due__Diduenjoy_Feedback__r.due__Account__r.FirstName, due__Diduenjoy_Feedback__r.due__Account__r.LastName 
                                                FROM due__Diduenjoy_Answer__c 
                                                WHERE due__Score__c >= 9 AND due__Diduenjoy_Feedback__r.due__CreatedAt__c = LAST_N_DAYS:13
                                                    AND due__Diduenjoy_Feedback__r.Name LIKE 'Post Purchase In Store -%' 
                                                    AND due__Diduenjoy_Feedback__r.due__Account__r.Last_Transaction_SA__pc = :userId
                                                ORDER BY due__Diduenjoy_Feedback__r.due__CreatedAt__c DESC LIMIT 5]){
            feedbacksWrapper.add(new Map<String,Object> {
                'id' => feedback.Id,
                'score' => feedback.due__Score__c,
                'verbatim' => feedback.due__Diduenjoy_Feedback__r.due__Comment__c,
                'clientId' => feedback.due__Diduenjoy_Feedback__r.due__Account__c,
                'clientFirstName' => feedback.due__Diduenjoy_Feedback__r.due__Account__r.FirstName,
                'clientLastName' => feedback.due__Diduenjoy_Feedback__r.due__Account__r.LastName,
                'date' => feedback.due__Diduenjoy_Feedback__r.due__CreatedAt__c
            });
        }

        return feedbacksWrapper;
    }

    public class HomepageWrapper {
        public Map<String,Object> portfolioInfo {get;set;}
        public Map<String,Object> newsInfo {get;set;}
        public List<Map<String, Object>> comboChallenge {get;set;}
        public List<Map<String,Object>> feedbacks {get; set;}

        public HomepageWrapper(Map<String,Object> portfolioInfo, Map<String,Object> newsInfo, List<Map<String, Object>> comboChallenge, List<Map<String,Object>> feedbacks) {
            this.portfolioInfo = portfolioInfo;
            this.newsInfo = newsInfo;
            this.comboChallenge = comboChallenge;
            this.feedbacks = feedbacks;
        }
    }
}