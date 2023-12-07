unit ufrmUrtPaketHammaddeler;

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
  TfrmRctPaketHammaddeler = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.UrtPaketHammaddeler,
  ufrmRctPaketHammaddeDetaylar;

{$R *.dfm}

function TfrmRctPaketHammaddeler.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmRctPaketHammaddeDetaylar.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmRctPaketHammaddeDetaylar.Create(Application, Self, TUrtPaketHammadde.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmRctPaketHammaddeDetaylar.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
