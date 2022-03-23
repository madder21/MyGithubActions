public with sharing class TransactionHandler {
	public static void updateClientPurchaseDatesLastSAAndStore (List<Transaction__c> triggerNew){
		Set<String> accountIds = new Set<String>();
		Set<String> transactionIds = new Set<String>();
		for(Transaction__c item :triggerNew){
			if(item.Client__c != null)
				accountIds.add(item.Client__c);
				transactionIds.add(item.Id);
		}
		
		Map<Id,Account> clients = new Map<Id,Account> ([SELECT Id,LastPurchaseDate__pc,FirstPurchaseDate__pc,Last_Transaction_SA__pc,Last_Transaction_Store__pc  
														FROM Account WHERE Id in :accountIds]);
		Map<Id,Account> clientsToUpdate = new Map<Id,Account>();

		Map<Id, Id> transItem = new Map<Id, Id>();
		for(TransactionItem__c tItem :[SELECT Sales_Advisor__c, Transaction__c from TransactionItem__c where Transaction__c IN :transactionIds AND Sales_Advisor__c != null]){
			transItem.put(tItem.Transaction__c, tItem.Sales_Advisor__c);
		}
		
		for(Transaction__c item :triggerNew){
			
			Account acc = clients.get(item.Client__c);
			if(acc != null  ){
				//the current transaction is the last transaction set the last purchase date and the last transaction SA and store
				if(acc.LastPurchaseDate__pc == null || (acc.LastPurchaseDate__pc  < item.TransactionDate__c)) {
					acc.LastPurchaseDate__pc = item.TransactionDate__c;
					if(transItem.containsKey(item.Id))
						acc.Last_Transaction_SA__pc = transItem.get(item.Id);
					if(item.Store__c != null)
						acc.Last_Transaction_Store__pc = item.Store__c;
				}
				//the current transaction is the first transaction set the first purchase date
				if(acc.FirstPurchaseDate__pc == null || (acc.FirstPurchaseDate__pc  > item.TransactionDate__c))
					acc.FirstPurchaseDate__pc = item.TransactionDate__c;

				clientsToUpdate.put(acc.Id,acc);
			}
			}
		
		
		if(clientsToUpdate.values().size() > 0 )
			Database.update (clientsToUpdate.values(),false);
	}

	// public static void updateClientItemsPurchaseDatesLastSAAndStore (List<TransactionItem__c> triggerNew){
	// 	Set<String> accountIds = new Set<String>();
	// 	for(TransactionItem__c item :triggerNew){
	// 		if(item.Client__c != null)
	// 			accountIds.add(item.Client__c);
	// 	}
		
	// 	Map<Id,Account> clients = new Map<Id,Account> ([SELECT Id,LastPurchaseDate__pc,FirstPurchaseDate__pc,Last_Transaction_SA__pc,Last_Transaction_Store__pc  
	// 													FROM Account WHERE Id in :accountIds]);
	// 	Map<Id,Account> clientsToUpdate = new Map<Id,Account>();
		
	// 	for(TransactionItem__c item :triggerNew){
			
	// 		Account acc = clients.get(item.Client__c);
	// 		if(acc != null  ){
	// 			//the current transaction is the last transaction set the last purchase date and the last transaction SA and store
	// 			if(acc.LastPurchaseDate__pc == null || (acc.LastPurchaseDate__pc  < item.TransactionDate__c)) {
	// 				acc.LastPurchaseDate__pc = item.TransactionDate__c;
	// 				if(item.Sales_Advisor__c != null)
	// 					acc.Last_Transaction_SA__pc = item.Sales_Advisor__c;
	// 				if(item.Store__c != null)
	// 					acc.Last_Transaction_Store__pc = item.Store__c;
	// 			}
	// 			//the current transaction is the first transaction set the first purchase date
	// 			if(acc.FirstPurchaseDate__pc == null || (acc.FirstPurchaseDate__pc  > item.TransactionDate__c))
	// 				acc.FirstPurchaseDate__pc = item.TransactionDate__c;


	// 			clientsToUpdate.put(acc.Id,acc);
	// 		}
	// 	}
		
	// 	if(clientsToUpdate.values().size() > 0 )
	// 		Database.update (clientsToUpdate.values(),false);
	// }
}