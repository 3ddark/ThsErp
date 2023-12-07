unit ufrmChBankalar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmChBankalar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmChBanka, Ths.Database.Table.ChBankalar;

{$R *.dfm}

function TfrmChBankalar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmChBanka.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmChBanka.Create(Application, Self, TChBanka.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmChBanka.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.

