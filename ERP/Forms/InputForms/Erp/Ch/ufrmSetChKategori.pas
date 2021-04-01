unit ufrmSetChKategori;

interface

{$I ThsERP.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.StrUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Samples.Spin,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmSetChKategori = class(TfrmBaseInputDB)
    lblrenk: TLabel;
    lblaciklama: TLabel;
    lblkategori: TLabel;
    edtkategori: TEdit;
    edtaciklama: TEdit;
    edtrenk: TEdit;
    procedure RefreshData();override;
    procedure btnAcceptClick(Sender: TObject);override;
    procedure edtrenkDblClick(Sender: TObject);
  private
    procedure SetColor(color: TColor; editColor: TEdit);
  public
    destructor Destroy; override;
    procedure Repaint; override;
  protected
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SetChKategori
  ;

{$R *.dfm}

destructor TfrmSetChKategori.Destroy;
begin
  inherited;
end;

procedure TfrmSetChKategori.edtrenkDblClick(Sender: TObject);
begin
  SetColor(GetDialogColor(StrToIntDef(edtrenk.Text, 0)), edtrenk);
end;

procedure TfrmSetChKategori.FormShow(Sender: TObject);
begin
  inherited;
end;

procedure TfrmSetChKategori.RefreshData();
begin
  inherited;
  SetColor(StrToIntDef(edtrenk.Text, 0), edtrenk);
end;

procedure TfrmSetChKategori.Repaint;
begin
  inherited;
  edtrenk.ReadOnly := True;
end;

procedure TfrmSetChKategori.SetColor(color: TColor; editColor: TEdit);
begin
  editColor.Text := IntToStr(color);
  editColor.Color := color;
  editColor.thsColorActive := color;
  editColor.thsColorRequiredInput := color;
  editColor.Repaint;
end;

procedure TfrmSetChKategori.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
