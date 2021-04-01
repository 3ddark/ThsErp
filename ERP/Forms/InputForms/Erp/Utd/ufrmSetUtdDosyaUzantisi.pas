unit ufrmSetUtdDosyaUzantisi;

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
  , Dialogs
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

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB, System.Actions
  ;

type
  TfrmSetUtdDosyaUzantisi = class(TfrmBaseInputDB)
    lbldosya_uzantisi: TLabel;
    lblfake_dosya_uzantisi: TLabel;
    dlgDosyaSec: TOpenTextFileDialog;
    edtfake_dosya_uzantisi: TEdit;
    cbbdosya_uzantisi: TComboBox;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  private
  public
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.SetUtdDosyaUzantisi
  ;


procedure TfrmSetUtdDosyaUzantisi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetUtdDosyaUzantisi(Table).FakeDosyaUzantisi.Value := edtfake_dosya_uzantisi.Text;
      TSetUtdDosyaUzantisi(Table).DosyaUzantisi.Value := cbbdosya_uzantisi.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetUtdDosyaUzantisi.FormCreate(Sender: TObject);
var
  n1: Integer;
  LPos: Integer;
begin
  inherited;
  edtfake_dosya_uzantisi.CharCase := TEditCharCase.ecNormal;
  cbbdosya_uzantisi.CharCase := TEditCharCase.ecNormal;

  cbbdosya_uzantisi.Clear;
  for n1 := 0 to Length(GDosyaUzantilari)-1 do
  begin
    LPos := Pos('|*.', GDosyaUzantilari[n1]);
    if LPos > 0 then
      cbbdosya_uzantisi.Items.Add(Copy(GDosyaUzantilari[n1], LPos+3, Length(GDosyaUzantilari[n1])))
  end;
  if cbbdosya_uzantisi.Items.Count > 0 then
    cbbdosya_uzantisi.ItemIndex := 0;
end;

procedure TfrmSetUtdDosyaUzantisi.RefreshData;
begin
  edtfake_dosya_uzantisi.Text := FormatedVariantVal(TSetUtdDosyaUzantisi(Table).FakeDosyaUzantisi);
  cbbdosya_uzantisi.ItemIndex := cbbdosya_uzantisi.Items.IndexOf(FormatedVariantVal(TSetUtdDosyaUzantisi(Table).DosyaUzantisi));
end;

end.
