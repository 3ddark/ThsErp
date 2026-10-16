unit ufrmInputLineDB;

// Ana kayıt + detay ekranının satır formu tabanı (ör. teklif kalemi). DB'ye yazmaz: Onayla satırı doğrulayıp
// ana forma döndürür (bellekte), Sil satırı silinecek işaretler; kayıt ana formun Onayla'sında tek transaction'da.
// Modal açılır (TDetailSet), Table nesnesi kabulde ana forma geçer. Kapanışta ana formun transaction'ına dokunmaz.
// Formlar TfrmInputSimpleDB gibi yazılır: BtnAcceptClick'te kontroller -> Table, sonra inherited.

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.Dialogs,
  Entity, Service, SharedFormTypes, ufrmInputSimpleDB, Detail.Lines;

type
  TfrmInputLineDB<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TfrmInputSimpleDB<TE, TS>, ILineForm)
  private
    FLineResult: TLineFormResult;
  protected
    // Kabul öncesi (kontroller Table'a yazıldıktan sonra): hesaplanan alanlar (tutarlar …) burada doldurulur;
    // geçersizse hata yükseltilir
    procedure PrepareLine; virtual;
  public
    // ILineForm
    function LineResult: TLineFormResult;
    function ExtractLine: TObject;

    procedure FormShow(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure BtnDeleteClick(Sender: TObject); override;
  end;

implementation

uses
  LocalizationManager, Ths.DialogHelper, Logger;

function TfrmInputLineDB<TE, TS>.LineResult: TLineFormResult;
begin
  Result := FLineResult;
end;

function TfrmInputLineDB<TE, TS>.ExtractLine: TObject;
begin
  Result := Table;
  Table := nil;
end;

procedure TfrmInputLineDB<TE, TS>.PrepareLine;
begin
//
end;

procedure TfrmInputLineDB<TE, TS>.FormShow(Sender: TObject);
begin
  inherited;
  // satırlar arası gezinti yok; salt okunurda yalnız Kapat
  BtnSpin.Visible := False;
  if FormMode = ifmReadOnly then
    BtnAccept.Visible := False;
end;

procedure TfrmInputLineDB<TE, TS>.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // inherited yok: TfrmInputSimpleDB güncelleme modunda transaction'ı geri alır (o transaction ana formun kilidi)
  GLogger.InfoFmt('Close Line Form: %s', [Self.ClassName]);
  Action := caHide;
end;

procedure TfrmInputLineDB<TE, TS>.BtnAcceptClick(Sender: TObject);
begin
  if FormMode in [ifmReadOnly, ifmRewiev] then
  begin
    ModalResult := mrCancel;
    Exit;
  end;

  if not ValidateInput(PanelMain) then
    Exit;
  PrepareLine;
  FLineResult := lfrAccept;
  ModalResult := mrOk;
end;

procedure TfrmInputLineDB<TE, TS>.BtnDeleteClick(Sender: TObject);
begin
  if FormMode <> ifmUpdate then
    Exit;
  if TThsDialogHelper.CustomMsgDlg(
    TLocalizationManager.Translate(TLangKeys.TDetailForm.MsgDeleteLine, 'Delete the selected line?'),
    mtConfirmation, [mbYes, mbNo],
    [TLocalizationManager.Translate(TLangKeys.TGeneral.Yes, 'Yes'), TLocalizationManager.Translate(TLangKeys.TGeneral.No, 'No')],
    mbNo,
    TLocalizationManager.Translate(TLangKeys.TMessage.UserConfirmationTitle, 'Confirmation')) <> mrYes then
    Exit;
  FLineResult := lfrDelete;
  ModalResult := mrOk;
end;

end.
