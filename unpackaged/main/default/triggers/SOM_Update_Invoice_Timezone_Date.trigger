trigger SOM_Update_Invoice_Timezone_Date on Invoice (before update) {
    new SOM_Update_Invoice_Timezone_Date_Handler().run();
}