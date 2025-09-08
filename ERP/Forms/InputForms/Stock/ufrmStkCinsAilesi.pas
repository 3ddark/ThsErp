unit ufrmStkCinsAilesi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.AppEvnts, Vcl.Samples.Spin,
  Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB, Vcl.Menus;

type
  TfrmStkCinsAilesi = class(TfrmBaseInputDB)
    edtfamily: TEdit;
    lblfamily: TLabel;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  StkKindFamily;

{$R *.dfm}

procedure TfrmStkCinsAilesi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkCinsAile(Table).Family.Value := edtfamily.Text;
      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkCinsAilesi.RefreshData;
begin
  edtfamily.Text := TStkCinsAile(Table).Family.Value;
end;

end.

