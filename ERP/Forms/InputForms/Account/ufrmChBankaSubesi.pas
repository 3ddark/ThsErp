unit ufrmChBankaSubesi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase,
  ufrmBaseInputDB;

type
  TfrmChBankaSubesi = class(TfrmBaseInputDB)
    lblbanka_id: TLabel;
    lblsube_kodu: TLabel;
    edtsube_kodu: TEdit;
    lblsube_adi: TLabel;
    edtsube_adi: TEdit;
    lblsehir_id: TLabel;
    edtbanka_id: TEdit;
    edtsehir_id: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure RefreshData(); override;
    procedure HelperProcess(Sender: TObject); override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.ChBankaSubeleri, ufrmChBankalar,
  Ths.Database.Table.ChBankalar, ufrmSysSehirler, Ths.Database.Table.SysSehirler;

{$R *.dfm}

procedure TfrmChBankaSubesi.FormCreate(Sender: TObject);
begin
  inherited;
  edtbanka_id.OnHelperProcess := HelperProcess;
  edtsehir_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmChBankaSubesi.FormDestroy(Sender: TObject);
begin
  inherited;
end;

procedure TfrmChBankaSubesi.HelperProcess(Sender: TObject);
var
  LFrmSehirler: TfrmSysSehirler;
  LFrmBankalar: TfrmChBankalar;
begin
  if Sender.ClassType <> TEdit then
    Exit;

  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if TEdit(Sender).Name = edtbanka_id.Name then
    begin
      LFrmBankalar := TfrmChBankalar.Create(TEdit(Sender), Self, TChBanka.Create(Table.Database), fomNormal, True);
      try
        LFrmBankalar.ShowModal;

        TChBankaSubesi(Table).BankaID.Value := LFrmBankalar.Table.Id.Value;
        TEdit(Sender).Text := TChBanka(LFrmBankalar.Table).BankaAdi.AsString;
      finally
        LFrmBankalar.Free;
      end;
    end
    else if TEdit(Sender).Name = edtsehir_id.Name then
    begin
      LFrmSehirler := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
      try
        LFrmSehirler.ShowModal;

        TChBankaSubesi(Table).SehirID.Value := LFrmSehirler.Table.Id.Value;
        TEdit(Sender).Text := TSysSehir(LFrmSehirler.Table).Sehir.AsString;
      finally
        LFrmSehirler.Free;
      end;
    end;
  end;

end;

procedure TfrmChBankaSubesi.RefreshData();
begin
  edtbanka_id.Text := TChBankaSubesi(Table).Banka.AsString;
  edtsube_kodu.Text := TChBankaSubesi(Table).SubeKodu.AsString;
  edtsube_adi.Text := TChBankaSubesi(Table).SubeAdi.AsString;
  edtsehir_id.Text := TChBankaSubesi(Table).Sehir.AsString;
end;

procedure TfrmChBankaSubesi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBankaSubesi(Table).Banka.Value := edtbanka_id.Text;
      TChBankaSubesi(Table).SubeKodu.Value := StrToIntDef(edtsube_kodu.Text, 0);
      TChBankaSubesi(Table).SubeAdi.Value := edtsube_adi.Text;
      TChBankaSubesi(Table).Sehir.Value := edtsehir_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
