unit ufrmSysSehirler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSysSehirler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table,
  Ths.Constants,
  ufrmSysSehir,
  Ths.Database.Table.SysSehirler;

{$R *.dfm}

function TfrmSysSehirler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysSehir.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysSehir.Create(Application, Self, TSysSehir.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysSehir.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysSehirler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;

  setDisplayFormatInteger(TSysSehir(Table).PlakaKodu.FieldName, '00', grd.DataSource.DataSet);
end;

end.
