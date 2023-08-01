unit ufrmSysOlcuBirimiTipleri;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Types, System.Classes, System.Math, System.StrUtils, System.UITypes,
  System.Rtti, System.Diagnostics, System.TimeSpan, System.TypInfo,
  System.Actions, Vcl.ImgList, Vcl.Menus, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Clipbrd, Vcl.ActnList, Data.DB,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  udm, ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

type
  TfrmSysOlcuBirimiTipleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Constants,
  ufrmSysOlcuBirimiTipi,
  Ths.Database.Table.SysOlcuBirimiTipleri;

{$R *.dfm}

function TfrmSysOlcuBirimiTipleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysOlcuBirimiTipi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysOlcuBirimiTipi.Create(Application, Self, TSysOlcuBirimiTipi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysOlcuBirimiTipi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
