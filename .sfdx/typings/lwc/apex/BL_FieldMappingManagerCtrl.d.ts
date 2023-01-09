declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.getFields" {
  export default function getFields(param: {objectName: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.getObjectNames" {
  export default function getObjectNames(): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.getUseCases" {
  export default function getUseCases(): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.updateUseCases" {
  export default function updateUseCases(param: {useCases: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.getProfiles" {
  export default function getProfiles(): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.getPermissions" {
  export default function getPermissions(param: {profileId: any, useCaseName: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.updateFieldMapping" {
  export default function updateFieldMapping(param: {mappings: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.deleteCustomMetadataRecords" {
  export default function deleteCustomMetadataRecords(param: {cmdType: any, devNames: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.checkDeploymentStatus" {
  export default function checkDeploymentStatus(param: {jobId: any}): Promise<any>;
}
declare module "@salesforce/apex/BL_FieldMappingManagerCtrl.performTestQuery" {
  export default function performTestQuery(param: {useCaseName: any}): Promise<any>;
}
