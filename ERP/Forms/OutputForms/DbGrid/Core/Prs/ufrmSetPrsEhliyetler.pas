unit ufrmSetPrsEhliyetler;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Types, System.Classes, System.Math, System.StrUtils, System.UITypes,
  System.Rtti, System.Diagnostics, System.TimeSpan, System.TypInfo,
  System.Actions, Vcl.ImgList, Vcl.Menus, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.AppEvnts,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Clipbrd, Vcl.ActnList, Data.DB,
//  frxUtils, frxClass, frxExportPDF, frxExportXLS, frxPreview, frxExportBaseDialog, frxDBSet,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, udm, ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSetPrsEhliyetler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Constants, ufrmSetPrsEhliyet, Ths.Database.Table.SetPrsEhliyetler;

{$R *.dfm}

function TfrmSetPrsEhliyetler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetPrsEhliyet.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetPrsEhliyet.Create(Application, Self, TSetPrsEhliyet.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetPrsEhliyet.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
