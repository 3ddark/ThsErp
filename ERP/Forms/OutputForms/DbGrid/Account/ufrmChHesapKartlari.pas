unit ufrmChHesapKartlari;

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
  TfrmHesapKartlari = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table,
  ufrmChHesapKarti,
  Ths.Database.Table.ChHesapKarti,
  Ths.Database.Table.SetChHesapTipi;

{$R *.dfm}

function TfrmHesapKartlari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmHesapKarti.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmHesapKarti.Create(Application, Self, TChHesapKarti.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmHesapKarti.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmHesapKartlari.FormShow(Sender: TObject);
var
  LPasifFilter: string;
begin
  LPasifFilter := '';
  if IsHelper then
    LPasifFilter := ' AND ' + TChHesapKarti(Table).Pasif.QryName + '=False';

  QryFiltreVarsayilanKullanici := QryFiltreVarsayilanKullanici + LPasifFilter + ' AND ' + TChHesapKarti(Table).HesapTipiID.QryName + '=' + Ord(htSon).ToString;

  inherited;
end;

end.
