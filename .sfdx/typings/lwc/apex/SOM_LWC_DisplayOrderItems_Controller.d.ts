declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getListLineItems" {
  export default function getListLineItems(param: {orderSumId: any, returnOrdId: any, isFromRo: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getTotalLinesRO" {
  export default function getTotalLinesRO(param: {returnOrdId: any, isFromRo: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getCurrency" {
  export default function getCurrency(param: {orderSumId: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getLocations" {
  export default function getLocations(param: {countryCode: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getProductDetails" {
  export default function getProductDetails(param: {productLine: any, currencyCode: any, priceBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getProductAts" {
  export default function getProductAts(param: {locationBySku: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getSKUsDelivery" {
  export default function getSKUsDelivery(): Promise<any>;
}
