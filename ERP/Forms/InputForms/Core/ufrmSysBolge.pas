unit ufrmSysBolge;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Math, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts, Vcl.Menus,
  Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo,
  Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB;

type
  TfrmSysBolge = class(TfrmBaseInputDB)
    lblbolge: TLabel;
    edtbolge: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.SysBolgeler;

{$R *.dfm}

procedure TfrmSysBolge.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysBolge(Table).Bolge.Value := edtbolge.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysBolge.RefreshData;
begin
  edtbolge.Text := TSysBolge(Table).Bolge.AsString;
end;

end.
