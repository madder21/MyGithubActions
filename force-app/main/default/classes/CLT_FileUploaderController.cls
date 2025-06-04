/**
 * @author (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is the Apex controller of the LWC clt_MemberedClientListCSVFileUploader
 *****************************************************************************************************************************************************************
 * @Version :
 * Version |Date of modification |Modified By|Related Jira Ticket|Description of changes
 * 1.0 |2024/10/06    |Sarah A. |RCLIENT-860    |Creation of client list members is now done by Apex Batch launch
 */
public with sharing class CLT_FileUploaderController {
    /**
     * @METHOD : insertMembersFromFile
     * @DESC : This method processes a CSV file containing client IDs and launches a batch job to create Client List Members based on the data in the file.
     * @PARAM : String clientListId - The ID of the Client List where members will be added. String fileName - The name of the uploaded file. Blob contentFile - The content of the uploaded file as a Blob.
     * @RETURN : none
     * @THROWS : CustomException - If the file format is not CSV or if it does not contain the expected column.
     */
    @AuraEnabled
    public static void insertMembersFromFile(String clientListId, String fileName, String contentFile) {
        try {
            String dynamicColumnName = 'Id'; // Can change this value to a different column

            // Verification 1: Check if the file is in CSV format
            if (!fileName.contains('.csv')) {
                throw new CustomException('File format is wrong. Only CSV format is allowed.');
            }

            // Verification 2: Check if the file contains the dynamic column (e.g., 'Id')
            String headerLine = contentFile.trim().substringBefore('\n');
            Integer index = getColumnIndex(dynamicColumnName, headerLine);
            if (index == -1) {
                throw new CustomException('File doesn\'t contain a ' + dynamicColumnName + ' column.');
            }

            // Launch the batch with the file data and the dynamic column name
            Integer batchSize = 10000;
            CLT_CreateClientListMembersBatch batch = new CLT_CreateClientListMembersBatch(clientListId, contentFile.trim().removeStart(headerLine).removeStart('\n'), batchSize, index, 1);
            Database.executeBatch(batch, batchSize); // Execute the batch

        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }

    /**
     * @METHOD : getColumnIndex
     * @DESC : This helper method retrieves the index of the specified column header from the first line of the CSV file.
     * @PARAM : String headerName - The name of the header to find. List<String> stringLines - The lines of the CSV file as a list of strings.
     * @RETURN : Integer - The index of the header if found; -1 otherwise.
     */
    private static Integer getColumnIndex(String headerName, String headerLine) {
        String normalizedHeaderName = headerName.trim().toLowerCase();
        List<string> headers = headerLine.split('[,;]');
       
        for(Integer i = 0; i < headers.size(); i++) {
            // Compare normalized headers
            if (headers[i].trim().toLowerCase().replaceAll('[^a-zA-Z0-9]', '') == normalizedHeaderName) {
                return i; // Return index if matched
            }
        }
        return  -1;
}

    public class CustomException extends Exception {}
}