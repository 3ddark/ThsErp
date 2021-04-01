unit ufrmSetStkStokTipi;

interface

{$I ThsERP.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, StrUtils,
  Vcl.AppEvnts,
  Ths.Erp.Helper.Edit, Ths.Erp.Helper.ComboBox, Ths.Erp.Helper.Memo,

  ufrmBase, ufrmBaseInputDB, Vcl.Menus, Vcl.Samples.Spin;

type
  TfrmSetStkStokTipi = class(TfrmBaseInputDB)
    lbltip: TLabel;
    edttip: TEdit;
    lblis_default: TLabel;
    chkis_default: TCheckBox;
    lblis_stok_hareketi_yap: TLabel;
    chkis_stok_hareketi_yap: TCheckBox;
    procedure btnAcceptClick(Sender: TObject);override;
  private
    function VarsayilanKontrol(): Boolean;
  public
  protected
    function ValidateInput(panel_groupbox_pagecontrol_tabsheet: TWinControl = nil): Boolean;
      override;
  published
    procedure btnDeleteClick(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.SetStkStokTipi
  ;

{$R *.dfm}

procedure TfrmSetStkStokTipi.btnDeleteClick(Sender: TObject);
begin
  //silme i�leminde, i�lem �ncesinde varsay�lan olan kay�t silinemez �nce ba�ka bir varsay�lan se�ilmeli
  if (FormMode = ifmUpdate) then
  begin
    if (FormatedVariantVal(TSetStkStokTipi(Table).IsDefault.DataType, TSetStkStokTipi(Table).IsDefault.Value) = True) then
    begin
      if VarsayilanKontrol then
        inherited;
    end
    else
      inherited;
  end
  else
    inherited;
end;

function TfrmSetStkStokTipi.ValidateInput(
  panel_groupbox_pagecontrol_tabsheet: TWinControl): Boolean;
begin
  Result := inherited ValidateInput();

  //g�ncelleme i�leminde, i�lem �ncesinde varsay�lan olan kayd�n varsay�lan i�aretini kald�ramazs�n�z �nce ba�ka bir varsay�lan se�ilmeli
  if ((FormMode = ifmUpdate) and (not chkis_default.Checked)
  and (FormatedVariantVal(TSetStkStokTipi(Table).IsDefault.DataType, TSetStkStokTipi(Table).IsDefault.Value) = True)) then
    Result := VarsayilanKontrol;
end;

function TfrmSetStkStokTipi.VarsayilanKontrol: Boolean;
begin
  Result := True;
  if ((FormMode = ifmUpdate)
  and (not chkis_default.Checked)
  and (FormatedVariantVal(TSetStkStokTipi(Table).IsDefault.DataType, TSetStkStokTipi(Table).IsDefault.Value) = True))
  then
    Result := False;
    CustomMsgDlg(
      ReplaceMessages(
      TranslateText(
          'Bu i�lemi yapamazs�n�z! Bu i�lemde "Varsay�lan" i�areti kald�r�l�yor.' + AddLBs +
          '�nce ba�ka bir kayd� "Varsay�lan" olarak se�melisiniz.' + AddLBs +
          'Daha sonra bu kayd�n Varsay�lan i�aretini kad�rabilirsiniz.',
          'Stok Tipi Varsayilan Yok', LngMsgData, LngApplication), [''], ['']),
          mtError, [mbOK], [TranslateText('Tamam', FrameworkLang.ButtonOK, LngButton, LngSystem)], mbOK,
          TranslateText('Di�er', FrameworkLang.MessageTitleError, LngMsgTitle, LngSystem)
    );
end;

procedure TfrmSetStkStokTipi.btnAcceptClick(Sender: TObject);
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

end.
