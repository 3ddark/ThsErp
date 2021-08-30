unit ufrmSysErisimHaklari;

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
  TfrmSysUserAccessRights = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormCreate(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Constants,
  ufrmSysErisimHakki,
  Ths.Erp.Database.Table.SysErisimHakki,
  ufrmSysKullanicilar,
  Ths.Erp.Database.Table.SysKullanici;

{$R *.dfm}

function TfrmSysUserAccessRights.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysUserAccessRight.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysUserAccessRight.Create(Self, Self, TSysErisimHakki.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysUserAccessRight.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysUserAccessRights.FormCreate(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSysUserAccessRights.FormShow(Sender: TObject);
begin
  inherited;

  setDisplayFormatInteger(TSysErisimHakki(Table).KaynakKodu.FieldName, '0', grd.DataSource.DataSet);

  mnicopy_record.Visible := True;
end;

end.
