pageextension 50100 CustomerListExt extends "Customer List"
{
    actions
    {
        addafter("Sent Emails")
        {
            action(ImportCSVFile)
            {
                ApplicationArea = All;
                Caption = 'Import from Azure Blob Storage';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Image = Import;

                trigger OnAction()
                var
                    FileBufferMgmt: Codeunit "File Buffer Management";
                begin
                    FileBufferMgmt.ImportItemsFromCSVUsingCSVBuffer();
                end;
            }

            action(ExportXMLFile)
            {
                ApplicationArea = All;
                Caption = 'Export to Azure Blob Storage';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Image = Export;

                trigger OnAction()
                var
                    FileBufferMgmt: Codeunit "File Buffer Management";
                begin
                    FileBufferMgmt.ExportSalesOrderToXMLUsingXMLBuffer();
                end;
            }

            action(GetContainerList)
            {
                ApplicationArea = All;
                Caption = 'Get Container List';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                PromotedIsBig = true;
                Image = List;

                trigger OnAction()
                var
                    AzureBlobStorageMgmt: Codeunit "Azure Blob Storage Management";
                begin
                    AzureBlobStorageMgmt.GetContainerList();
                end;
            }
        }
    }
}