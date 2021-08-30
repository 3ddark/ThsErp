unit ufrmSysIlceler;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Types,
  System.Classes,
  System.Math,
  System.StrUtils,
  System.UITypes,
  System.Rtti,
  System.Diagnostics,
  System.TimeSpan,
  System.TypInfo,
  System.Actions,
  Vcl.ImgList,
  Vcl.Menus,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.Samples.Spin,
  Vcl.Clipbrd,
  Vcl.ActnList,
  Data.DB,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  frxClass,
  frxUtils,
  frxExportPDF,
  frxExportXLS,
  frxPreview,
  frxExportBaseDialog,
  frxDBSet,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  udm,
  ufrmBase,
  ufrmBaseDBGrid;

type
  TfrmSysIlceler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Constants,
  ufrmSysIlce,
  Ths.Erp.Database.Table.SysIlce;

{$R *.dfm}

function TfrmSysIlceler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysIlce.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysIlce.Create(Application, Self, TSysIlce.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysIlce.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
