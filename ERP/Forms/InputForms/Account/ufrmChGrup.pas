unit ufrmChGrup;

interface

{$I Ths.inc}

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
  Ths.Helper.Edit,
  Ths.Helper.Memo,
  Ths.Helper.ComboBox,
  ufrmBase,
  ufrmBaseInputDB;

type
  TfrmChGrup = class(TfrmBaseInputDB)
    edtgrup: TEdit;
    lblgrup: TLabel;
    procedure btnAcceptClick(Sender: TObject);override;
  private
  public
  protected
  published
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Database.Table.ChGruplar;

{$R *.dfm}

procedure TfrmChGrup.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChGrup(Table).Grup.Value := edtGrup.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmChGrup.RefreshData;
begin
  edtGrup.Text := TChGrup(Table).Grup.Value;
end;

end.
