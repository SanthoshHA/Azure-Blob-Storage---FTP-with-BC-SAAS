codeunit 50108 "File Buffer Management"
{
    procedure ImportItemsFromCSVUsingCSVBuffer()
    var
        TempCSVBuffer: Record "CSV Buffer" temporary;
        Item: Record Item;
        InFileStream: InStream;
    begin
        //Read a csv file from Azure Blob Storage
        AzureBlobStorageManagement.ReadFileFromAzureBlobStorage(InFileStream);

        TempCSVBuffer.DeleteAll();
        TempCSVBuffer.LoadDataFromStream(InFileStream, ',');
        if TempCSVBuffer.FindSet() then
            repeat
                if TempCSVBuffer."Field No." = 1 then
                    Item.Init();

                case TempCSVBuffer."Field No." of
                    1:
                        Item.Validate("No.", TempCSVBuffer.Value);
                    2:
                        Item.Validate(Description, TempCSVBuffer.Value);
                    3:
                        if not Item.Insert() then
                            Item.Modify();
                end;
            until TempCSVBuffer.Next() = 0;

        Message('Items are imported from Blob storage');
    end;

    procedure ExportSalesOrderToXMLUsingXMLBuffer()
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        SalesHdr: Record "Sales Header";
        SalesLine: Record "Sales Line";
        XMLReader: Codeunit "XML Buffer Reader";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        SalesOrdersEntryNo: Integer;
        XMLDoc: XmlDocument;
        InStreamL: InStream;
    begin
        //Save Sales Order Entry number from Temp XML Buffer
        SalesOrdersEntryNo := TempXMLBuffer.AddGroupElement('SalesOrders');

        SalesHdr.SetRange("Document Type", SalesHdr."Document Type"::Order);
        SalesHdr.SetLoadFields("No.", "Sell-to Customer No.");// Load only required fields
        if SalesHdr.FindSet() then
            repeat
                TempXMLBuffer.Get(SalesOrdersEntryNo); // Get SalesOrdersEntryNo Or Use TempXMLBuffer.GetParent
                TempXMLBuffer.AddGroupElement('Header');
                TempXMLBuffer.AddAttribute('OrderNumber', SalesHdr."No.");
                TempXMLBuffer.AddElement('SelltoCustomerNo', SalesHdr."Sell-to Customer No.");

                SalesLine.SetRange("Document Type", SalesHdr."Document Type");
                SalesLine.SetRange("Document No.", SalesHdr."No.");
                SalesLine.SetLoadFields(Type, "No.", Description, "Unit Price");// Load only required fields
                if SalesLine.FindSet() then
                    repeat
                        TempXMLBuffer.AddGroupElement('Line');
                        TempXMLBuffer.AddElement('Type', Format(SalesLine.Type));
                        TempXMLBuffer.AddElement('No', SalesLine."No.");
                        TempXMLBuffer.AddElement('Description', SalesLine.Description);
                        TempXMLBuffer.AddElement('UnitPrice', Format(SalesLine."Unit Price"));
                        TempXMLBuffer.GetParent();
                    until SalesLine.Next() = 0;
            until SalesHdr.Next() = 0;

        TempXMLBuffer.Get(SalesOrdersEntryNo); // Get SalesOrdersEntryNo or we have to use multiple TempXMLBuffer.GetParent

        XMLReader.SaveToTempBlob(TempBlob, TempXMLBuffer);
        TempBlob.CreateInStream(InStreamL);
        XmlDocument.ReadFrom(InStreamL, XMLDoc);

        FileName := StrSubstNo('SalesOrders_%1.xml', Format(Today, 0, '<Day,2><Month,2><Year4>'));

        //Exporting a xml file to Azure Blob Storage
        AzureBlobStorageManagement.ExportFileToAzureBlobStorage(FileName, InStreamL);
    end;

    var
        AzureBlobStorageManagement: Codeunit "Azure Blob Storage Management";
}