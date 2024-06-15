unit ufrmStkCinsOzellikleri;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.DBGrids,
  Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase, ufrmBaseDBGrid,
  System.Actions, Vcl.ActnList, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf;

type
  TfrmStkCinsOzellikleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmStkCinsOzelligi, Ths.Database.Table.StkCinsOzellikleri;

{$R *.dfm}

function TfrmStkCinsOzellikleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmStkCinsOzelligi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmStkCinsOzelligi.Create(Application, Self, TStkCinsOzellik.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmStkCinsOzelligi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
