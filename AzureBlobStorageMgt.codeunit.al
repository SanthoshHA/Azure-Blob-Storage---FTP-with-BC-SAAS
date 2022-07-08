codeunit 50107 "Azure Blob Storage Management"
{
    procedure ExportFileToAzureBlobStorage(BlobName: Text; var SourceInStream: InStream)
    begin
        //Storage account access key
        Authorization := StorageServiceAuthorization.CreateSharedKey('1FAE6wsh2udqdwnIjwI71+Sq51ys0zrznnpZFo9GIUv8ZhFJ2GFai0D/dmgL06HfR51/67FAM1Tk+AStWvqBfw==');

        //Initialize container
        ContainerClient.Initialize('storageaccountftpbc', Authorization);

        //Create container if not exist
        Response := ContainerClient.CreateContainer('exportcontainer');

        //Init Blob Client
        BlobClient.Initialize('storageaccountftpbc', 'exportcontainer', Authorization);

        //Create a Blob
        BlobClient.PutBlobBlockBlobStream(BlobName, SourceInStream);
        //BlobClient.PutBlobAppendBlobText();

        if not Response.IsSuccessful() then
            Message('Blob creation error: %1', Response.GetError())
        else
            Message('File %1 created on Azure Blob storage', BlobName);
    end;

    procedure ReadFileFromAzureBlobStorage(InFileStream: InStream)
    begin
        Authorization := StorageServiceAuthorization.CreateSharedKey('1FAE6wsh2udqdwnIjwI71+Sq51ys0zrznnpZFo9GIUv8ZhFJ2GFai0D/dmgL06HfR51/67FAM1Tk+AStWvqBfw==');
        BlobClient.Initialize('storageaccountftpbc', 'importcontainer', Authorization);
        Response := BlobClient.ListBlobs(ContainerContent);
        if Response.IsSuccessful() then begin
            if ContainerContent.FindSet() then
                repeat
                    //if ContainerContent.Name = 'Items.csv' then
                    BlobClient.GetBlobAsStream(ContainerContent.Name, InFileStream);

                //BlobClient.GetBlobAsText()
                //BlobClient.GetBlobAsFile()
                until ContainerContent.Next() = 0;
        end;
    end;

    procedure GetContainerList()
    begin
        Authorization := StorageServiceAuthorization.CreateSharedKey('1FAE6wsh2udqdwnIjwI71+Sq51ys0zrznnpZFo9GIUv8ZhFJ2GFai0D/dmgL06HfR51/67FAM1Tk+AStWvqBfw==');
        ContainerClient.Initialize('storageaccountftpbc', Authorization);

        //List containers
        Response := ContainerClient.ListContainers(Containers);

        if Response.IsSuccessful() then begin
            if Containers.FindSet() then
                repeat
                    message('Container Name: %1', Containers.Name);
                until Containers.Next() = 0;
        end
        else
            Message('Error: %1', Response.GetError());
    end;

    var
        Containers: Record "ABS Container";
        ContainerContent: Record "ABS Container Content";
        ContainerClient: Codeunit "ABS Container Client";
        Response: Codeunit "ABS Operation Response";
        BlobClient: Codeunit "ABS Blob Client";
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        Authorization: Interface "Storage Service Authorization";
}