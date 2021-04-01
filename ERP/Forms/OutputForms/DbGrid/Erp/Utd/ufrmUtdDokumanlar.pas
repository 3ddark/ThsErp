unit ufrmUtdDokumanlar;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.IOUtils,
  Winapi.ShellAPI,
  Winapi.Windows,
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
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid;

type
  TfrmUtdDokumanlar = class(TfrmBaseDBGrid)
    mniDosyaGoster: TMenuItem;
    procedure mniDosyaGosterClick(Sender: TObject);
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Database.Singleton,
  ufrmUtdDokuman,
  Ths.Erp.Database.Table.UtdDokuman;

{$R *.dfm}

function TfrmUtdDokumanlar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmUtdDokuman.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmUtdDokuman.Create(Application, Self, TUtdDokuman.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmUtdDokuman.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmUtdDokumanlar.mniDosyaGosterClick(Sender: TObject);
var
  LDoc: TUtdDokuman;
var
  LFileStored: string;
  LFileTemp: string;
  LTempFolder: string;
begin
  LDoc := TUtdDokuman.Create(Table.Database);
  LDoc.SelectToList(' AND ' + LDoc.TableName + '.' + LDoc.Id.FieldName + '=' + IntToStr(FormatedVariantVal(Table.Id)), False, False);
  if LDoc.List.Count = 1 then
  begin
    //dosya fake uzantý ile saklandýðý için önce fake dosya yolunu alýyoruz.
    LFileStored := LDoc.GetFileName(True);
    //sonrasýnda gerçek dosya uzantýsý ile alýyoruz.
    LFileTemp := LDoc.GetFileName(False);
    LTempFolder := GetTempFolder;
    LFileTemp := LTempFolder + ExtractFileName(LFileTemp);
    TFile.Copy(LFileStored, LFileTemp, True);

    ShellExecute(0, 'open', PWideChar(LFileTemp), '', '', SW_NORMAL);
  end
  else
    FreeAndNil(LDoc);
end;

end.
