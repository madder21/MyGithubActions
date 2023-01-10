declare module "@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getValidSkus" {
  export default function getValidSkus(): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getLocations" {
  export default function getLocations(): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getOnHand" {
  export default function getOnHand(param: {locationEntry: any, skuEntry: any}): Promise<any>;
}
declare module "@salesforce/apex/SOM_LWC_Update_OnHands_Controller.updateOnHand" {
  export default function updateOnHand(param: {locationEntry: any, skuEntry: any, newOnHands: any, invRecord: any}): Promise<any>;
}
