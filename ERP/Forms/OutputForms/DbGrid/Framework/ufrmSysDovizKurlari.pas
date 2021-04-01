unit ufrmSysDovizKurlari;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Actions, Vcl.ActnList;

type
  TfrmSysDovizKurlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Table,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  ufrmSysDovizKuru,
  Ths.Erp.Database.Table.SysDovizKuru;

{$R *.dfm}

function TfrmSysDovizKurlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysDovizKuru.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysDovizKuru.Create(Application, Self, TSysDovizKuru.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysDovizKuru.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysDovizKurlari.FormShow(Sender: TObject);
var
  LHane: Integer;
  Lfs: TFormatSettings;
begin
  inherited;
  mnicopy_record.Visible := True;

  LHane := GSysOndalikHane.DovizKuru.Value;
  if Table.DataSource.DataSet.RecordCount > 0 then
  begin
    Lfs := FormatSettings;
    setDisplayFormatFloat(TSysDovizKuru(Table).Kur.FieldName, '#' + Lfs.DecimalSeparator + StringOfChar('#', LHane) + '0' + Lfs.ThousandSeparator + StringOfChar('0', LHane), Table.DataSource.DataSet);
  end;
end;

end.
