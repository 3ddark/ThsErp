unit ufrmSysSehir;

interface

{$I Ths.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.StrUtils, System.Math, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.AppEvnts,
  Vcl.Menus, Vcl.Samples.Spin, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.Memo, Ths.Helper.ComboBox, ufrmBase, ufrmBaseInputDB, Ths.Globals,
  Ths.Database.Table;

type
  TfrmSysSehir = class(TfrmBaseInputDB)
    lblulke_id: TLabel;
    lblsehir: TLabel;
    lblplaka_kodu: TLabel;
    edtsehir: TEdit;
    edtplaka_kodu: TEdit;
    edtulke_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Database.Table.SysSehirler,
  Ths.Database.Table.SysUlkeler{,
  ufrmSysUlkeler};

{$R *.dfm}

procedure TfrmSysSehir.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TSysSehir(Table).Sehir.Value := edtsehir.Text;
      TSysSehir(Table).PlakaKodu.Value := edtplaka_kodu.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmSysSehir.FormShow(Sender: TObject);
begin
  edtulke_id.OnHelperProcess := HelperProcess;
  inherited;
end;

procedure TfrmSysSehir.HelperProcess(Sender: TObject);
//var
//  LFrm: TfrmSysUlkeler;
begin
{  if (FormMode = ifmNewRecord) or (FormMode = ifmUpdate) then
  begin
    if Sender.ClassType = TEdit then
    begin
      if TEdit(Sender).Name = edtulke_id.Name then
      begin
        LFrm := TfrmSysUlkeler.Create(TEdit(Sender), Self, TSysUlke.Create(Table.Database), fomNormal, True);
        try
          LFrm.ShowModal;
          if LFrm.DataAktar then
          begin
            if LFrm.CleanAndClose then
            begin
              TEdit(Sender).Clear;
              TSysSehir(Table).UlkeID.Value := 0;
            end
            else
            begin
              TSysSehir(Table).UlkeID.Value := LFrm.Table.Id.Value;
              TEdit(Sender).Text := TSysUlke(LFrm.Table).UlkeAdi.AsString;
            end;
          end;
        finally
          LFrm.Free;
        end;
      end
    end;
  end;}
end;

procedure TfrmSysSehir.RefreshData;
begin
  inherited;
  edtulke_id.Text := TSysSehir(Table).UlkeAdi.Value;
  edtsehir.Text := TSysSehir(Table).Sehir.Value;
  edtplaka_kodu.Text := TSysSehir(Table).PlakaKodu.Value;
end;

end.
