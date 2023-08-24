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
  Ths.Database.Table.SetPrsEhliyetler;

type
  TfrmPrsEhliyet = class(TfrmBaseInputDB)
    lblehliyet_id: TLabel;
    cbbehliyet_id: TComboBox;
    lblpersonel_id: TLabel;
    edtpersonel_id: TEdit;
  private
    FSetEmpDriverLicense: TSetPrsEhliyet;
  protected
    procedure HelperProcess(Sender: TObject); override;
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
  ufrmPrsPersoneller, Ths.Database.Table.PrsPersoneller,
  Ths.Database.Table.PrsEhliyetler;

{$R *.dfm}

procedure TfrmPrsEhliyet.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TPrsEhliyet(Table).EhliyetID.Value := TSetPrsEhliyet(cbbehliyet_id.Items.Objects[cbbehliyet_id.ItemIndex]).Id.Value;

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

  cbbehliyet_id.Clear;
  FSetEmpDriverLicense.SelectToList('', False, False);
  for n1 := 0 to FSetEmpDriverLicense.List.Count-1 do
    cbbehliyet_id.Items.AddObject(TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]).Ehliyet.Value, TSetPrsEhliyet(FSetEmpDriverLicense.List[n1]));
  cbbehliyet_id.ItemIndex := -1;
end;

procedure TfrmPrsEhliyet.FormDestroy(Sender: TObject);
begin
  if Assigned(FSetEmpDriverLicense) then
    FSetEmpDriverLicense.Free;
  inherited;
end;

procedure TfrmPrsEhliyet.FormPaint(Sender: TObject);
begin
  inherited;
end;

procedure TfrmPrsEhliyet.FormShow(Sender: TObject);
begin
  inherited;
//  if not AcceptBtnDoAction then
  RefreshData;
  edtpersonel_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmPrsEhliyet.HelperProcess(Sender: TObject);
var
  LPrs: TPrsPersonel;
  LFrmPrs: TfrmPrsPersoneller;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if (TEdit(Sender).Name = edtpersonel_id.Name) then
      begin
        LPrs := TPrsPersonel.Create(Table.Database);
        LFrmPrs := TfrmPrsPersoneller.Create(TEdit(Sender), Self, LPrs, fomNormal, True);
        try
          LFrmPrs.ShowModal;
          if LFrmPrs.DataAktar then
          begin
            if LFrmPrs.CleanAndClose then
            begin
              TPrsEhliyet(Table).PersonelID.Value := 0;
              TEdit(Sender).Clear;
            end
            else
            begin
              TPrsEhliyet(Table).PersonelID.Value := LFrmPrs.Table.Id.Value;
              TEdit(Sender).Text := LPrs.AdSoyad.AsString;
            end;
          end;
        finally
          LFrmPrs.Free;
        end;
      end
    end;
  end;
end;

procedure TfrmPrsEhliyet.RefreshData;
begin
  cbbehliyet_id.ItemIndex := cbbehliyet_id.Items.IndexOf(TPrsEhliyet(Table).Ehliyet.Value);
  edtpersonel_id.Text := TPrsEhliyet(Table).Personel.AsString;
end;

procedure TfrmPrsEhliyet.Repaint;
begin
  inherited;
end;

end.
