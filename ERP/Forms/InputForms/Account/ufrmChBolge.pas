unit ufrmChBolge;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus,
  Vcl.AppEvnts, System.ImageList, Vcl.ImgList, Vcl.Samples.Spin,
  Ths.Helper.BaseTypes,
  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,
  ufrmBase, ufrmBaseInputDB,
  Ths.Database.Table,
  Ths.Database.Table.ChBolgeler,
  Ths.Globals;

type
  TfrmChBolge = class(TfrmBaseInputDB)
    lblbolge: TLabel;
    edtbolge: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmChBolge.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TChBolge(Table).Bolge.Value := edtbolge.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmChBolge.RefreshData;
begin
  edtbolge.Text := TChBolge(Table).Bolge.AsString;
end;

end.
