trigger SOM_Update_Credit_Memo_Date on CreditMemo (before update) {
    new SOM_Update_Credit_Memo_Date_Handler().run();
}