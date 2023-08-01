unit ufrmSetChHesapTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSetChHesapTipleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
  ufrmSetChHesapTipi,
  Ths.Database.Table.SetChHesapTipi;

{$R *.dfm}

function TfrmSetChHesapTipleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetChHesapTipi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetChHesapTipi.Create(Application, Self, TSetChHesapTipi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetChHesapTipi.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSetChHesapTipleri.FormCreate(Sender: TObject);
begin
  inherited;
  FQrySiralamaVarsayilan := Table.Id.FieldName + ' ASC';
end;

end.
