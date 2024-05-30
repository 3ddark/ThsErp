unit ufrmStkCinsOzelligi;

interface

{$I Ths.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Vcl.Menus, Vcl.Samples.Spin,
  Vcl.AppEvnts, Ths.Helper.Edit, Ths.Helper.ComboBox, Ths.Helper.Memo, ufrmBase,
  ufrmBaseInputDB;

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
    lbls9: TLabel;
    lbls10: TLabel;
    edts9: TEdit;
    edts10: TEdit;
    lbli1: TLabel;
    lbli2: TLabel;
    lbli3: TLabel;
    lbli4: TLabel;
    edti1: TEdit;
    edti2: TEdit;
    edti3: TEdit;
    edti4: TEdit;
    lbli5: TLabel;
    edti5: TEdit;
    lbld1: TLabel;
    lbld2: TLabel;
    lbld3: TLabel;
    lbld4: TLabel;
    edtd1: TEdit;
    edtd2: TEdit;
    edtd3: TEdit;
    edtd4: TEdit;
    lbld5: TLabel;
    edtd5: TEdit;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table.StkCinsOzellikleri;

{$R *.dfm}

procedure TfrmStkCinsOzelligi.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TStkCinsOzellik(Table).Cins.Value := edtcins.Text;
      TStkCinsOzellik(Table).Aciklama.Value := edtaciklama.Text;
      TStkCinsOzellik(Table).S1.Value := edts1.Text;
      TStkCinsOzellik(Table).S2.Value := edts2.Text;
      TStkCinsOzellik(Table).S3.Value := edts3.Text;
      TStkCinsOzellik(Table).S4.Value := edts4.Text;
      TStkCinsOzellik(Table).S5.Value := edts5.Text;
      TStkCinsOzellik(Table).S6.Value := edts6.Text;
      TStkCinsOzellik(Table).S7.Value := edts7.Text;
      TStkCinsOzellik(Table).S8.Value := edts8.Text;
      TStkCinsOzellik(Table).S9.Value := edts9.Text;
      TStkCinsOzellik(Table).S10.Value := edts10.Text;
      TStkCinsOzellik(Table).I1.Value := edti1.Text;
      TStkCinsOzellik(Table).I2.Value := edti2.Text;
      TStkCinsOzellik(Table).I3.Value := edti3.Text;
      TStkCinsOzellik(Table).I4.Value := edti4.Text;
      TStkCinsOzellik(Table).I5.Value := edti5.Text;
      TStkCinsOzellik(Table).D1.Value := edtd1.Text;
      TStkCinsOzellik(Table).D2.Value := edtd2.Text;
      TStkCinsOzellik(Table).D3.Value := edtd3.Text;
      TStkCinsOzellik(Table).D4.Value := edtd4.Text;
      TStkCinsOzellik(Table).D5.Value := edtd5.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmStkCinsOzelligi.RefreshData;
begin
  edtcins.Text := TStkCinsOzellik(Table).Cins.AsString;
  edtaciklama.Text := TStkCinsOzellik(Table).Aciklama.AsString;
  edts1.Text := TStkCinsOzellik(Table).S1.AsString;
  edts2.Text := TStkCinsOzellik(Table).S2.AsString;
  edts3.Text := TStkCinsOzellik(Table).S3.AsString;
  edts4.Text := TStkCinsOzellik(Table).S4.AsString;
  edts5.Text := TStkCinsOzellik(Table).S5.AsString;
  edts6.Text := TStkCinsOzellik(Table).S6.AsString;
  edts7.Text := TStkCinsOzellik(Table).S7.AsString;
  edts8.Text := TStkCinsOzellik(Table).S8.AsString;
  edts9.Text := TStkCinsOzellik(Table).S9.AsString;
  edts10.Text := TStkCinsOzellik(Table).S10.AsString;
  edti1.Text := TStkCinsOzellik(Table).I1.AsString;
  edti2.Text := TStkCinsOzellik(Table).I2.AsString;
  edti3.Text := TStkCinsOzellik(Table).I3.AsString;
  edti4.Text := TStkCinsOzellik(Table).I4.AsString;
  edti5.Text := TStkCinsOzellik(Table).I5.AsString;
  edtd1.Text := TStkCinsOzellik(Table).D1.AsString;
  edtd2.Text := TStkCinsOzellik(Table).D2.AsString;
  edtd3.Text := TStkCinsOzellik(Table).D3.AsString;
  edtd4.Text := TStkCinsOzellik(Table).D4.AsString;
  edtd5.Text := TStkCinsOzellik(Table).D5.AsString;
end;

end.

