// /**
//  * @author Sarah AYOUN (Balink)
//  * @Type Apex Class
//  *****************************************************************************************************************************************************************
//  * @description This class is an Apex Batch that processes a CSV file to create Client List Members
//  * based on the provided Account IDs in the file.
//  *****************************************************************************************************************************************************************
//  * @Version :
//  * Version |Date of modification |Modified By|Related Jira Ticket|Description of changes
//  * 1.0 |2024/10/06    |Sarah A. |RCLIENT-860 |.Initial creation of batch to process Client List Members from a CSV file.
//  */
public class CLT_CreateClientListMembersBatch implements Database.Batchable<Integer>, Database.Stateful {
    public Integer maxIteration = 5;
    public String clientListId;
    public String contentFile;
    public Integer batchSize;
    public Integer columnIndex;
    public Integer iterationCounter;

    // Constructor to initialize the batch
    public CLT_CreateClientListMembersBatch(String clientListId, String contentFile, Integer batchSize, Integer columnIndex, Integer iterationCounter) {
        this.clientListId = clientListId;
        this.contentFile = contentFile;
        this.batchSize = batchSize;
        this.columnIndex = columnIndex;
        this.iterationCounter = iterationCounter;
    }

    public Iterable<Integer> start(Database.BatchableContext bc) {
        return new List<Integer> {1};
    }

    public void execute(Database.BatchableContext bc, List<Integer> scope) {
        Set<String> clientIds = new Set<String>();

        Integer i=0;
        while(i < batchSize && !String.isEmpty(this.contentFile)) {
            i++;
            String currentLine = this.contentFile.substringBefore('\n');
            this.contentFile = this.contentFile.substringAfter('\n');  // Update contentFile to remove processed line
            
            String currentClientId = getClientIdFromLine(this.columnIndex, currentLine);
            if(!String.isEmpty(currentClientId)) {
                clientIds.add(currentClientId);
            }
        }

        // Retrieve existing ClientListMember__c records to avoid duplication
        List<ClientListMember__c> clientListMembers = new List<ClientListMember__c>();
        for(ClientListMember__c clm : [SELECT Client__c FROM ClientListMember__c WHERE ClientList__c = :clientListId AND Client__c IN :clientIds]) {
            clientIds.remove(clm.Client__c);
        }

        // If there are new clients, insert them
        if (!clientIds.isEmpty()) {
            for (Account client : [SELECT Id, Name FROM Account WHERE Id IN :clientIds]) {
                clientListMembers.add(new ClientListMember__c(
                    Client__c = client.Id,
                    Name = client.Name,
                    ClientList__c = clientListId,
                    Status__c = 'To Reach Out'
                ));
            }

            // Insert the records
            if (!clientListMembers.isEmpty()) {
                Database.UpsertResult[] results = Database.upsert(clientListMembers, false);
                for (Database.UpsertResult result : results) {
                    if (!result.isSuccess()) {
                        throw new CustomException('Error during batch insert.');
                    }
                }
            }
        }
    }

    private static String getClientIdFromLine(Integer columnIndex, String line) {
        List<String> lineItems = line.split('[,;]');
        return lineItems.size() > columnIndex ? lineItems[columnIndex].trim() : '';
    }

    public void finish(Database.BatchableContext bc) {
        // If there's remaining content, schedule another batch
        if (!String.isEmpty(this.contentFile)) {
            if (this.iterationCounter < this.maxIteration) {
                this.iterationCounter++;
                // Proceed with the next batch iteration
                Database.executeBatch(new CLT_CreateClientListMembersBatch(this.clientListId, this.contentFile, this.batchSize, this.columnIndex, this.iterationCounter), this.batchSize);
            }
        }
    }

    // Custom exception for error handling
    public class CustomException extends Exception {}
}