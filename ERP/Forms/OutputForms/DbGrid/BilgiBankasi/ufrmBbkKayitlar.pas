unit ufrmBbkKayitlar;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.StrUtils,
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
  TfrmBbkKayitlar = class(TfrmBaseDBGrid)
    rghizli_filtre: TRadioGroup;
    mniN1: TMenuItem;
    mnitasi: TMenuItem;
    mnito_genel: TMenuItem;
    mnito_asansor: TMenuItem;
    mnito_export: TMenuItem;
    procedure FormShow(Sender: TObject); override;
    procedure HizliFiltre(Sender: TObject);
    procedure mnito_genelClick(Sender: TObject);
    procedure mnito_asansorClick(Sender: TObject);
    procedure mnito_exportClick(Sender: TObject);
    procedure pmDBPopup(Sender: TObject); override;
  private
    FHizliFilter: string;
    FHizliFilterActive: Boolean;
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  Ths.Erp.Globals,
  ufrmBbkKayit,
  Ths.Erp.Database.Table.BbkKayit,
  Ths.Erp.Database.Table.SetBbkKayitTipi;

{$R *.dfm}

function TfrmBbkKayitlar.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
var
  kayit: TBbkKayit;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmBbkKayit.Create(Application, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
  begin
    kayit := TBbkKayit.Create(Table.Database);
    if rghizli_filtre.ItemIndex = 0 then
      kayit.KayitTipiID.Value := Ord(TBbkKayitTipi.Genel)
    else if rghizli_filtre.ItemIndex = 1 then
      kayit.KayitTipiID.Value := Ord(TBbkKayitTipi.Asansor)
    else if rghizli_filtre.ItemIndex = 2 then
      kayit.KayitTipiID.Value := Ord(TBbkKayitTipi.Exprt);
    Result := TfrmBbkKayit.Create(Application, Self, kayit, pFormMode)
  end
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmBbkKayit.Create(Application, Self, Table.Clone(), pFormMode);
end;

procedure TfrmBbkKayitlar.FormShow(Sender: TObject);
begin
  inherited;
  rghizli_filtre.ItemIndex := 0;
  FHizliFilterActive := True;
  HizliFiltre(nil);
end;

procedure TfrmBbkKayitlar.HizliFiltre(Sender: TObject);
begin
  if not IsHelper then
  begin
    if FHizliFilterActive then
    begin
      grd.DataSource.DataSet.DisableControls;
      try
        FHizliFilterActive := False;
        grd.DataSource.DataSet.Filter := ReplaceStr(grd.DataSource.DataSet.Filter, FHizliFilter, '');

        FHizliFilter := '';
        if rghizli_filtre.ItemIndex = 0 then
          FHizliFilter := TBbkKayit(Table).KayitTipiID.FieldName + '=' + Ord(TBbkKayitTipi.Genel).ToString
        else if rghizli_filtre.ItemIndex = 1 then
          FHizliFilter := TBbkKayit(Table).KayitTipiID.FieldName + '=' + Ord(TBbkKayitTipi.Asansor).ToString
        else if rghizli_filtre.ItemIndex = 2 then
          FHizliFilter := TBbkKayit(Table).KayitTipiID.FieldName + '=' + Ord(TBbkKayitTipi.Exprt).ToString;

        if grd.DataSource.DataSet.Filter <> '' then
          FHizliFilter := ' AND ' + FHizliFilter;
        grd.DataSource.DataSet.Filter := FHizliFilter;
        if grd.DataSource.DataSet.Filter <> '' then
          grd.DataSource.DataSet.Filtered := True;
      finally
        FHizliFilterActive := True;
        grd.DataSource.DataSet.EnableControls;
      end;
    end;
  end;
end;

procedure TfrmBbkKayitlar.mnito_asansorClick(Sender: TObject);
var
  ATable: TBbkKayit;
begin
  if CustomMsgDlg('Kaydı taşıma istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo) <> mrYes then
    Exit;

  ATable := TBbkKayit.Create(Table.Database);
  try
    ATable.SelectToList(' AND ' + ATable.TableName + '.' + Table.Id.FieldName + '=' + VarToStr(FormatedVariantVal(Table.Id)), False, False);
    ATable.KayitTipiID.Value := Ord(TBbkKayitTipi.Asansor);
    ATable.Update(True);
  finally
    ATable.Free;
  end;

  grd.DataSource.DataSet.Refresh;
  grd.Refresh;
  rghizli_filtre.ItemIndex := 1;
  HizliFiltre(rghizli_filtre);
end;

procedure TfrmBbkKayitlar.mnito_exportClick(Sender: TObject);
var
  ATable: TBbkKayit;
begin
  if CustomMsgDlg('Kaydı taşıma istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo) <> mrYes then
    Exit;

  ATable := TBbkKayit.Create(Table.Database);
  try
    ATable.SelectToList(' AND ' + ATable.TableName + '.' + Table.Id.FieldName + '=' + VarToStr(FormatedVariantVal(Table.Id)), False, False);
    ATable.KayitTipiID.Value := Ord(TBbkKayitTipi.Exprt);
    ATable.Update(True);
  finally
    ATable.Free;
  end;

  grd.DataSource.DataSet.Refresh;
  grd.Refresh;
  rghizli_filtre.ItemIndex := 2;
  HizliFiltre(rghizli_filtre);
end;

procedure TfrmBbkKayitlar.mnito_genelClick(Sender: TObject);
var
  ATable: TBbkKayit;
begin
  if CustomMsgDlg('Kaydı taşıma istediğinden emin misin?', mtConfirmation, mbYesNo, ['Evet', 'Hayır'], mbNo) <> mrYes then
    Exit;

  ATable := TBbkKayit.Create(Table.Database);
  try
    ATable.SelectToList(' AND ' + ATable.TableName + '.' + Table.Id.FieldName + '=' + VarToStr(FormatedVariantVal(Table.Id)), False, False);
    ATable.KayitTipiID.Value := Ord(TBbkKayitTipi.Genel);
    ATable.Update(True);
  finally
    ATable.Free;
  end;

  grd.DataSource.DataSet.Refresh;
  grd.Refresh;
  rghizli_filtre.ItemIndex := 0;
  HizliFiltre(rghizli_filtre);
end;

procedure TfrmBbkKayitlar.pmDBPopup(Sender: TObject);
begin
  inherited;
  mnito_genel.Enabled := True;
  mnito_asansor.Enabled := True;
  mnito_export.Enabled := True;

  if TBbkKayit(Table).KayitTipiID.Value = Ord(TBbkKayitTipi.Genel) then
    mnito_genel.Enabled := False
  else if TBbkKayit(Table).KayitTipiID.Value = Ord(TBbkKayitTipi.Asansor) then
    mnito_asansor.Enabled := False
  else if TBbkKayit(Table).KayitTipiID.Value = Ord(TBbkKayitTipi.Exprt) then
    mnito_export.Enabled := False;
end;

end.
