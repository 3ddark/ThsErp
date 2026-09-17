//****************************************************************
// zeSaveODS.pas - ODS (OpenDocument Spreadsheet) format saver (fluent API wrapper)
// Modernized for Delphi 10.4+: UTF-8 only, System.Zip
//****************************************************************
unit zeSaveODS;

interface

implementation

uses
  System.SysUtils, System.Types, System.StrUtils, zeSave, zexmlss, zeodfs;

type
  TZxODSSaver = class(TZXMLSSave)
  protected
    function DoSave: integer; override;
    class function FormatDescriptions: TStringDynArray; override;
  end;

class function TZxODSSaver.FormatDescriptions: TStringDynArray;
begin
  Result := SplitString('.ods*.fods*OASIS*OpenOffice*OpenOffice.org*' + 'application/vnd.oasis.opendocument.spreadsheet*' + 'org.oasis.opendocument.spreadsheet*' + 'OpenDocument*OpenDocument SpreadSheet*ISO/IEC 26300*ISO 26300', '*');
end;

function TZxODSSaver.DoSave: integer;
begin
  Result := ExportXmlssToODFS(fBook, FFile, GetPageNumbers, GetPageTitles);
end;

initialization
  TZxODSSaver.Register;


finalization
  TZxODSSaver.UnRegister;

end.

