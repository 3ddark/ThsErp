unit ufrmUrtReceteler;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.Actions, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Vcl.ActnList, Data.DB,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmRctReceteler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table.UrtReceteler,
  ufrmRctReceteDetaylar;

{$R *.dfm}

function TfrmRctReceteler.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TUrtRecete(Table.List[0]).Clone, AFormMode)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TUrtRecete.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmRctReceteDetaylar.Create(Application, Self, TUrtRecete(Table.List[0]).Clone, AFormMode);
end;

end.
