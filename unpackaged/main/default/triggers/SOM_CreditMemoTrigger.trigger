trigger SOM_CreditMemoTrigger on CreditMemo (before update) {
    new SOM_CreditMemoTriggerHandler().run();
}
