unit ufrmBbkBolgeSehir;

interface

{$I ThsERP.inc}

uses
    Windows
  , Messages
  , SysUtils
  , Variants
  , Classes
  , Graphics
  , Controls
  , Forms
  , Dialogs
  , StdCtrls
  , ExtCtrls
  , ComCtrls
  , StrUtils
  , DateUtils
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin
  , Vcl.ExtDlgs

  , FireDAC.Comp.Client

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , ufrmBaseInputDB
  ;

type
  TfrmBbkBolgeSehir = class(TfrmBaseInputDB)
    lblsehir_id: TLabel;
    edtsehir_id: TEdit;
    lblbolge_id: TLabel;
    edtbolge_id: TEdit;
  protected
    procedure HelperProcess(Sender: TObject); override;
  published
    procedure btnAcceptClick(Sender: TObject);override;
    procedure FormCreate(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

uses
    Ths.Erp.Globals
  , Ths.Erp.Database.Table.BbkBolgeSehir
  , Ths.Erp.Database.Table.SysSehir
  , ufrmSysSehirler
  , Ths.Erp.Database.Table.SetBbkBolge
  , ufrmSetBbkBolgeler
  ;

procedure TfrmBbkBolgeSehir.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      TBbkBolgeSehir(Table).Sehir.Value := edtsehir_id.Text;
      TBbkBolgeSehir(Table).Bolge.Value := edtbolge_id.Text;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmBbkBolgeSehir.FormCreate(Sender: TObject);
begin
  inherited;
  edtsehir_id.OnHelperProcess := HelperProcess;
  edtbolge_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmBbkBolgeSehir.HelperProcess(Sender: TObject);
var
  LFrmCity: TfrmSysSehirler;
  LFrmBolge: TfrmSetBbkBolgeler;
begin
  if Sender.ClassType = TEdit then
  begin
    if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
    begin
      if TEdit(Sender).Name = edtsehir_id.Name then
      begin
        LFrmCity := TfrmSysSehirler.Create(TEdit(Sender), Self, TSysSehir.Create(Table.Database), fomNormal, True);
        try
          LFrmCity.ShowModal;
          if LFrmCity.CleanAndClose then
          begin
            TBbkBolgeSehir(Table).SehirID.Value := 0;
            edtsehir_id.Clear;
          end
          else
          begin
            TBbkBolgeSehir(Table).SehirID.Value := TSysSehir(LFrmCity.Table).Id.Value;
            edtsehir_id.Text := FormatedVariantVal(TSysSehir(LFrmCity.Table).SehirAdi);
          end;
        finally
          LFrmCity.Free;
        end;
      end
      else
      if TEdit(Sender).Name = edtbolge_id.Name then
      begin
        LFrmBolge := TfrmSetBbkBolgeler.Create(TEdit(Sender), Self, TSetBbkBolge.Create(Table.Database), fomNormal, True);
        try
          LFrmBolge.ShowModal;
          if LFrmBolge.CleanAndClose then
          begin
            TBbkBolgeSehir(Table).BolgeID.Value := 0;
            edtbolge_id.Clear;
          end
          else
          begin
            TBbkBolgeSehir(Table).BolgeID.Value := TSetBbkBolge(LFrmBolge.Table).Id.Value;
            edtbolge_id.Text := FormatedVariantVal(TSetBbkBolge(LFrmBolge.Table).Bolge);
          end;
        finally
          LFrmBolge.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrmBbkBolgeSehir.RefreshData;
begin
  edtsehir_id.Text := FormatedVariantVal(TBbkBolgeSehir(Table).Sehir);
  edtbolge_id.Text := FormatedVariantVal(TBbkBolgeSehir(Table).Bolge);
end;

end.
