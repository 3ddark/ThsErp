unit ufrmSysLisanDataIcerikler;

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
  FireDAC.Comp.DataSet,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList;

type
  TfrmSysLisanDataIcerikler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Constants,
  ufrmSysLisanDataIcerik,
  Ths.Erp.Database.Table.SysLisanDataIcerik;

{$R *.dfm}

function TfrmSysLisanDataIcerikler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysLangDataContent.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysLangDataContent.Create(Self, Self, TSysLisanDataIcerik.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysLangDataContent.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysLisanDataIcerikler.FormShow(Sender: TObject);
begin
  inherited;
  mnicopy_record.Visible := True;
end;

end.
