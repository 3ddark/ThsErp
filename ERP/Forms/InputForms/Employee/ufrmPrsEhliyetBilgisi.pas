unit ufrmPrsEhliyetBilgisi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SetPrsEhliyet,
  Ths.Erp.Database.Table.PrsPersonel;

type
  TfrmEmpDriverLicenseAbility = class(TfrmBaseInputDB)
    lbldriver_license_id: TLabel;
    cbbdriver_license_id: TComboBox;
    lblemp_card_id: TLabel;
    cbbemp_card_id: TComboBox;
    lblis_active: TLabel;
    chkis_active: TCheckBox;
  private
    FSetEmpDriverLicense: TSetPrsEhliyet;
    FEmpCard: TPrsPersonel;
  public
    procedure Repaint; override;
  protected
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormShow(Sender: TObject); override;
    procedure FormPaint(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.PrsEhliyetBilgisi;

{$R *.dfm}

procedure TfrmEmpDriverLicenseAbility.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsEhliyetBilgisi(Table).EhliyetID.Value := TSetPrsEhliyet(cbbdriver_license_id.Items.Objects[cbbdriver_license_id.ItemIndex]).Id.Value;
      TPrsEhliyetBilgisi(Table).PersonelID.Value := TPrsPersonel(cbbemp_card_id.Items.Objects[cbbemp_card_id.ItemIndex]).Id.Value;
      TPrsEhliyetBilgisi(Table).IsAktif.Value := chkis_active.Checked;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmEmpDriverLicenseAbility.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetEmpDriverLicense := TSetPrsEhliyet.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbbdriver_license_id.Clear;
  FSetEmpDriverLicense.SelectToList('', False, False);
  for n1 := 0 to FSetEmpDriverLicense.List.Count-1 do
    cbbdriver_license_id.Items.AddObject(TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]).Ehliyet.Value, TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]));
  cbbdriver_license_id.ItemIndex := -1;

  cbbemp_card_id.Clear;
  FEmpCard.SelectToList('', False, False);
  for n1 := 0 to FEmpCard.List.Count-1 do
    cbbemp_card_id.Items.AddObject(TPrsPersonel(FEmpCard.List[n1]).AdSoyad.Value, TPrsPersonel(FEmpCard.List[n1]));
  cbbemp_card_id.ItemIndex := -1;
end;

procedure TfrmEmpDriverLicenseAbility.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpDriverLicense) then
    FSetEmpDriverLicense.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmEmpDriverLicenseAbility.FormPaint(Sender: TObject);
begin
  inherited;
  cbbemp_card_id.Enabled := False;
end;

procedure TfrmEmpDriverLicenseAbility.FormShow(Sender: TObject);
begin
  inherited;
//  if not AcceptBtnDoAction then
  RefreshData;
  cbbemp_card_id.Enabled := False;
end;

procedure TfrmEmpDriverLicenseAbility.RefreshData;
var
  n1: Integer;
begin
  for n1 := 0 to cbbemp_card_id.Items.Count-1 do
  begin
    if Assigned(cbbemp_card_id.Items.Objects[n1]) then
      if TPrsPersonel(cbbemp_card_id.Items.Objects[n1]).Id.Value = TPrsEhliyetBilgisi(Table).PersonelID.Value then
      begin
        cbbemp_card_id.ItemIndex := n1;
        Break;
      end;
  end;

  cbbdriver_license_id.ItemIndex := cbbdriver_license_id.Items.IndexOf(TPrsEhliyetBilgisi(Table).Ehliyet.Value);
  chkis_active.Checked := TPrsEhliyetBilgisi(Table).IsAktif.Value;
end;

procedure TfrmEmpDriverLicenseAbility.Repaint;
begin
  inherited;
  //cbbemp_card_id.Enabled := False;
end;

end.
