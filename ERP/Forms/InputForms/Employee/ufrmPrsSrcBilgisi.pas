unit ufrmPrsSrcBilgisi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,

  ufrmBase,
  ufrmBaseInputDB,
  Ths.Erp.Database.Table.SetPrsSrcTipi,
  Ths.Erp.Database.Table.PrsPersonel;

type
  TfrmEmpSrcAbility = class(TfrmBaseInputDB)
    lblsrc_type_id: TLabel;
    lblemp_card_id: TLabel;
    cbbsrc_type_id: TComboBox;
    cbbemp_card_id: TComboBox;
  private
    FSetEmpSrcType: TSetPrsSrcTipi;
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
  Ths.Erp.Database.Table.PrsSrcBilgisi;

{$R *.dfm}

procedure TfrmEmpSrcAbility.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsSrcBilgisi(Table).SrcTipiID.Value := TSetPrsSrcTipi(cbbsrc_type_id.Items.Objects[cbbsrc_type_id.ItemIndex]).Id.Value;
      TPrsSrcBilgisi(Table).PersonelID.Value := TPrsPersonel(cbbemp_card_id.Items.Objects[cbbemp_card_id.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmEmpSrcAbility.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetEmpSrcType := TSetPrsSrcTipi.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbbsrc_type_id.Clear;
  FSetEmpSrcType.SelectToList('', False, False);
  for n1 := 0 to FSetEmpSrcType.List.Count-1 do
    cbbsrc_type_id.Items.AddObject(TSetPrsSrcTipi(FSetEmpSrcType.List[n1]).SrcTipi.Value, TSetPrsSrcTipi(FSetEmpSrcType.List[n1]));
  cbbsrc_type_id.ItemIndex := -1;

  cbbemp_card_id.Clear;
  FEmpCard.SelectToList('', False, False);
  for n1 := 0 to FEmpCard.List.Count-1 do
    cbbemp_card_id.Items.AddObject(TPrsPersonel(FEmpCard.List[n1]).AdSoyad.Value, TPrsPersonel(FEmpCard.List[n1]));
  cbbemp_card_id.ItemIndex := -1;
end;

procedure TfrmEmpSrcAbility.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpSrcType) then
    FSetEmpSrcType.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmEmpSrcAbility.RefreshData;
begin
  cbbsrc_type_id.ItemIndex := cbbsrc_type_id.Items.IndexOf(TPrsSrcBilgisi(Table).SrcTipi.Value);
  cbbemp_card_id.ItemIndex := cbbemp_card_id.Items.IndexOf(TPrsSrcBilgisi(Table).Personel.Value);
end;

end.
