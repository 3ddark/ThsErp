unit ufrmSysGunler;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter,
  ufrmBase, ufrmBaseDBGrid;

{$I Ths.inc}

type
  TfrmSysGunler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysGun,
  Ths.Database.Table.SysGunler;

{$R *.dfm}

function TfrmSysGunler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysGun.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysGun.Create(Self, Self, TSysGun.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGun.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysGunler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
