unit ufrmSetChGrup;

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
  TfrmSetChGrup = class(TfrmBaseInputDB)
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
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.SetChGrup;

{$R *.dfm}

procedure TfrmSetChGrup.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSetChGrup(Table).Grup.Value := edtGrup.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSetChGrup.RefreshData;
begin
  edtGrup.Text := TSetChGrup(Table).Grup.Value;
end;

end.
