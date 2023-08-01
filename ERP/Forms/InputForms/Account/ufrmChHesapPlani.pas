unit ufrmChHesapPlani;

interface

{$I Ths.inc}

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
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmChHesapPlani = class(TfrmBaseInputDB)
    lbltek_duzen_kodu: TLabel;
    edttek_duzen_kodu: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lblseviye_sayisi: TLabel;
    cbbseviye_sayisi: TComboBox;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure RefreshData; override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.ChHesapPlanlari;

{$R *.dfm}

procedure TfrmChHesapPlani.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChHesapPlani(Table).PlanKodu.Value := edttek_duzen_kodu.Text;
      TChHesapPlani(Table).PlanAdi.Value := edtaciklama.Text;
      TChHesapPlani(Table).Seviye.Value := StrToIntDef(cbbseviye_sayisi.Text, 1);

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmChHesapPlani.FormCreate(Sender: TObject);
begin
  inherited;
  cbbseviye_sayisi.Clear;
  cbbseviye_sayisi.Items.Add('1');
  cbbseviye_sayisi.Items.Add('2');
  cbbseviye_sayisi.Items.Add('3');
  cbbseviye_sayisi.ItemIndex := 0;
end;

procedure TfrmChHesapPlani.RefreshData;
begin
  edttek_duzen_kodu.Text := TChHesapPlani(Table).PlanKodu.AsString;
  edtaciklama.Text := TChHesapPlani(Table).PlanAdi.AsString;
  cbbseviye_sayisi.ItemIndex := cbbseviye_sayisi.Items.IndexOf(TChHesapPlani(Table).Seviye.AsString);
end;

end.
