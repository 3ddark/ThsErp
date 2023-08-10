unit ufrmStkCinsOzelligi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts,

  Ths.Helper.Edit,
  Ths.Helper.ComboBox,
  Ths.Helper.Memo,

  ufrmBase, ufrmBaseInputDB;

type
  TfrmStkCinsOzelligi = class(TfrmBaseInputDB)
    lblcins: TLabel;
    edtcins: TEdit;
    lblaciklama: TLabel;
    edtaciklama: TEdit;
    lbls1: TLabel;
    edts1: TEdit;
    lbls2: TLabel;
    edts2: TEdit;
    lbls3: TLabel;
    edts3: TEdit;
    lbls4: TLabel;
    edts4: TEdit;
    lbls5: TLabel;
    edts5: TEdit;
    lbls6: TLabel;
    edts6: TEdit;
    lbls7: TLabel;
    edts7: TEdit;
    lbls8: TLabel;
    edts8: TEdit;
    lbli1: TLabel;
    edti1: TEdit;
    lbli2: TLabel;
    edti2: TEdit;
    lbli3: TLabel;
    edti3: TEdit;
    lbli4: TLabel;
    edti4: TEdit;
    lbld1: TLabel;
    lbld2: TLabel;
    lbld3: TLabel;
    lbld4: TLabel;
    edtd1: TEdit;
    edtd2: TEdit;
    edtd3: TEdit;
    edtd4: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table.StkCinsOzellikleri;

{$R *.dfm}

procedure TfrmStkCinsOzelligi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkCinsOzelligi(Table).Cins.Value := edtcins.Text;
      TStkCinsOzelligi(Table).Aciklama.Value := edtaciklama.Text;
      TStkCinsOzelligi(Table).S1.Value := edts1.Text;
      TStkCinsOzelligi(Table).S2.Value := edts2.Text;
      TStkCinsOzelligi(Table).S3.Value := edts3.Text;
      TStkCinsOzelligi(Table).S4.Value := edts4.Text;
      TStkCinsOzelligi(Table).S5.Value := edts5.Text;
      TStkCinsOzelligi(Table).S6.Value := edts6.Text;
      TStkCinsOzelligi(Table).S7.Value := edts7.Text;
      TStkCinsOzelligi(Table).S8.Value := edts8.Text;
      TStkCinsOzelligi(Table).I1.Value := edti1.Text;
      TStkCinsOzelligi(Table).I2.Value := edti2.Text;
      TStkCinsOzelligi(Table).I3.Value := edti3.Text;
      TStkCinsOzelligi(Table).I4.Value := edti4.Text;
      TStkCinsOzelligi(Table).D1.Value := edtd1.Text;
      TStkCinsOzelligi(Table).D2.Value := edtd2.Text;
      TStkCinsOzelligi(Table).D3.Value := edtd3.Text;
      TStkCinsOzelligi(Table).D4.Value := edtd4.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkCinsOzelligi.RefreshData;
begin
  edtcins.Text := TStkCinsOzelligi(Table).Cins.AsString;
  edtaciklama.Text := TStkCinsOzelligi(Table).Aciklama.AsString;
  edts1.Text := TStkCinsOzelligi(Table).S1.AsString;
  edts2.Text := TStkCinsOzelligi(Table).S2.AsString;
  edts3.Text := TStkCinsOzelligi(Table).S3.AsString;
  edts4.Text := TStkCinsOzelligi(Table).S4.AsString;
  edts5.Text := TStkCinsOzelligi(Table).S5.AsString;
  edts6.Text := TStkCinsOzelligi(Table).S6.AsString;
  edts7.Text := TStkCinsOzelligi(Table).S7.AsString;
  edts8.Text := TStkCinsOzelligi(Table).S8.AsString;
  edti1.Text := TStkCinsOzelligi(Table).I1.AsString;
  edti2.Text := TStkCinsOzelligi(Table).I2.AsString;
  edti3.Text := TStkCinsOzelligi(Table).I3.AsString;
  edti4.Text := TStkCinsOzelligi(Table).I4.AsString;
  edtd1.Text := TStkCinsOzelligi(Table).D1.AsString;
  edtd2.Text := TStkCinsOzelligi(Table).D2.AsString;
  edtd3.Text := TStkCinsOzelligi(Table).D3.AsString;
  edtd4.Text := TStkCinsOzelligi(Table).D4.AsString;
end;

end.
