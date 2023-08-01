unit ufrmChHesapKartlari;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, System.Actions,
  Vcl.Controls, Vcl.Forms, Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ExtCtrls, Vcl.ImgList, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids,
  Vcl.Dialogs, Vcl.ActnList, Data.DB, ufrmBase, ufrmBaseDBGrid,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ZPgEventAlerter;

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
begin
  QryFiltreVarsayilanKullanici := QryFiltreVarsayilanKullanici + ' AND ' + Table.TableName + '.' + TChHesapKarti(Table).HesapTipiID.FieldName + '=' + Ord(htSon).ToString;
  inherited;
end;

end.
