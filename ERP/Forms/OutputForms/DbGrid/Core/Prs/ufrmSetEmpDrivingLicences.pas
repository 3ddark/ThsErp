unit ufrmSetEmpDrivingLicences;

interface

{$I Ths.inc}

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
  ZAbstractRODataset,
  ZAbstractDataset,
  ZDataset,
  ZAbstractConnection,
  ZConnection,
  frxClass,
  frxUtils,
  frxExportPDF,
  frxExportXLS,
  frxPreview,
  frxExportBaseDialog,
  frxDBSet,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  udm,
  ufrmBase,
  ufrmBaseDBGrid, ZPgEventAlerter;

type
  TfrmSetEmpDrivingLicences = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSetEmpDrivingLicence,
  Ths.Database.Table.SetPrsEhliyetler;

{$R *.dfm}

function TfrmSetEmpDrivingLicences.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetEmpDrivingLicence.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetEmpDrivingLicence.Create(Application, Self, TSetPrsEhliyet.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetEmpDrivingLicence.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
