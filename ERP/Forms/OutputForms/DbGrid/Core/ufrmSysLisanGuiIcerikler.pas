unit ufrmSysLisanGuiIcerikler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB,
  System.Actions, Vcl.ActnList,
  ZPgEventAlerter, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ufrmBase, ufrmBaseDBGrid;

type
  TfrmSysLisanGuiIcerikler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysLisanGuiIcerik,
  Ths.Database.Table.SysLisanGuiIcerikler;

{$R *.dfm}

function TfrmSysLisanGuiIcerikler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysLisanGuiIcerik.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysLisanGuiIcerik.Create(Self, Self, TSysLisanGuiIcerik.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLisanGuiIcerik.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysLisanGuiIcerikler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
