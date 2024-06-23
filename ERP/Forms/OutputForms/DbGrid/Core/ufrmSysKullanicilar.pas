unit ufrmSysKullanicilar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.Controls, Vcl.Forms,
  Vcl.DBGrids, Vcl.Menus, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ImgList,
  Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Grids, Vcl.Dialogs, Data.DB,
  System.Actions, Vcl.ActnList, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  ufrmBase, ufrmBaseDBGrid, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt;

type
  TfrmSysKullanicilar = class(TfrmBaseDBGrid)
    mniCopyAccessRightFromUser: TMenuItem;
    procedure mniCopyAccessRightFromUserClick(Sender: TObject);
  protected
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
  Ths.Constants, Ths.Globals, ufrmSysKullanici,
  Ths.Database.Table.SysKullanicilar;

{$R *.dfm}

function TfrmSysKullanicilar.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (AFormMode = ifmRewiev) then
    Result := TfrmSysKullanici.Create(Application, Self, Table.Clone(), AFormMode)
  else if (AFormMode = ifmNewRecord) then
    Result := TfrmSysKullanici.Create(Application, Self, TSysKullanici.Create(Table.Database), AFormMode)
  else if (AFormMode = ifmCopyNewRecord) then
    Result := TfrmSysKullanici.Create(Application, Self, Table.Clone(), AFormMode);
end;

procedure TfrmSysKullanicilar.FormShow(Sender: TObject);
begin
  inherited;
  if IsHelper then
    mniCopyAccessRightFromUser.Visible := not IsHelper;
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

  LFrm.QryFiltreVarsayilan := ' AND ' + LUsr.KullaniciAdi.FieldName + '<>' + QuotedStr(TSysKullanici(Table).KullaniciAdi.Value) + ' AND ' + LUsr.IsAktif.FieldName + '= True';
  LFrm.ShowModal;
  if LFrm.DataAktar then
  begin
    LFromUserID := LUsr.Id.Value;
    LFromUser := LUsr.KullaniciAdi.Value;
    if CustomMsgDlg('Se�ilen ' + LFromUser + ' kullan�c�s�n�n haklar� ' + TSysKullanici(Table).KullaniciAdi.Value + ' kullan�c�s�na kopyalanacak.' + AddLBs(2) + '��leme devam etmek istiyor musun?', mtConfirmation, mbYesNo, [TranslateText('Yes', FrameworkLang.GeneralYesLower, LngGeneral, LngSystem), TranslateText('No', FrameworkLang.GeneralNoLower, LngGeneral, LngSystem)], mbNo, TranslateText('Confirmation', FrameworkLang.GeneralConfirmationLower, LngGeneral, LngSystem)) = mrYes then
      TSysKullanici(Table).CopyFromRights(LFromUserID, TSysKullanici(Table).Id.Value);
  end;
end;

end.

