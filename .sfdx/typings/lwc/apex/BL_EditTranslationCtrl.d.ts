declare module "@salesforce/apex/BL_EditTranslationCtrl.getTranslationContent" {
  export default function getTranslationContent(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_EditTranslationCtrl.saveTranslationContent" {
  export default function saveTranslationContent(param: {recordId: any, content: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_EditTranslationCtrl.addRowsToTranslations" {
  export default function addRowsToTranslations(param: {target: any, valuesMap: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_EditTranslationCtrl.removeRowsFromTranslations" {
  export default function removeRowsFromTranslations(param: {target: any, keys: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_EditTranslationCtrl.replaceKeysInTranslations" {
  export default function replaceKeysInTranslations(param: {target: any, keysMap: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_EditTranslationCtrl.printTranslations" {
  export default function printTranslations(param: {target: any}): Promise<any>;
}
