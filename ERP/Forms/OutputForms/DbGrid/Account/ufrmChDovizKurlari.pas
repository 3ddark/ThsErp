unit ufrmChDovizKurlari;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmChDovizKurlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table,
  Ths.Constants,
  ufrmChDovizKuru,
  Ths.Database.Table.ChDovizKurlari;

{$R *.dfm}

function TfrmChDovizKurlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmChDovizKuru.Create(Application, Self, Table.Clone, pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmChDovizKuru.Create(Application, Self, TChDovizKuru.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmChDovizKuru.Create(Application, Self, Table.Clone, pFormMode);
end;

procedure TfrmChDovizKurlari.FormShow(Sender: TObject);
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
    setDisplayFormatFloat(TChDovizKuru(Table).Kur.FieldName, '#' + Lfs.DecimalSeparator + StringOfChar('#', LHane) + '0' + Lfs.ThousandSeparator + StringOfChar('0', LHane), Table.DataSource.DataSet);
  end;
end;

end.
