public with sharing class CLT_FileUploaderController {
    @AuraEnabled
	public static void insertMembersFromFile(String clientListId, string fileName, Blob contentFile ){
		try {
			map <string,list<List<string>>> allValuesFromFile = parseCSV(clientListId, fileName, contentFile);
		}
		catch(Exception ex){
			throw new CustomException(ex.getMessage());
		}
	}

    public static map <string,List<list<string>>> parseCSV(String clientListId, string fileName, Blob contentFile){
		if(!fileName.contains('.csv')){
			throw new CustomException('File format is wrong \n only csv format are allowed.');
		}
        
        List<ClientListMember__c> clientListMembers = new List<ClientListMember__c>();
		list<String> stringLines = new List<string>();
		Set<String> clientIds = new Set<String>();
		map <string,list<list<string>>> valuesFromFile = new map <string,list<list<string>>>();
		stringLines = contentFile.toString().trim().split('\n');
		System.debug(stringLines.size());
		string headerName = 'Id';
        system.debug(headerName);
		Integer index = getColumnIndex(headerName, stringLines);

		if (index == -1){
			throw new CustomException('file dosen\'t contain an ' + headerName + ' column');
		}
        
		for(Integer i = 1; i< stringLines.size() ; i++){
			List<string> rowData = stringLines[i].split('[,;]');
            clientIds.add(rowData.get(index).trim());
		}
        system.debug(clientIds);

        //delete client list members of clients that are not part of the new uploaded list
        List<ClientListMember__c> clmToDelete = [SELECT Id 
                                                FROM ClientListMember__c 
                                                WHERE ClientList__c = :clientListId AND Client__c NOT IN :clientIds];
        if(clmToDelete.size() > 0) {
            delete clmToDelete;
        }

        //keep client list members with their status for already existing clients
        for(ClientListMember__c clm : [SELECT Client__c 
                                    FROM ClientListMember__c 
                                    WHERE ClientList__c = :clientListId AND Client__c IN :clientIds]) {
            clientIds.remove(clm.Client__c);
        }

        if(clientIds.size() > 0) {
            //retrieve clients for whom a new member needs to be inserted
            List<Account> clients = [SELECT Id, Name FROM Account WHERE Id = :clientIds];
            system.debug(clients);
         
            if (clients.isEmpty()){
                throw new CustomException('No client with the uploaded Ids was found in Salesforce');
            }
         
            //Create records
            for (Account client : clients){
                ClientListMember__c newClientListMember = new ClientListMember__c(
                    Client__c = client.Id,
                    Name = client.Name,
                    ClientList__c = clientListId,
                    Status__c = 'To Reach Out'
                );
                clientListMembers.add(newClientListMember);
            }
            system.debug(clientListMembers);
         
            //Insert records
            List<Database.UpsertResult> results = Database.upsert(clientListMembers, false);
            for (Database.UpsertResult result : results){
                try{
                    if (result.getId() != null){
                        System.debug(result.id);
                    }
                }
                catch(Exception ex){
                    System.debug(result.errors.get(0).getMessage());
                    throw new CustomException(result.errors.get(0).getMessage());
                }
            }
        }
		return valuesFromFile;
	}

    private static Integer getColumnIndex(String headerName, List<String> stringLines) {
		List<string> headers = stringLines.get(0).split('[,;]');
        
        for(Integer i = 0; i < headers.size(); i++) {
            headers[i] = headers[i].removeStart('ï»¿').trim();
        }
        
        return headers.indexOf(headerName); 
	}

    public class CustomException extends Exception {}
}