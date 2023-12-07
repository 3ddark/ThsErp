unit ufrmSetOdemeBaslangicDonemleri;

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
  TfrmSetOdemeBaslangicDonemleri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  ufrmSetOdemeBaslangicDonemi,
  Ths.Database.Table.SetOdemeBaslangicDonemi;

{$R *.dfm}

function TfrmSetOdemeBaslangicDonemleri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSetOdemeBaslangicDonemi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSetOdemeBaslangicDonemi.Create(Application, Self, TSetOdemeBaslangicDonemi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSetOdemeBaslangicDonemi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
