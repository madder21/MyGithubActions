public with sharing class SOM_SerialNumbersValidation {

    public class wr_SerialNumberQuantity {
        @InvocableVariable @AuraEnabled
        public Integer qty;
    
        @InvocableVariable @AuraEnabled
        public String serialNumbers;    
    }

    @InvocableMethod
    public static List<String> ValidateSerialNumbers(List<wr_SerialNumberQuantity> input) {
        List<String> errorMessage = new List<String>();
        List<String> serialNumbers;

        if(input[0].serialNumbers != null){
            System.debug('in if input ' + input[0].serialNumbers);
            serialNumbers = new List<String>();
            serialNumbers = input[0].serialNumbers.split(';');
            System.debug('in if serialNumbers split ' + serialNumbers);
            System.debug('in if qty ' + input[0].qty);

            if(serialNumbers.size() != input[0].qty){
                errorMessage.add('You must enter numbers of serial numbers equals to quantity and separated by ";".');
                System.debug('error mesg ' + errorMessage[0]);
                return errorMessage;
            }
            Set<String> setSerialNumbers = new Set<String>();
            setSerialNumbers.addAll(serialNumbers);
            if(setSerialNumbers.size() < serialNumbers.size()){
                errorMessage.add('You must not enter duplicated serial numbers.');
                return errorMessage;
            }
            Pattern pt = Pattern.compile('^[0-9]{17}$');
            for(String serial : serialNumbers){
                Boolean match = true;
                Matcher m = pt.matcher(serial);
                match = m.matches();
                if(!match){
                    errorMessage.add('Accepted Format is 17 digits (ex: xxxxxxxxxxxxxxxxx;xxxxxxxxxxxxxxxxx).');
                    return errorMessage;
                }
            }
        }

        return errorMessage;
    }


}