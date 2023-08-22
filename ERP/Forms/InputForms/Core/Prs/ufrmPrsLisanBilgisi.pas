unit ufrmPrsLisanBilgisi;

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
  TfrmPrsLisanBilgisi = class(TfrmBaseInputDB)
    lbllisan_id: TLabel;
    lblokuma_seviyesi_id: TLabel;
    lblyazma_seviyesi_id: TLabel;
    lblkonusma_seviyesi_id: TLabel;
    lblpersonel_id: TLabel;
    cbblisan_id: TComboBox;
    cbbokuma_seviyesi_id: TComboBox;
    cbbyazma_seviyesi_id: TComboBox;
    cbbkonusma_seviyesi_id: TComboBox;
    cbbpersonel_id: TComboBox;
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

procedure TfrmPrsLisanBilgisi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsLisanBilgisi(Table).LisanID.Value := TSetPrsLisan(cbblisan_id.Items.Objects[cbblisan_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).OkumaID.Value := TSetPrsLisanSeviyesi(cbbokuma_seviyesi_id.Items.Objects[cbbokuma_seviyesi_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).YazmaID.Value := TSetPrsLisanSeviyesi(cbbyazma_seviyesi_id.Items.Objects[cbbyazma_seviyesi_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).OkumaID.Value := TSetPrsLisanSeviyesi(cbbkonusma_seviyesi_id.Items.Objects[cbbkonusma_seviyesi_id.ItemIndex]).Id.Value;
      TPrsLisanBilgisi(Table).PersonelID.Value := TPrsPersonel(cbbpersonel_id.Items.Objects[cbbpersonel_id.ItemIndex]).Id.Value;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmPrsLisanBilgisi.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetPrsLisan := TSetPrsLisan.Create(Table.Database);
  FSetPrsLisanSeviyesi := TSetPrsLisanSeviyesi.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbblisan_id.Clear;
  FSetPrsLisan.SelectToList('', False, False);
  for n1 := 0 to FSetPrsLisan.List.Count-1 do
    cbblisan_id.Items.AddObject(TSetPrsLisan(FSetPrsLisan.List[n1]).Lisan.Value, TSetPrsLisan(FSetPrsLisan.List[n1]));
  cbblisan_id.ItemIndex := -1;

  cbbokuma_seviyesi_id.Clear;
  cbbyazma_seviyesi_id.Clear;
  cbbkonusma_seviyesi_id.Clear;
  FSetPrsLisanSeviyesi.SelectToList('', False, False);
  for n1 := 0 to FSetPrsLisanSeviyesi.List.Count-1 do
  begin
    cbbokuma_seviyesi_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
    cbbyazma_seviyesi_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
    cbbkonusma_seviyesi_id.Items.AddObject(TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]).LisanSeviyesi.Value, TSetPrsLisanSeviyesi(FSetPrsLisanSeviyesi.List[n1]));
  end;
  cbbokuma_seviyesi_id.ItemIndex := -1;
  cbbyazma_seviyesi_id.ItemIndex := -1;
  cbbkonusma_seviyesi_id.ItemIndex := -1;

  cbbpersonel_id.Clear;
  FEmpCard.SelectToList('', False, False);
  for n1 := 0 to FEmpCard.List.Count-1 do
    cbbpersonel_id.Items.AddObject(TPrsPersonel(FEmpCard.List[n1]).AdSoyad.Value, TPrsPersonel(FEmpCard.List[n1]));
  cbbpersonel_id.ItemIndex := -1;
end;

procedure TfrmPrsLisanBilgisi.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetPrsLisan) then
    FSetPrsLisan.Free;
  if Assigned(FSetPrsLisanSeviyesi) then
    FSetPrsLisanSeviyesi.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmPrsLisanBilgisi.RefreshData;
begin
  cbblisan_id.ItemIndex := cbblisan_id.Items.IndexOf(TPrsLisanBilgisi(Table).Lisan.Value);
  cbbokuma_seviyesi_id.ItemIndex := cbbokuma_seviyesi_id.Items.IndexOf(TPrsLisanBilgisi(Table).Okuma.Value);
  cbbyazma_seviyesi_id.ItemIndex := cbbyazma_seviyesi_id.Items.IndexOf(TPrsLisanBilgisi(Table).Yazma.Value);
  cbbkonusma_seviyesi_id.ItemIndex := cbbkonusma_seviyesi_id.Items.IndexOf(TPrsLisanBilgisi(Table).Konusma.Value);
  cbbpersonel_id.ItemIndex := cbbpersonel_id.Items.IndexOf(TPrsLisanBilgisi(Table).Personel.Value);
end;

end.
