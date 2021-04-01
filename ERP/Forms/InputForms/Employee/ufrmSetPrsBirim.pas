unit ufrmSetPrsBirim;

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
  ufrmBaseInputDB,
  ufrmSetPrsBolumler,
  Ths.Erp.Database.Table.SetPrsBolum,
  Ths.Erp.Database.Table.SetPrsBirim;

type
  TfrmSetPrsBirim = class(TfrmBaseInputDB)
    lblbolum_id: TLabel;
    edtbolum_id: TEdit;
    lblbirim: TLabel;
    edtbirim: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSetPrsBirim.FormShow(Sender: TObject);
begin
  edtbolum_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSetPrsBirim.HelperProcess(Sender: TObject);
var
  LFrmSection: TfrmSetPrsBolumler;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender is TEdit then
    begin
      if TEdit(Sender).Name = edtbolum_id.Name then
      begin
        LFrmSection := TfrmSetPrsBolumler.Create(TEdit(Sender), Self, TSetPrsBolum.Create(Table.Database), fomNormal, True);
        try
          LFrmSection.ShowModal;
        finally
          LFrmSection.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmSetPrsBirim.RefreshData;
begin
  inherited;
  edtbolum_id.Text := TSetPrsBirim(Table).Bolum.Value;
end;

procedure TfrmSetPrsBirim.btnAcceptClick(Sender: TObject);
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
