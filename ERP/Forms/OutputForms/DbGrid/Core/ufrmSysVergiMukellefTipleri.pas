unit ufrmSysVergiMukellefTipleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB,
  ufrmBase, ufrmBaseDBGrid, System.Actions, Vcl.ActnList,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSysVergiMukellefTipleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysMukellefTipi,
  Ths.Database.Table.SysVergiMukellefTipleri;

{$R *.dfm}

function TfrmSysVergiMukellefTipleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysMukellefTipi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysMukellefTipi.Create(Application, Self, TSysVergiMukellefTipi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysMukellefTipi.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysVergiMukellefTipleri.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
