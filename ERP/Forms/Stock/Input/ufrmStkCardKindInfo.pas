unit ufrmStkCardKindInfo;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkCardKindInfo.Service, StkCardKindInfo, LocalizationManager;

type
  TfrmStkCardKindInfo = class(TfrmInputSimpleDB<TStkCardKindInfo, TStkCardKindInfoService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblcard_id: TLabel;
    edtcard_id: TEdit;
    lblkind_id: TLabel;
    edtkind_id: TEdit;
    lbls1: TLabel;
    edts1: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkCardKindInfo.BtnAcceptClick(Sender: TObject);
begin
  Table.StkKartID := StrToInt64Def(edtcard_id.Text, 0);
  Table.CinsID := StrToInt64Def(edtkind_id.Text, 0);
  Table.Deger := edts1.Text;
  inherited;
end;

procedure TfrmStkCardKindInfo.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkCardKindInfo.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtcard_id.SetFocus;
end;

procedure TfrmStkCardKindInfo.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('stk_card_kind_info.title_singular', 'Stok Kartı Cins Bilgisi');
  lblcard_id.Caption := TLocalizationManager.Translate('stk_card_kind_info.lbl_card_id', 'Stok Kart ID');
  lblkind_id.Caption := TLocalizationManager.Translate('stk_card_kind_info.lbl_kind_id', 'Cins ID');
  lbls1.Caption := TLocalizationManager.Translate('stk_card_kind_info.lbl_deger', 'Değer');
end;

procedure TfrmStkCardKindInfo.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkCardKindInfo.RefreshData;
begin
  inherited;
  edtcard_id.Text := IntToStr(Table.StkKartID);
  edtkind_id.Text := IntToStr(Table.CinsID);
  edts1.Text := Table.Deger;
end;

end.
