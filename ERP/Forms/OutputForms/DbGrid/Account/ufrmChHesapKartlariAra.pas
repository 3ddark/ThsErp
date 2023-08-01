unit ufrmChHesapKartlariAra;

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
  ufrmBaseDBGrid, ZAbstractRODataset, ZAbstractDataset, ZDataset,
  ZPgEventAlerter;

type
  TfrmHesapKartlariAra = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table,
  ufrmChHesapKartiAra,
  Ths.Database.Table.ChHesapKartiAra,
  Ths.Database.Table.ChHesapKarti;

{$R *.dfm}

function TfrmHesapKartlariAra.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmHesapKartiAra.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmHesapKartiAra.Create(Application, Self, TChHesapKartiAra.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmHesapKartiAra.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmHesapKartlariAra.FormShow(Sender: TObject);
begin
  QryFiltreVarsayilanKullanici :=
  ' AND (' + Table.TableName + '.' + TChHesapKartiAra(Table).HesapTipiID.FieldName + '=' + IntToStr(Ord(htAra)) +
   ' OR (' + TChHesapKartiAra(Table).Seviye.FieldName + '=' + IntToStr(2) + ' AND '
           + Table.TableName + '.' + TChHesapKartiAra(Table).HesapTipiID.FieldName + '=' + IntToStr(Ord(htAna)) + '))';
  inherited;
end;

end.
