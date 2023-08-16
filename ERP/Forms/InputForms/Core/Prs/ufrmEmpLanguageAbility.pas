unit ufrmEmpLanguageAbility;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.AppEvnts,
  System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table.SetPrsLisanlar,
  Ths.Database.Table.SetPrsLisanSeviyeleri,
  Ths.Database.Table.PrsPersoneller;

type
  TfrmEmpLanguageAbility = class(TfrmBaseInputDB)
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
    FSetPrsLisan: TSetPrsLisan;
    FSetPrsLisanSeviyesi: TSetPrsLisanSeviyesi;
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
  Ths.Database.Table.PrsLisanBilgileri;

{$R *.dfm}

procedure TfrmEmpLanguageAbility.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsLisanBilgisi(Table).LisanID.Value := TSetPrsLisan(cbbemp_lang_id.Items.Objects[cbbemp_lang_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).OkumaID.Value := TSetPrsLisanSeviyesi(cbbread_level_id.Items.Objects[cbbread_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).YazmaID.Value := TSetPrsLisanSeviyesi(cbbwrite_level_id.Items.Objects[cbbwrite_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).OkumaID.Value := TSetPrsLisanSeviyesi(cbbspeak_level_id.Items.Objects[cbbspeak_level_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).PersonelID.Value := TPrsPersonel(cbbemp_card_id.Items.Objects[cbbemp_card_id.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmEmpLanguageAbility.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetPrsLisan := TSetPrsLisan.Create(Table.Database);
  FSetPrsLisanSeviyesi := TSetPrsLisanSeviyesi.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbbemp_lang_id.Clear;
  FSetPrsLisan.SelectToList('', False, False);
  for n1 := 0 to FSetPrsLisan.List.Count-1 do
    cbbemp_lang_id.Items.AddObject(TSetPrsLisan(FSetPrsLisan.List[n1]).Lisan.Value, TSetPrsLisan(FSetPrsLisan.List[n1]));
  cbbemp_lang_id.ItemIndex := -1;

  cbbread_level_id.Clear;
  cbbwrite_level_id.Clear;
  cbbspeak_level_id.Clear;
  FSetPrsLisanSeviyesi.SelectToList('', False, False);
  for n1 := 0 to FSetPrsLisanSeviyesi.List.Count-1 do
  begin
    cbbread_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
    cbbwrite_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
    cbbspeak_level_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
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

procedure TfrmEmpLanguageAbility.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetPrsLisan) then
    FSetPrsLisan.Free;
  if Assigned(FSetPrsLisanSeviyesi) then
    FSetPrsLisanSeviyesi.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmEmpLanguageAbility.RefreshData;
begin
  cbbemp_lang_id.ItemIndex := cbbemp_lang_id.Items.IndexOf(TPrsLisanBilgisi(Table).Lisan.Value);
  cbbread_level_id.ItemIndex := cbbread_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Okuma.Value);
  cbbwrite_level_id.ItemIndex := cbbwrite_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Yazma.Value);
  cbbspeak_level_id.ItemIndex := cbbspeak_level_id.Items.IndexOf(TPrsLisanBilgisi(Table).Konusma.Value);
  cbbemp_card_id.ItemIndex := cbbemp_card_id.Items.IndexOf(TPrsLisanBilgisi(Table).Personel.Value);
end;

end.
