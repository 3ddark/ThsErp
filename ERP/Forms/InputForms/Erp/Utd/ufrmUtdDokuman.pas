unit ufrmUtdDokuman;

interface

{$I ThsERP.inc}

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , StdCtrls
  , ExtCtrls
  , ComCtrls
  , StrUtils
  , DateUtils
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin
  , Vcl.ExtDlgs
  , Vcl.Dialogs

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  , Ths.Erp.Database.Table.SetUtdDosyaUzantisi
  , Ths.Erp.Database.Table.SetUtdDokumanTipi
  ;
type
  TfrmUtdDokuman = class(TfrmBaseInputDB)
    dlgDosyaSec: TOpenTextFileDialog;
    lblsiparis_no: TLabel;
    edtsiparis_no: TEdit;
    lbldokuman_tipi_id: TLabel;
    cbbdokuman_tipi_id: TComboBox;
    btndosya_sec: TButton;
    lbldosya_adi_val: TLabel;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
    procedure btndosya_secClick(Sender: TObject);
  private
    FFileExts: TSetUtdDosyaUzantisi;
    FDosyaExt: TSetUtdDosyaUzantisi;
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  public
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Table.UtdDokuman
  ;

procedure TfrmUtdDokuman.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      if (FormMode = ifmUpdate) then
      begin
        if CustomMsgDlg('Daha önce yüklenen dosyanýz varsa silinecek ve yeni dosyaný sisteme yüklenecek.' + AddLBs +
                        'Devam etmek istiyor musun?',
                        mtConfirmation, mbYesNo, ['Evet Sil', 'Hayýr'], mbNo, 'Dosya Silme Onayý') = mrNo
        then
          Exit;
      end;

      TUtdDokuman(Table).SiparisNo.Value := edtsiparis_no.Text;
      //TUtdDokuman(Table).DosyaUzantisiID.Value := btnDosyaEkle.Action ;
      TUtdDokuman(Table).DokumanTipi.Value := cbbdokuman_tipi_id.Text;
      if (cbbdokuman_tipi_id.ItemIndex >  -1) and Assigned(cbbdokuman_tipi_id.Items.Objects[cbbdokuman_tipi_id.ItemIndex]) then
        TUtdDokuman(Table).DokumanTipiID.Value := TSetUtdDokumanTipi(cbbdokuman_tipi_id.Items.Objects[cbbdokuman_tipi_id.ItemIndex]).Id.Value;


      TUtdDokuman(Table).LocalDosyaAdi.Value := lbldosya_adi_val.Caption;
      TUtdDokuman(Table).DosyaUzantisiID.Value := FDosyaExt.Id.Value;
      TUtdDokuman(Table).DosyaUzantisi.Value := FDosyaExt.DosyaUzantisi.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmUtdDokuman.btndosya_secClick(Sender: TObject);
var
  LFilter: string;
  n1, n2: Integer;
begin
  LFilter := '';
  for n1 := 0 to FFileExts.List.Count-1 do
    for n2 := 0 to Length(GDosyaUzantilari)-1 do
    begin
      if (Pos(FILE_EXT_XLS, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_XLS then
          LFilter := LFilter + ';*.' + FILE_EXT_XLS;
      end
      else if (Pos(FILE_EXT_XLSX, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_XLSX then
          LFilter := LFilter + ';*.' + FILE_EXT_XLSX;
      end
      else if (Pos(FILE_EXT_DOC, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_DOC then
          LFilter := LFilter + ';*.' + FILE_EXT_DOC;
      end
      else if (Pos(FILE_EXT_DOCX, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_DOCX then
          LFilter := LFilter + ';*.' + FILE_EXT_DOCX;
      end
      else if (Pos(FILE_EXT_ODT, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_ODT then
          LFilter := LFilter + ';*.' + FILE_EXT_ODT;
      end
      else if (Pos(FILE_EXT_ODS, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_ODS then
          LFilter := LFilter + ';*.' + FILE_EXT_ODS;
      end
      else if (Pos(FILE_EXT_PDF, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_PDF then
          LFilter := LFilter + ';*.' + FILE_EXT_PDF;
      end
      else if (Pos(FILE_EXT_PNG, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_PNG then
          LFilter := LFilter + ';*.' + FILE_EXT_PNG;
      end
      else if (Pos(FILE_EXT_JPG, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_JPG then
          LFilter := LFilter + ';*.' + FILE_EXT_JPG;
      end
      else if (Pos(FILE_EXT_BMP, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_BMP then
          LFilter := LFilter + ';*.' + FILE_EXT_BMP;
      end
      else if (Pos(FILE_EXT_TXT, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_TXT then
          LFilter := LFilter + ';*.' + FILE_EXT_TXT;
      end
      else if (Pos(FILE_EXT_DXF, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_DXF then
          LFilter := LFilter + ';*.' + FILE_EXT_DXF;
      end
      else if (Pos(FILE_EXT_DWG, GDosyaUzantilari[n2]) > 0) then
      begin
        if TSetUtdDosyaUzantisi(FFileExts.List[n1]).DosyaUzantisi.Value = FILE_EXT_DWG then
          LFilter := LFilter + ';*.' + FILE_EXT_DWG;
      end
    end;

  if LFilter = '' then
    Exit;

  LFilter := RightStr(LFilter, Length(LFilter)-1);
  LFilter := 'Pano Dokumanlar|' + LFilter;

  lbldosya_adi_val.Caption := GetDialogOpen(LFilter);
end;

destructor TfrmUtdDokuman.Destroy;
begin
  FreeAndNil(FFileExts);
  FreeAndNil(FDosyaExt);
  inherited;
end;

procedure TfrmUtdDokuman.FormCreate(Sender: TObject);
begin
  inherited;
  lbldosya_adi_val.Caption := '';

  FFileExts := TSetUtdDosyaUzantisi.Create(GDataBase);
  FFileExts.SelectToList('', False, False);

  FDosyaExt := TSetUtdDosyaUzantisi.Create(Table.Database);

  fillComboBoxData(cbbdokuman_tipi_id, TUtdDokuman(Table).FDocTip, [TUtdDokuman(Table).FDocTip.DokumanTipi.FieldName], '', True);
end;

procedure TfrmUtdDokuman.RefreshData;
begin
  edtsiparis_no.Text := FormatedVariantVal(TUtdDokuman(Table).SiparisNo);
  cbbdokuman_tipi_id.ItemIndex := cbbdokuman_tipi_id.Items.IndexOf(FormatedVariantVal(TUtdDokuman(Table).DokumanTipi));
end;

function TfrmUtdDokuman.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if lbldosya_adi_val.Caption = '' then
    CreateExceptionByLang('Lütfen önce dosya seçiniz', '999999');

  FDosyaExt.SelectToList(' AND ' + FDosyaExt.TableName + '.' + FDosyaExt.DosyaUzantisi.FieldName + '=' + QuotedStr(ExtractFileExt(lbldosya_adi_val.Caption).Replace('.', '')), False, False);
  if FDosyaExt.List.Count = 0 then
    CreateExceptionByLang('Seçilen dosyaya ait dosya uzantýsý kayýtlarda bulunamadý!', '999999');

  if FormatedVariantVal(GSysUygulamaAyariDiger.PathUTD) = '' then
    CreateExceptionByLang('Ayarlarda UTD Yedek Klasörü tanýmlu deðil! Lütfen önce tanýmlama yapýnýz.', '999999', '1');
end;

end.
