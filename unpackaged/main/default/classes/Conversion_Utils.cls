/*
 * Created by Israel Zygelboim on 13/01/2019.
 */
public class Conversion_Utils {

    static List<CurrencyType> currencyTypes;
    static CurrencyType defaultCurrency;
    static Map<String,Decimal> conversionRate;

    private static void init(){
        currencyTypes = [SELECT ConversionRate, IsoCode, IsCorporate FROM CurrencyType];
        conversionRate = new Map<String, Decimal>();

        for(CurrencyType type : currencyTypes){
            conversionRate.put(type.IsoCode,type.ConversionRate);
            if (type.IsCorporate){
                defaultCurrency = type;
            }
        }
    }

    public static Decimal convertToDefault(Decimal value, String isoCode) {
        if (currencyTypes == null){
            init();
        }
        if (value == null){
            return 0;
        }
//        Decimal conversionRate = conversionRate.get(isoCode);
        return (value*conversionRate.get(isoCode)).setScale(2);
//        return value.divide(conversionRate.get(isoCode),2);
    }

    public static Decimal convertToUserCurrency(Decimal value) {
        return convertToDefault(value, UserInfo.getDefaultCurrency());
    }


}