@isTest
public class CSC_LogCallGenesysController_Test {
    
    @isTest
    private static void test() {
        List<Task> testTasks = new List<Task>();
        
        for (Integer i = 0; i < 5; i++) {
            Task t = new Task(  Subject = 'Test Task ' + i,
                                Status = 'In Progress'
                                //Assigned_To__c = UserInfo.getUserId() // Assign the task to the current test user  
                             );
        	testTasks.add(t);
        }
        insert testTasks;
        
        // Call the method being tested
        List<Task> tasksForCurrentUser = CSC_LogCallGenesysController.getTasks();
        
        // Create a test Case
        Case testCase = new Case(Subject = 'Test Case', Description='test case');
        insert testCase;        
        String testId =  String.valueOf(testCase.Id);
        
        // Call the method being tested
        String urlCase ='test.salesforce.com/lightning/r/Case/'+testCase.Id+'/view';
        CSC_LogCallGenesysController.updateTask(testTasks, urlCase);
    }
}