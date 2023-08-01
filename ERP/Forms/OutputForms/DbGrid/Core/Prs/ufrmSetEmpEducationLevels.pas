unit ufrmSetEmpEducationLevels;

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
  ZPgEventAlerter,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  udm,
  ufrmBase,
  ufrmBaseDBGrid;

type
  TfrmSetEmpEducationLevels = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSetEmpEducationLevel,
  Ths.Database.Table.SetPrsLisanSeviyeleri;

{$R *.dfm}

function TfrmSetEmpEducationLevels.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetEmpEducationLevel.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetEmpEducationLevel.Create(Application, Self, TSetPrsLisanSeviyesi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetEmpEducationLevel.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
