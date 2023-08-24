unit ufrmSetPrsBirim;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB,
  ufrmSetPrsBolumler, Ths.Database.Table.SetPrsBolumler,
  Ths.Database.Table.SetPrsBirimler;

type
  TfrmSetPrsBirim = class(TfrmBaseInputDB)
    lblbolum_id: TLabel;
    edtbolum_id: TEdit;
    lblbirim: TLabel;
    edtbirim: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
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
  LPrsBolum: TSetPrsBolum;
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender is TEdit then
    begin
      if TEdit(Sender).Name = edtbolum_id.Name then
      begin
        LPrsBolum := TSetPrsBolum.Create(Table.Database);
        LFrmSection := TfrmSetPrsBolumler.Create(TEdit(Sender), Self, LPrsBolum, fomNormal, True);
        try
          LFrmSection.ShowModal;
          if LFrmSection.DataAktar then
          begin
            if LFrmSection.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSetPrsBirim(Table).BolumID.Value := 0;
            end
            else
            begin
              TEdit(Sender).Text := LPrsBolum.Bolum.AsString;
              TSetPrsBirim(Table).BolumID.Value := LPrsBolum.Id.AsInt64;
            end;
          end;
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
  edtbolum_id.Text := TSetPrsBirim(Table).Bolum.AsString;
  edtbirim.Text := TSetPrsBirim(Table).Birim.AsString;
end;

procedure TfrmSetPrsBirim.btnAcceptClick(Sender: TObject);
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
