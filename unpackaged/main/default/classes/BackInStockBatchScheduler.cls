/*
----------------------------------------------------------------------
-- - Name              :  BackInStockBatchScheduler
-- - Author            :  Eric Burté
-- - Description       :  Scheduler class for Batch_BackInStock
-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks
-- -----------          -----------                 --------         ----------------------
-- 17-07-2023           Eric Burté				    1.0              Initial version
---------------------------------------------------------------------------------------
*/

global class BackInStockBatchScheduler implements Schedulable {
    //Command Line : 'System.schedule('BackInStockBatchScheduler', '0 20 01/02 * * ? *', new BackInStockBatchScheduler());';
    
    global void execute(SchedulableContext sc)
    {
        // Call of BackInStock Batch
        
            Batch_BackInStock batchBIS = new Batch_BackInStock ();
        if(!Test.isRunningTest()){  
            //Parameters of ExecuteBatch(context,BatchSize)
            Database.executebatch(batchBIS,200);
        }
    }
   
}