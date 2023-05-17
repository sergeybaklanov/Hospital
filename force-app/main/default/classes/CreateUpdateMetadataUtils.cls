public class CreateUpdateMetadataUtils implements Metadata.DeployCallback {
    
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Success: ' + result);
        } else {
            System.debug('Fail: ' + result);
        }
    }
    
    public static void createUpdateMetadata(List<Metadata.CustomMetadata> customMetadataList){
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        
        for (Metadata.CustomMetadata customMetadata : customMetadataList) {
            mdContainer.addMetadata(customMetadata);
        }
        
        CreateUpdateMetadataUtils callback = new CreateUpdateMetadataUtils();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}
