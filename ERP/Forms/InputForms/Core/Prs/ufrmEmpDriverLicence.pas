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
  Ths.Database.Table.SeTEmpDriverLicenceler;

type
  TEmpDriverLicenceForm = class(TfrmBaseInputDB)
    lblehliyet_id: TLabel;
    cbbehliyet_id: TComboBox;
    lblpersonel_id: TLabel;
    edtpersonel_id: TEdit;
  private
    FSetEmpDriverLicense: TSeTEmpDriverLicence;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormShow(Sender: TObject); override;

  end;

implementation

uses
  ufrmEmpPersonneller, Ths.Database.Table.EmpPersonneller,
  Ths.Database.Table.EmpDriverLicenceler;

{$R *.dfm}

procedure TEmpDriverLicenceForm.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TEmpDriverLicence(Table).EhliyetID.Value := TSeTEmpDriverLicence(cbbehliyet_id.Items.Objects[cbbehliyet_id.ItemIndex]).Id.Value;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TEmpDriverLicenceForm.FormCreate(Sender: TObject);
var
  n1: Integer;
begin
  inherited;
  FSetEmpDriverLicense := TSeTEmpDriverLicence.Create(Table.Database);

  cbbehliyet_id.Clear;
  FSetEmpDriverLicense.SelectToList('', False, False);
  for n1 := 0 to FSetEmpDriverLicense.List.Count-1 do
    cbbehliyet_id.Items.AddObject(TSeTEmpDriverLicence(FSetEmpDriverLicense.List[n1]).Ehliyet.Value, TSeTEmpDriverLicence(FSetEmpDriverLicense.List[n1]));
  cbbehliyet_id.ItemIndex := 0;
end;

procedure TEmpDriverLicenceForm.FormDestroy(Sender: TObject);
begin
  FSetEmpDriverLicense.Free;
  inherited;
end;

procedure TEmpDriverLicenceForm.FormShow(Sender: TObject);
begin
  edtpersonel_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TEmpDriverLicenceForm.HelperProcess(Sender: TObject);
var
  LPrs: TEmpPersonnel;
  LFrmPrs: TEmpPersonnelListForm;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if (TEdit(Sender).Name = edtpersonel_id.Name) then
      begin
        LPrs := TEmpPersonnel.Create(Table.Database);
        LFrmPrs := TEmpPersonnelListForm.Create(TEdit(Sender), Self, LPrs, fomNormal, True);
        try
          LFrmPrs.ShowModal;
          if LFrmPrs.DataAktar then
          begin
            if LFrmPrs.CleanAndClose then
            begin
              TEmpDriverLicence(Table).PersonelID.Value := 0;
              TEdit(Sender).Clear;
            end
            else
            begin
              TEmpDriverLicence(Table).PersonelID.Value := LFrmPrs.Table.Id.Value;
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

procedure TEmpDriverLicenceForm.RefreshData;
begin
  cbbehliyet_id.ItemIndex := cbbehliyet_id.Items.IndexOf(TEmpDriverLicence(Table).Ehliyet.AsString);
  edtpersonel_id.Text := TEmpDriverLicence(Table).Personel.AsString;
end;

end.


