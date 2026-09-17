//****************************************************************
// zeSaveXLSX.pas - XLSX format saver (fluent API wrapper)
// Modernized for Delphi 10.4+: UTF-8 only, System.Zip
//****************************************************************
unit zeSaveXLSX;

interface

implementation

uses
  System.SysUtils, System.Types, System.StrUtils, zeSave, zexmlss, zexlsx;

type
  TZxXlsxSaver = class(TZXMLSSave)
  protected
    function DoSave: integer; override;
    class function FormatDescriptions: TStringDynArray; override;
  end;

class function TZxXlsxSaver.FormatDescriptions: TStringDynArray;
begin
  Result := SplitString('.XLSX*.XLSM*' + 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet*' + 'Excel 2007*Excel 2010*Office 2007*Office 2010*' + 'Office Open XML*OOXML*OpenXML*ECMA-376*ISO/IEC 29500*ISO 29500', '*');
end;

function TZxXlsxSaver.DoSave: integer;
begin
  Result := ExportXmlssToXLSX(fBook, FFile, GetPageNumbers, GetPageTitles);
end;

initialization
  TZxXlsxSaver.Register;


finalization
  TZxXlsxSaver.UnRegister;

end.

