unit ufrmSetPrsLisanSeviyeleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSetPrsLisanSeviyeleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmSetPrsLisanSeviyesi, Ths.Database.Table.SetPrsLisanSeviyeleri;

{$R *.dfm}

function TfrmSetPrsLisanSeviyeleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetPrsLisanSeviyesi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetPrsLisanSeviyesi.Create(Application, Self, TSetPrsLisanSeviyesi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetPrsLisanSeviyesi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.

