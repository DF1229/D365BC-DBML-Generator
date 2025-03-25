namespace DFR.DBML;

using System.Threading;
using DFR.DBML.Generation;

codeunit 50100 "Generate DBML DFR"
{
    TableNo = "Job Queue Entry";

    var
        DBMLFileBuilder: Codeunit "DBML File Builder DFR";

    trigger OnRun()
    var
        TableNo: Integer;
        AppGuid: Text;
    begin
        Rec.TestField("Parameter String");
        Evaluate(AppGuid, Rec."Parameter String");

        DBMLFileBuilder.Generate(AppGuid);
        DBMLFileBuilder.Generate(2000000120, false);
        DBMLFileBuilder.Generate(2000000058, false);
        DBMLFileBuilder.Export();

        // Rec.TestField("Parameter String");
        // Evaluate(TableNo, Rec."Parameter String");

        // DBMLFileBuilder.Generate(TableNo);
        // DBMLFileBuilder.Export();
    end;
}
