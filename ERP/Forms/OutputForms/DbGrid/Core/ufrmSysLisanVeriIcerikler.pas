unit ufrmSysLisanVeriIcerikler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSysLisanVeriIcerikler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  ufrmSysLisanVeriIcerik,
  Ths.Database.Table.SysLisanVeriIcerikler;

{$R *.dfm}

function TfrmSysLisanVeriIcerikler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysLisanVeriIcerik.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysLisanVeriIcerik.Create(Self, Self, TSysLisanVeriIcerik.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLisanVeriIcerik.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysLisanVeriIcerikler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
