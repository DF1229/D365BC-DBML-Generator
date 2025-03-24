namespace DFR.DBML;
using DBML.DBML;
using System.Threading;

codeunit 50100 "Generate DBML DFR"
{
    TableNo = "Job Queue Entry";

    var
        DBMLFileBuilder: Codeunit "DBML File Builder";

    trigger OnRun()
    var
        TableNo: Integer;
    begin
        Rec.TestField("Parameter String");
        Evaluate(TableNo, Rec."Parameter String");

        DBMLFileBuilder.Generate(TableNo);
        DBMLFileBuilder.Export();
    end;
}