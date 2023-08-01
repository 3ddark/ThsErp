unit ufrmSysAylar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB,
  System.Actions, Vcl.ActnList,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter,
  ufrmBase, ufrmBaseDBGrid;

type
  TfrmSysAylar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysLisan,
  Ths.Database.Table.SysAylar;

{$R *.dfm}

function TfrmSysAylar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysLisan.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysLisan.Create(Self, Self, TSysAy.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLisan.Create(Self, Self, Table.Clone(), pFormMode);
end;

end.
