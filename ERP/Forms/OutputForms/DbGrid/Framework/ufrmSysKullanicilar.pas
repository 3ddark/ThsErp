unit ufrmSysKullanicilar;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.ImgList,
  Vcl.Samples.Spin,
  Vcl.StdCtrls,
  Vcl.Grids,
  Vcl.Dialogs,
  Data.DB,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Intf,
  FireDAC.Comp.Client,
  frxClass,
  frxDBSet,
  frxExportBaseDialog,
  frxExportPDF,
  ufrmBase,
  ufrmBaseDBGrid, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  System.Actions, Vcl.ActnList;

type
  TfrmSysKullanicilar = class(TfrmBaseDBGrid)
    mniCopyAccessRightFromUser: TMenuItem;
    procedure mniCopyAccessRightFromUserClick(Sender: TObject);
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Constants,
  Ths.Erp.Globals,
  ufrmSysKullanici,
  Ths.Erp.Database.Table.SysKullanici;

{$R *.dfm}

function TfrmSysKullanicilar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysKullanici.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysKullanici.Create(Application, Self, TSysKullanici.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysKullanici.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysKullanicilar.FormShow(Sender: TObject);
begin
  inherited;
  if IsHelper then
  begin
    mniCopyAccessRightFromUser.Visible := not IsHelper;
  end;
  mnicopy_record.Visible := True;
end;

procedure TfrmSysKullanicilar.mniCopyAccessRightFromUserClick(Sender: TObject);
var
  LUsr: TSysKullanici;
  LFrm: TfrmSysKullanicilar;
  LFromUser: string;
  LFromUserID: Integer;
begin
  LUsr := TSysKullanici.Create(GDataBase);
  LFrm := TfrmSysKullanicilar.Create(nil, nil, LUsr, fomNormal, True);

  LFrm.QryFiltreVarsayilan :=
    ' AND ' + LUsr.TableName + '.' + LUsr.KullaniciAdi.FieldName + '!=' + QuotedStr(TSysKullanici(Table).KullaniciAdi.Value) +
    ' AND ' + LUsr.TableName + '.' + LUsr.IsAktif.FieldName + '= True';
  LFrm.ShowModal;
  if LFrm.DataAktar then
  begin
    LFromUserID := LUsr.Id.Value;
    LFromUser := LUsr.KullaniciAdi.Value;
    if CustomMsgDlg(
      'Seçilen ' + LFromUser + ' kullanýcýsýnýn haklarý ' + TSysKullanici(Table).KullaniciAdi.Value + ' kullanýcýsýna kopyalanacak.' +
      AddLBs(2) +
      'Ýþleme devam etmek istiyor musun?',

      mtConfirmation, mbYesNo,
      [TranslateText('Yes', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem),
       TranslateText('No', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)],
      mbNo,
      TranslateText('Confirmation', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)
    ) = mrYes
    then
      TSysKullanici(Table).CopyFromRights(LFromUserID, TSysKullanici(Table).Id.Value);
  end;
end;

end.
