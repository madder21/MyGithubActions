public class SOM_CreditMemoTriggerHandler extends BaseTriggerHandler {
	private List<CreditMemo> newList;
    private List<CreditMemo> oldList;

    public SOM_CreditMemoTriggerHandler() {
        oldList = (List<CreditMemo>)Trigger.old;
        newList = (List<CreditMemo>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
        List<CreditMemo> newListWithEmptyDate = new List<CreditMemo>();
        for(CreditMemo singleCr : newList){
            if(singleCr.Credit_Memo_Date__c == null){
                newListWithEmptyDate.add(singleCr);
            }
        } 
        if(newListWithEmptyDate != null && !newListWithEmptyDate.isEmpty()){
            SOM_CreditMemoHelper.updateCreditMemoDate(newListWithEmptyDate);
        }
    }
}
