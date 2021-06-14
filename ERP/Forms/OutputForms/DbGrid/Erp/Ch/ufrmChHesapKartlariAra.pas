unit ufrmChHesapKartlariAra;

interface

{$I ThsERP.inc}

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
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, frxExportXLS;

type
  TfrmHesapKartlariAra = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  ufrmChHesapKartiAra,
  Ths.Erp.Database.Table.ChHesapKartiAra;

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
   ' OR (' + TChHesapKartiAra(Table).SeviyeSayisi.FieldName + '=' + IntToStr(2) + ' AND '
           + Table.TableName + '.' + TChHesapKartiAra(Table).HesapTipiID.FieldName + '=' + IntToStr(Ord(htAna)) + '))';
  inherited;
end;

end.
