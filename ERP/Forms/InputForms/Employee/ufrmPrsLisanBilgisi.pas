unit ufrmPrsLisanBilgisi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin

  , ufrmBase
  , ufrmBaseInputDB
  , Ths.Erp.Database.Table.SetPrsLisan
  , Ths.Erp.Database.Table.SetPrsLisanSeviyesi
  , Ths.Erp.Database.Table.PrsPersonel
  ;

type
  TfrmEmpLangAbility = class(TfrmBaseInputDB)
    lblemp_lang_id: TLabel;
    lblread_level_id: TLabel;
    lblwrite_level_id: TLabel;
    lblspeak_level_id: TLabel;
    lblemp_card_id: TLabel;
    cbbemp_lang_id: TComboBox;
    cbbread_level_id: TComboBox;
    cbbwrite_level_id: TComboBox;
    cbbspeak_level_id: TComboBox;
    cbbemp_card_id: TComboBox;
  private
    FSetEmpLang: TSetPrsLisan;
    FSetEmpLangLevel: TSetPrsLisanSeviyesi;
    FEmpCard: TPrsPersonel;
  public
  protected
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.PrsLisanBilgisi;

{$R *.dfm}

procedure TfrmEmpLangAbility.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsLisanBilgisi(Table).LisanID.Value := TSetPrsLisan(cbbemp_lang_id.Items.Objects[cbbemp_lang_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).OkumaID.Value := TSetPrsLisanSeviyesi(cbbread_level_id.Items.Objects[cbbread_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).YazmaID.Value := TSetPrsLisanSeviyesi(cbbwrite_level_id.Items.Objects[cbbwrite_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).KonusmaID.Value := TSetPrsLisanSeviyesi(cbbspeak_level_id.Items.Objects[cbbspeak_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).PersonelID.Value := TPrsPersonel(cbbemp_card_id.Items.Objects[cbbemp_card_id.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmEmpLangAbility.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetEmpLang := TSetPrsLisan.Create(Table.Database);
  FSetEmpLangLevel := TSetPrsLisanSeviyesi.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbbemp_lang_id.Clear;
  FSetEmpLang.SelectToList('', False, False);
  for n1 := 0 to FSetEmpLang.List.Count-1 do
    cbbemp_lang_id.Items.AddObject(TSetPrsLisan(FSetEmpLang.List[n1]).Lisan.Value, TSetPrsLisan(FSetEmpLang.List[n1]));
  cbbemp_lang_id.ItemIndex := -1;

  cbbread_level_id.Clear;
  cbbwrite_level_id.Clear;
  cbbspeak_level_id.Clear;
  FSetEmpLangLevel.SelectToList('', False, False);
  for n1 := 0 to FSetEmpLangLevel.List.Count-1 do
  begin
    cbbread_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]));
    cbbwrite_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]));
    cbbspeak_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetEmpLangLevel.List[n1]));
  end;
  cbbread_level_id.ItemIndex := -1;
  cbbwrite_level_id.ItemIndex := -1;
  cbbspeak_level_id.ItemIndex := -1;

  cbbemp_card_id.Clear;
  FEmpCard.SelectToList('', False, False);
  for n1 := 0 to FEmpCard.List.Count-1 do
    cbbemp_card_id.Items.AddObject(TPrsPersonel(FEmpCard.List[n1]).AdSoyad.Value, TPrsPersonel(FEmpCard.List[n1]));
  cbbemp_card_id.ItemIndex := -1;
end;

procedure TfrmEmpLangAbility.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpLang) then
    FSetEmpLang.Free;
  if Assigned(FSetEmpLangLevel) then
    FSetEmpLangLevel.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmEmpLangAbility.RefreshData;
begin
  cbbemp_lang_id.ItemIndex := cbbemp_lang_id.Items.IndexOf(TPrsLisanBilgisi(Table).Lisan.Value);
  cbbread_level_id.ItemIndex := cbbread_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Okuma.Value);
  cbbwrite_level_id.ItemIndex := cbbwrite_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Yazma.Value);
  cbbspeak_level_id.ItemIndex := cbbspeak_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Konusma.Value);
  cbbemp_card_id.ItemIndex := cbbemp_card_id.Items.IndexOf(TPrsLisanBilgisi(Table).Personel.Value);
end;

end.
