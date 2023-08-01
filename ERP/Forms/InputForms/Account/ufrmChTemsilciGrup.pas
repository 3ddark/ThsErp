unit ufrmChTemsilciGrup;

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChTemsilciGrup,
  Ths.Erp.Database.Table.ChTemsilciGrupTuru;

type
  TfrmChTemsilciGrup = class(TfrmBaseInputDB)
    lbltemsilci_grup_turu_id: TLabel;
    cbbtemsilci_grup_turu_id: TComboBox;
    lbltemsilci_grup: TLabel;
    edttemsilci_grup: TEdit;
    procedure btnAcceptClick(Sender: TObject);override;
  private
    FTemsilciGrupTuru: TChTemsilciGrupTuru;
  public
  protected
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmChTemsilciGrup.btnAcceptClick(Sender: TObject);
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

procedure TfrmChTemsilciGrup.FormCreate(Sender: TObject);
begin
  inherited;
  FTemsilciGrupTuru := TChTemsilciGrupTuru.Create(Table.Database);
  FTemsilciGrupTuru.SelectToList('', False, False);
  fillComboBoxData(cbbtemsilci_grup_turu_id, FTemsilciGrupTuru, [FTemsilciGrupTuru.TemsilciGrupTuru.FieldName], '', True);
end;

procedure TfrmChTemsilciGrup.FormDestroy(Sender: TObject);
begin
  FTemsilciGrupTuru.Free;
  inherited;
end;

end.
