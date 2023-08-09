public class SOM_CreditMemoTriggerHandler extends BaseTriggerHandler {
	private List<CreditMemo> newList;
    private List<CreditMemo> oldList;

    public SOM_CreditMemoTriggerHandler() {
        oldList = (List<CreditMemo>)Trigger.old;
        newList = (List<CreditMemo>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
             SOM_CreditMemoHelper.updateCreditMemoDate(newList);
    }
}
