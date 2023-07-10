public class SOM_Update_Credit_Memo_Date_Handler extends BaseTriggerHandler {
	private List<CreditMemo> newList;
    private List<CreditMemo> oldList;

    public SOM_Update_Credit_Memo_Date_Handler() {
        oldList = (List<CreditMemo>)Trigger.old;
        newList = (List<CreditMemo>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
             SOM_Update_Credit_Memo_Date_Helper.updateCreditMemoDate(newList);
    }
}