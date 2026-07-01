unit ufrmAccHesapKartlariAra;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Actions,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Vcl.ActnList,
  Data.DB,
  ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmAccHesapKartlariAra = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table,
  ufrmAccHesapKartiAra,
  Ths.Database.Table.ChHesapKartiAra,
  Ths.Database.Table.ChHesapKarti;

{$R *.dfm}

function TfrmAccHesapKartlariAra.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmAccHesapKartiAra.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmAccHesapKartiAra.Create(Application, Self, TChHesapKartiAra.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmAccHesapKartiAra.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmAccHesapKartlariAra.FormShow(Sender: TObject);
begin
  QryFiltreVarsayilanKullanici :=
  ' AND (' + TChHesapKartiAra(Table).HesapTipiID.QryName + '=' + IntToStr(Ord(htAra)) +
   ' OR (' + TChHesapKartiAra(Table).Seviye.FieldName + '=' + IntToStr(2) + ' AND '
           + TChHesapKartiAra(Table).HesapTipiID.QryName + '=' + IntToStr(Ord(htAna)) + '))';
  inherited;
end;

end.
