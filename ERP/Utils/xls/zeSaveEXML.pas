//****************************************************************
// zeSaveEXML.pas - Excel XML SpreadSheet format saver (fluent API wrapper)
// Modernized for Delphi 10.4+: UTF-8 only
//****************************************************************
unit zeSaveEXML;

interface

implementation

uses
  System.SysUtils, System.Types, System.StrUtils, zeSave, zexmlss, zexmlssutils;

type
  TZxXMLSSSaver = class(TZXMLSSave)
  protected
    function DoSave: integer; override;
    class function FormatDescriptions: TStringDynArray; override;
  end;

class function TZxXMLSSSaver.FormatDescriptions: TStringDynArray;
begin
  Result := SplitString('.XML*SpreadsheetML*Excel XML*XMLSS*XML SS*' + 'Microsoft Office 2003 XML*Office 2003 XML*' + 'application/vnd.ms-excel*application/xml', '*');
end;

function TZxXMLSSSaver.DoSave: integer;
begin
  Result := SaveXmlssToEXML(fBook, FFile, GetPageNumbers, GetPageTitles);
end;

initialization
  TZxXMLSSSaver.Register;


finalization
  TZxXMLSSSaver.UnRegister;

end.

