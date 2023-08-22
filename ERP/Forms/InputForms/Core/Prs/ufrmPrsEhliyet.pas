unit ufrmPrsEhliyet;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase,
  ufrmBaseInputDB,
  Ths.Database.Table.SetPrsEhliyetler,
  Ths.Database.Table.PrsPersoneller;

type
  TfrmPrsEhliyet = class(TfrmBaseInputDB)
    lblehliyet_id: TLabel;
    cbbehliyet_id: TComboBox;
    lblpersonel_id: TLabel;
    cbbpersonel_id: TComboBox;
  private
    FSetEmpDriverLicense: TSetPrsEhliyet;
    FEmpCard: TPrsPersonel;
  public
    procedure Repaint; override;
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
  Ths.Database.Table.PrsEhliyetler;

{$R *.dfm}

procedure TfrmPrsEhliyet.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsEhliyet(Table).EhliyetID.Value := TSetPrsEhliyet(cbbehliyet_id.Items.Objects[cbbehliyet_id.ItemIndex]).Id.Value;
      TPrsEhliyet(Table).PersonelID.Value := TPrsPersonel(cbbpersonel_id.Items.Objects[cbbpersonel_id.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmPrsEhliyet.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetEmpDriverLicense := TSetPrsEhliyet.Create(Table.Database);
  FEmpCard := TPrsPersonel.Create(Table.Database);

  cbbehliyet_id.Clear;
  FSetEmpDriverLicense.SelectToList('', False, False);
  for n1 := 0 to FSetEmpDriverLicense.List.Count-1 do
    cbbehliyet_id.Items.AddObject(TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]).Ehliyet.Value, TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]));
  cbbehliyet_id.ItemIndex := -1;

  cbbpersonel_id.Clear;
  FEmpCard.SelectToList('', False, False);
  for n1 := 0 to FEmpCard.List.Count-1 do
    cbbpersonel_id.Items.AddObject(TPrsPersonel(FEmpCard.List[n1]).AdSoyad.Value, TPrsPersonel(FEmpCard.List[n1]));
  cbbpersonel_id.ItemIndex := -1;
end;

procedure TfrmPrsEhliyet.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpDriverLicense) then
    FSetEmpDriverLicense.Free;
  if Assigned(FEmpCard) then
    FEmpCard.Free;
  inherited;
end;

procedure TfrmPrsEhliyet.FormPaint(Sender: TObject);
begin
  inherited;
  cbbpersonel_id.Enabled := False;
end;

procedure TfrmPrsEhliyet.FormShow(Sender: TObject);
begin
  inherited;
//  if not AcceptBtnDoAction then
  RefreshData;
  cbbpersonel_id.Enabled := False;
end;

procedure TfrmPrsEhliyet.RefreshData;
var
  n1: Integer;
begin
  for n1 := 0 to cbbpersonel_id.Items.Count-1 do
  begin
    if Assigned(cbbpersonel_id.Items.Objects[n1]) then
      if TPrsPersonel(cbbpersonel_id.Items.Objects[n1]).Id.Value = TPrsEhliyet(Table).PersonelID.Value then
      begin
        cbbpersonel_id.ItemIndex := n1;
        Break;
      end;
  end;

  cbbehliyet_id.ItemIndex := cbbehliyet_id.Items.IndexOf(TPrsEhliyet(Table).Ehliyet.Value);
end;

procedure TfrmPrsEhliyet.Repaint;
begin
  inherited;
  //cbbemp_card_id.Enabled := False;
end;

end.
