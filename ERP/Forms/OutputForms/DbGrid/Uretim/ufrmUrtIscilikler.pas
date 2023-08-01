unit ufrmUrtIscilikler;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Actions,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Vcl.ActnList,
  Data.DB,
  ufrmBase,
  ufrmBaseDBGrid, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZPgEventAlerter;

type
  TfrmUrtIscilikler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  ufrmUrtIscilik,
  Ths.Database.Table.UrtIscilikler;

{$R *.dfm}

function TfrmUrtIscilikler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmUrtIscilik.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmUrtIscilik.Create(Application, Self, TUrtIscilik.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmUrtIscilik.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
