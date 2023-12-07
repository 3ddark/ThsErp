unit ufrmPrsLisanBilgileri;

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
  TfrmPrsLisanBilgileri = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm; override;
  end;

implementation

uses
  ufrmPrsLisanBilgisi, Ths.Database.Table.PrsLisanBilgileri;

{$R *.dfm}

function TfrmPrsLisanBilgileri.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmPrsLisanBilgisi.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmPrsLisanBilgisi.Create(Application, Self, TPrsLisanBilgisi.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmPrsLisanBilgisi.Create(Application, Self, Table.Clone(), pFormMode);
end;

end.
