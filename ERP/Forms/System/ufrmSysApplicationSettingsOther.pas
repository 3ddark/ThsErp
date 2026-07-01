unit ufrmSysApplicationSettingsOther;

interface

{$I Ths.inc}

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
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSysApplicationSettingsOther = class(TfrmBaseInputDB)
    lblpath_stock_image: TLabel;
    edtpath_stock_image: TEdit;
    btnpath_stock_image: TButton;
    lblpath_update: TLabel;
    edtpath_update: TEdit;
    btnpath_update: TButton;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure btnpath_stock_imageClick(Sender: TObject);
    procedure FormCreate(Sender: TObject); override;
    procedure btnpath_updateClick(Sender: TObject);
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean; override;
  published
    procedure Repaint; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.SysApplicationSettingsOther;

{$R *.dfm}

procedure TfrmSysApplicationSettingsOther.btnpath_stock_imageClick(Sender: TObject);
begin
  edtpath_stock_image.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSettingsOther.btnpath_updateClick(Sender: TObject);
begin
  edtpath_update.Text := GetDialogDirectory;
end;

procedure TfrmSysApplicationSettingsOther.FormCreate(Sender: TObject);
begin
  inherited;

  edtpath_stock_image.CharCase := ecNormal;
  edtpath_update.CharCase := ecNormal;
end;

procedure TfrmSysApplicationSettingsOther.RefreshData();
begin
  edtpath_stock_image.Text := TSysApplicationSettingsOther(Table).PathUpdate.AsString;
  edtpath_update.Text := TSysApplicationSettingsOther(Table).PathStockImage.AsString;
end;

procedure TfrmSysApplicationSettingsOther.Repaint;
begin
  inherited;
  edtpath_stock_image.ReadOnly := True;
  edtpath_update.ReadOnly := True;

  btnpath_stock_image.Enabled := False;
  btnpath_update.Enabled := False;

  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    btnpath_stock_image.Enabled := True;
    btnpath_update.Enabled := True;
  end;
end;

function TfrmSysApplicationSettingsOther.ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput(panel_groupbox_pagecontrol_tabsheet);

  if not DirectoryExists(edtpath_stock_image.Text) then
  begin
    edtpath_stock_image.SetFocus;
    CreateExceptionByLang('Please select a valid directory!', '999999', '1');
  end;

  if not DirectoryExists(edtpath_update.Text) then
  begin
    edtpath_update.SetFocus;
    CreateExceptionByLang('Please select a valid directory!', '999999', '1');
  end;
end;

procedure TfrmSysApplicationSettingsOther.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysApplicationSettingsOther(Table).PathUpdate.Value := edtpath_update.Text;
      TSysApplicationSettingsOther(Table).PathStockImage.Value := edtpath_stock_image.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

end.
