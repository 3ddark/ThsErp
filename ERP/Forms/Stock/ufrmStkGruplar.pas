unit ufrmStkGruplar;

interface

{$I Ths.inc}

uses
  System.Classes, Vcl.Forms, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.Dialogs, Data.DB, ufrmBase, ufrmBaseDBGrid, System.Actions,
  Vcl.ActnList, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmStkGruplar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmStkGrup, Ths.Database.Table.StkGruplar;

{$R *.dfm}

function TfrmStkGruplar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmStkGrup.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmStkGrup.Create(Application, Self, TStkGruplar.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmStkGrup.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.

