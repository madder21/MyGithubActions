global with sharing class SOM_FlowUtils_UuidGenerator {

    public static final String UUID_CHAR_CONCAT = '-';

    @InvocableMethod(label='Generate Uuid')
    global static List<UuidGeneratorResponse> generateUuid(List<String> inputs){
        List<UuidGeneratorResponse> responses = new List<UuidGeneratorResponse>();
        for (String input:inputs) {
            UuidGeneratorResponse res = new UuidGeneratorResponse();
            String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
            res.value = h.SubString(0,8)+ UUID_CHAR_CONCAT + h.SubString(8,12) + 
                   UUID_CHAR_CONCAT + h.SubString(12,16) + UUID_CHAR_CONCAT + 
                   h.SubString(16,20) + UUID_CHAR_CONCAT + h.substring(20);
    
            responses.add(res);
        }

        return responses;
    }

    global with sharing class UuidGeneratorResponse{
        @InvocableVariable
        public String value;
    }
}