unit ufrmSetSatSiparisDurumlar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB, ufrmBase,
  ufrmBaseDBGrid, System.Actions, Vcl.ActnList, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmSetSatSiparisDurumlar = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmSetSatSiparisDurum, Ths.Database.Table.SetSatSiparisDurum;

{$R *.dfm}

function TfrmSetSatSiparisDurumlar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetSatSiparisDurum.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetSatSiparisDurum.Create(Application, Self, TSetSatSiparisDurum.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetSatSiparisDurum.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.

