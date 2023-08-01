unit ufrmSetEmpUnit;

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
  ufrmBaseInputDB,
  ufrmSetEmpSections,
  Ths.Database.Table.SetPrsBolumler,
  Ths.Database.Table.SetPrsBirimler;

type
  TfrmSetEmpUnit = class(TfrmBaseInputDB)
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

procedure TfrmSetEmpUnit.FormShow(Sender: TObject);
begin
  edtbolum_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSetEmpUnit.HelperProcess(Sender: TObject);
var
  LFrmSection: TfrmSetEmpSections;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender is TEdit then
    begin
      if TEdit(Sender).Name = edtbolum_id.Name then
      begin
        LFrmSection := TfrmSetEmpSections.Create(TEdit(Sender), Self, TSetPrsBolum.Create(Table.Database), fomNormal, True);
        try
          LFrmSection.ShowModal;
        finally
          LFrmSection.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmSetEmpUnit.RefreshData;
begin
  inherited;
  edtbolum_id.Text := TSetPrsBirim(Table).Bolum.Value;
end;

procedure TfrmSetEmpUnit.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetPrsBirim(Table).Bolum.Value := edtbolum_id.Text;
      TSetPrsBirim(Table).Birim.Value := edtbirim.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

end.
