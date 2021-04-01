unit ufrmAyarEFaturaIletisimKanali;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmAyarEFaturaIletisimKanali = class(TfrmBaseInputDB)
    edtAciklama: TEdit;
    edtKod: TEdit;
    lblAciklama: TLabel;
    lblKod: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.AyarEFaturaIletisimKanali;

{$R *.dfm}

procedure TfrmAyarEFaturaIletisimKanali.FormCreate(Sender: TObject);
begin
  inherited;

  edtAciklama.CharCase := ecNormal;
end;

procedure TfrmAyarEFaturaIletisimKanali.RefreshData();
begin
  edtKod.Text := FormatedVariantVal(TAyarEFaturaIletisimKanali(Table).Kod);
  edtAciklama.Text := FormatedVariantVal(TAyarEFaturaIletisimKanali(Table).Aciklama);
end;

procedure TfrmAyarEFaturaIletisimKanali.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TAyarEFaturaIletisimKanali(Table).Kod.Value := edtKod.Text;
      TAyarEFaturaIletisimKanali(Table).Aciklama.Value := edtAciklama.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
