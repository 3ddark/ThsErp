unit ufrmSysUygulamaAyariDiger;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.AppEvnts,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSysUygulamaAyariDiger = class(TfrmBaseInputDB)
    lblis_edefter_aktif: TLabel;
    chkis_edefter_aktif: TCheckBox;
    lblis_efatura_aktif: TLabel;
    chkis_efatura_aktif: TCheckBox;
    lblis_eirsaliye_aktif: TLabel;
    chkis_eirsaliye_aktif: TCheckBox;
    lblpath_stok_resim: TLabel;
    edtpath_stok_resim: TEdit;
    btnpath_stok_resim: TButton;
    lblpath_guncelleme: TLabel;
    edtpath_guncelleme: TEdit;
    btnpath_guncelleme: TButton;
    lblpath_utd: TLabel;
    edtpath_utd: TEdit;
    btnpath_utd: TButton;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure btnpath_stok_resimClick(Sender: TObject);
    procedure FormCreate(Sender: TObject); override;
    procedure btnpath_guncellemeClick(Sender: TObject);
    procedure btnpath_utdClick(Sender: TObject);
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure Repaint; override;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SysUygulamaAyariDiger;

{$R *.dfm}

procedure TfrmSysUygulamaAyariDiger.btnpath_stok_resimClick(Sender: TObject);
begin
  edtpath_stok_resim.Text := GetDialogDirectory;
end;

procedure TfrmSysUygulamaAyariDiger.btnpath_guncellemeClick(Sender: TObject);
begin
  edtpath_guncelleme.Text := GetDialogDirectory;
end;

procedure TfrmSysUygulamaAyariDiger.btnpath_utdClick(Sender: TObject);
begin
  edtpath_utd.Text := GetDialogDirectory;
end;

procedure TfrmSysUygulamaAyariDiger.FormCreate(Sender: TObject);
begin
  inherited;

  edtpath_stok_resim.CharCase := ecNormal;
  edtpath_guncelleme.CharCase := ecNormal;
  edtpath_utd.CharCase := ecNormal;
end;

procedure TfrmSysUygulamaAyariDiger.RefreshData();
begin
  edtpath_guncelleme.Text := FormatedVariantVal(TSysUygulamaAyariDiger(Table).PathUpdate);
  edtpath_utd.Text := FormatedVariantVal(TSysUygulamaAyariDiger(Table).PathUTD);
end;

procedure TfrmSysUygulamaAyariDiger.Repaint;
begin
  inherited;
  edtpath_stok_resim.ReadOnly := True;
  edtpath_guncelleme.ReadOnly := True;
  edtpath_utd.ReadOnly := True;

  btnpath_stok_resim.Enabled := False;
  btnpath_guncelleme.Enabled := False;
  btnpath_utd.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stok_resim.Enabled := True;
    btnpath_guncelleme.Enabled := True;
    btnpath_utd.Enabled := True;
  end;
end;

function TfrmSysUygulamaAyariDiger.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if not DirectoryExists(edtpath_stok_resim.Text) then
  begin
    edtpath_stok_resim.SetFocus;
    CreateExceptionByLang('Lütfen geçerli bir dosya yolu giriniz!', '999999', '1');
  end;

  if not DirectoryExists(edtpath_guncelleme.Text) then
  begin
    edtpath_guncelleme.SetFocus;
    CreateExceptionByLang('Lütfen geçerli bir dosya yolu giriniz!', '999999', '1');
  end;

  if not DirectoryExists(edtpath_utd.Text) then
  begin
    edtpath_utd.SetFocus;
    CreateExceptionByLang('Lütfen geçerli bir dosya yolu giriniz!', '999999', '1');
  end;
end;

procedure TfrmSysUygulamaAyariDiger.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysUygulamaAyariDiger(Table).PathUpdate.Value := edtpath_guncelleme.Text;
      TSysUygulamaAyariDiger(Table).PathUTD.Value := edtpath_utd.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
