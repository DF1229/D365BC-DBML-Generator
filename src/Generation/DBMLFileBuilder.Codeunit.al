namespace DFR.DBML.Generation;

using System.Reflection;
using System.Utilities;

codeunit 50101 "DBML File Builder DFR"
{
    var
        Filename: Text;
        Builder: TextBuilder;
        FilenameLbL: Label '%1 - %2.dbml', Locked = true;
        TableHeaderLbl: Label 'table "%1" {', Locked = true;
        ColoredTableHeaderLbl: Label 'table "%1" [headercolor: #%2] {', Locked = true;
        TableFooterTxt: Label '}', Locked = true;
        NoteLbl: Label '[note: ''%1'']', Locked = true;
        RelationLbl: Label '[ref: > %1.%2]', Locked = true;
        TabTok: Label '    ', Locked = true;

    procedure Export() Result: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
    begin
        OutStr := TempBlob.CreateOutStream();
        OutStr.WriteText(this.Builder.ToText());
        InStr := TempBlob.CreateInStream();
        Result := DownloadFromStream(InStr, '', '', '', this.Filename);
    end;

    procedure Generate(TableNo: Integer)
    var
        Metadata: Record "Table Metadata";
    begin
        Metadata.Get(TableNo);
        this.SetFilename(Metadata.ID, Metadata.Name);
        AddTable(TableNo, Metadata);
    end;

    procedure Generate(TableNo: Integer; SetFilename: Boolean)
    var
        Metadata: Record "Table Metadata";
    begin
        Metadata.Get(TableNo);
        if SetFilename then
            this.SetFilename(Metadata.ID, Metadata.Name);
        AddTable(TableNo, Metadata);
    end;

    procedure Generate(AppGuid: Text)
    var
        AppId: Guid;
    begin
        Evaluate(AppId, AppGuid);
        this.Generate(AppId);
    end;

    procedure Generate(AppId: Guid)
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetModuleInfo(AppId, AppInfo);
        this.SetFilename(AppInfo);
        this.Generate(AppInfo);
    end;

    procedure Generate(AppInfo: ModuleInfo)
    var
        Tables: Record "Table Metadata";
    begin
        Tables.SetRange("App ID", AppInfo.Id());
        Tables.FindSet();
        repeat
            this.AddTable(Tables.ID, Tables);
        until Tables.Next() = 0;
    end;

    local procedure AddTable(TableNo: Integer; Metadata: Record "Table Metadata")
    var
        Fields: Record Field;
    begin
        this.InitTable(Metadata.Name);

        Fields.SetRange(TableNo, TableNo);
        Fields.FindSet();
        repeat
            this.AddField(Fields);
        until Fields.Next() = 0;

        this.FinalizeTable();
    end;

    local procedure SetFilename(AppInfo: ModuleInfo)
    begin
        this.Filename := StrSubstNo(FilenameLbl, AppInfo.Publisher(), AppInfo.Name());
    end;

    local procedure SetFilename(TableNo: Integer; TableName: Text[20])
    begin
        this.Filename := StrSubstNo(FilenameLbl, TableNo, TableName);
    end;

    local procedure InitTable(Name: Text)
    begin
        this.Builder.AppendLine(StrSubstNo(TableHeaderLbl, Name));
    end;

    local procedure InitTable(Name: Text; Color: Text)
    begin
        Color := Color.Replace('#', '');
        this.Builder.AppendLine(StrSubstNo(ColoredTableHeaderLbl, Name, Color));
    end;

    local procedure FinalizeTable()
    begin
        this.Builder.AppendLine(TableFooterTxt);
        this.Builder.AppendLine();
    end;

    local procedure AddField(Field: Record Field)
    var
        Relations: Record "Table Relations Metadata";
        Name: Text;
        Type: Text;
        Length: Text;
        Note: Text;
        Relation: Text;
        RelField: Text;
        RelTable: Text;
    begin
        Name := Field.FieldName;
        Name := Name.Contains(' ') ? StrSubstNo('"%1"', Name) : Name.Contains('.') ? StrSubstNo('"%1"', Name) : Name;
        Name := Name.Replace('$', '');
        Type := Format(Field.Type);
        case Field.Type of
            Field.Type::Text, Field.Type::Code:
                Length := StrSubstNo('[%1]', Field.Len);
        end;
        Note := Field.Class = Field.Class::FlowField ? StrSubstNo(NoteLbl, 'FlowField') : '';
        Note := Field.Class = Field.Class::FlowFilter ? StrSubstNo(NoteLbl, 'FlowFilter') : '';
        Relations.SetRange("Table ID", Field.TableNo);
        Relations.SetRange("Field No.", Field."No.");
        if Relations.FindFirst() then begin
            RelTable := Relations."Related Table Name";
            RelTable := RelTable.Contains(' ') ? StrSubstNo('"%1"', RelTable) : RelTable.Contains('.') ? StrSubstNo('"%1"', RelTable) : RelTable.Contains('/') ? StrSubstNo('"%1"', RelTable) : RelTable;
            RelField := Relations."Related Field Name";
            RelField := RelField.Contains(' ') ? StrSubstNo('"%1"', RelField) : RelField.Contains('.') ? StrSubstNo('"%1"', RelField) : RelField.Contains('/') ? StrSubstNo('"%1"', RelField) : RelField;
            RelField := RelField.Replace('$', '');
            Relation := StrSubstNo(RelationLbl, RelTable, RelField);
        end;

        this.Builder.Append(TabTok);
        this.Builder.Append(Name);
        this.Builder.Append(' ');
        this.Builder.Append(Type);
        if Length <> '' then
            this.Builder.Append(Length);
        this.Builder.Append(' ');
        if Relation <> '' then
            this.Builder.Append(Relation);
        if (Note <> '') and (Relation = '') then
            this.Builder.Append(Note);

        this.Builder.AppendLine();
    end;
}
