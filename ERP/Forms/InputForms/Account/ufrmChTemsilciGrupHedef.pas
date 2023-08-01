unit ufrmChTemsilciGrupHedef;

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
  ufrmBaseInputDB,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.ChTemsilciGrup,
  Ths.Erp.Database.Table.ChTemsilciGrupHedef,
  Ths.Erp.Database.Table.SysParaBirimi;

type
  TfrmChTemsilciGrupHedef = class(TfrmBaseInputDB)
    lbltemsilci_grup_id: TLabel;
    cbbtemsilci_grup_id: TComboBox;
    lblpara_birimi: TLabel;
    cbbpara_birimi: TComboBox;
    lblhedef_ocak: TLabel;
    lblhedef_subat: TLabel;
    lblhedef_mart: TLabel;
    lblhedef_nisan: TLabel;
    lblhedef_mayis: TLabel;
    lblhedef_haziran: TLabel;
    lblhedef_temmuz: TLabel;
    lblhedef_agustos: TLabel;
    lblhedef_aralik: TLabel;
    lblhedef_kasim: TLabel;
    lblhedef_ekim: TLabel;
    lblhedef_eylul: TLabel;
    lblhedefler: TLabel;
    lblhedef_mamul: TLabel;
    lblhedef_tumu: TLabel;
    lblgecen_ocak: TLabel;
    lblgecen_subat: TLabel;
    lblgecen_mart: TLabel;
    lblgecen_nisan: TLabel;
    lblgecen_mayis: TLabel;
    lblgecen_haziran: TLabel;
    lblgecen_temmuz: TLabel;
    lblgecen_agustos: TLabel;
    lblgecen_aralik: TLabel;
    lblgecen_kasim: TLabel;
    lblgecen_ekim: TLabel;
    lblgecen_eylul: TLabel;
    lblonceki_donem: TLabel;
    lblonceki_mamul: TLabel;
    lblonceki_tumu: TLabel;
    edthedef_ocak: TEdit;
    edthedef_ham_ocak: TEdit;
    edthedef_subat: TEdit;
    edthedef_ham_subat: TEdit;
    edthedef_mart: TEdit;
    edthedef_ham_mart: TEdit;
    edthedef_nisan: TEdit;
    edthedef_ham_nisan: TEdit;
    edthedef_mayis: TEdit;
    edthedef_ham_mayis: TEdit;
    edthedef_haziran: TEdit;
    edthedef_ham_haziran: TEdit;
    edthedef_temmuz: TEdit;
    edthedef_ham_temmuz: TEdit;
    edthedef_agustos: TEdit;
    edthedef_ham_agustos: TEdit;
    edthedef_eylul: TEdit;
    edthedef_ham_eylul: TEdit;
    edthedef_ekim: TEdit;
    edthedef_ham_ekim: TEdit;
    edthedef_kasim: TEdit;
    edthedef_ham_kasim: TEdit;
    edthedef_aralik: TEdit;
    edthedef_ham_aralik: TEdit;
    edtgecen_ocak: TEdit;
    edtgecen_ham_ocak: TEdit;
    edtgecen_subat: TEdit;
    edtgecen_ham_subat: TEdit;
    edtgecen_mart: TEdit;
    edtgecen_ham_mart: TEdit;
    edtgecen_nisan: TEdit;
    edtgecen_ham_nisan: TEdit;
    edtgecen_mayis: TEdit;
    edtgecen_ham_mayis: TEdit;
    edtgecen_haziran: TEdit;
    edtgecen_ham_haziran: TEdit;
    edtgecen_temmuz: TEdit;
    edtgecen_ham_temmuz: TEdit;
    edtgecen_agustos: TEdit;
    edtgecen_ham_agustos: TEdit;
    edtgecen_eylul: TEdit;
    edtgecen_ham_eylul: TEdit;
    edtgecen_ekim: TEdit;
    edtgecen_ham_ekim: TEdit;
    edtgecen_kasim: TEdit;
    edtgecen_ham_kasim: TEdit;
    edtgecen_aralik: TEdit;
    edtgecen_ham_aralik: TEdit;
    procedure btnAcceptClick(Sender: TObject);override;
  private
    FTemsilciGrup: TChTemsilciGrup;
    FPara: TSysParaBirimi;
  public
  protected
  published
    procedure FormCreate(Sender: TObject); override;
    procedure FormDestroy(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

{$R *.dfm}

procedure TfrmChTemsilciGrupHedef.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if (ValidateInput) then
    begin
      btnAcceptAuto;

      inherited;
    end;
  end
  else
    inherited;
end;

procedure TfrmChTemsilciGrupHedef.FormCreate(Sender: TObject);
begin
  inherited;
  FTemsilciGrup := TChTemsilciGrup.Create(Table.Database);
  FPara := TSysParaBirimi.Create(Table.Database);

  fillComboBoxData(cbbtemsilci_grup_id, FTemsilciGrup, [FTemsilciGrup.TemsilciGrup.FieldName], '', True);
  fillComboBoxData(cbbpara_birimi, FPara, [FPara.ParaBirimi.FieldName], '', False);
end;

procedure TfrmChTemsilciGrupHedef.FormDestroy(Sender: TObject);
begin
  FTemsilciGrup.Free;
  FPara.Free;
  inherited;
end;

procedure TfrmChTemsilciGrupHedef.FormShow(Sender: TObject);
begin
  inherited;
  {$IFDEF DUMMY_VALUE}
    if FormMode = ifmNewRecord then
    begin
      edthedef_ocak.Text := '100000';
      edthedef_subat.Text := '100000';
      edthedef_mart.Text := '100000';
      edthedef_nisan.Text := '100000';
      edthedef_mayis.Text := '100000';
      edthedef_haziran.Text := '100000';
      edthedef_temmuz.Text := '100000';
      edthedef_agustos.Text := '100000';
      edthedef_eylul.Text := '100000';
      edthedef_ekim.Text := '100000';
      edthedef_kasim.Text := '100000';
      edthedef_aralik.Text := '100000';

      edthedef_ham_ocak.Text := '80000';
      edthedef_ham_subat.Text := '80000';
      edthedef_ham_mart.Text := '90000';
      edthedef_ham_nisan.Text := '90000';
      edthedef_ham_mayis.Text := '90000';
      edthedef_ham_haziran.Text := '70000';
      edthedef_ham_temmuz.Text := '70000';
      edthedef_ham_agustos.Text := '70000';
      edthedef_ham_eylul.Text := '70000';
      edthedef_ham_ekim.Text := '70000';
      edthedef_ham_kasim.Text := '80000';
      edthedef_ham_aralik.Text := '80000';

      edtgecen_ocak.Text := '900000';
      edtgecen_subat.Text := '900000';
      edtgecen_mart.Text := '900000';
      edtgecen_nisan.Text := '900000';
      edtgecen_mayis.Text := '900000';
      edtgecen_haziran.Text := '900000';
      edtgecen_temmuz.Text := '900000';
      edtgecen_agustos.Text := '900000';
      edtgecen_eylul.Text := '900000';
      edtgecen_ekim.Text := '900000';
      edtgecen_kasim.Text := '900000';
      edtgecen_aralik.Text := '900000';

      edtgecen_ham_ocak.Text := '500000';
      edtgecen_ham_subat.Text := '500000';
      edtgecen_ham_mart.Text := '500000';
      edtgecen_ham_nisan.Text := '500000';
      edtgecen_ham_mayis.Text := '500000';
      edtgecen_ham_haziran.Text := '600000';
      edtgecen_ham_temmuz.Text := '600000';
      edtgecen_ham_agustos.Text := '600000';
      edtgecen_ham_eylul.Text := '600000';
      edtgecen_ham_ekim.Text := '600000';
      edtgecen_ham_kasim.Text := '600000';
      edtgecen_ham_aralik.Text := '600000';
    end;
  {$ENDIF}

end;

end.
