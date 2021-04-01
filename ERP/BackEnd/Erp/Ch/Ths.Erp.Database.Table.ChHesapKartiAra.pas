unit Ths.Erp.Database.Table.ChHesapKartiAra;

interface

{$I ThsERP.inc}

uses
  SysUtils, Classes, Dialogs, Forms, Windows, Controls, Types, DateUtils,
  FireDAC.Stan.Param, System.Variants, Data.DB, System.StrUtils,
  Ths.Erp.Database,
  Ths.Erp.Database.Table,
  Ths.Erp.Database.Table.SetChHesapTipi,
  Ths.Erp.Database.Table.SetChHesapPlani;

type
  TChHesapKartiAra = class(TTable)
  private
    FHesapKodu: TFieldDB;
    FHesapIsmi: TFieldDB;
    FMuhasebeKodu: TFieldDB;
    FHesapTipiID: TFieldDB;
    FHesapTipi: TFieldDB;
    FKokHesapKodu: TFieldDB;
    FSeviyeSayisi: TFieldDB;
  protected
    FSetChHesapTipi: TSetChHesapTipi;
    FSetChHesapPlani: TSetChHesapPlani;

    procedure BusinessSelect(AFilter: string; ALock: Boolean; APermissionControl: Boolean); override;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    procedure Validate;

    Property HesapKodu: TFieldDB read FHesapKodu write FHesapKodu;
    Property HesapIsmi: TFieldDB read FHesapIsmi write FHesapIsmi;
    Property MuhasebeKodu: TFieldDB read FMuhasebeKodu write FMuhasebeKodu;
    Property HesapTipiID: TFieldDB read FHesapTipiID write FHesapTipiID;
    Property HesapTipi: TFieldDB read FHesapTipi write FHesapTipi;
    Property KokHesapKodu: TFieldDB read FKokHesapKodu write FKokHesapKodu;
    Property SeviyeSayisi: TFieldDB read FSeviyeSayisi write FSeviyeSayisi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.ChHesapKarti;

procedure TChHesapKartiAra.BusinessDelete(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
  LStr: string;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LStr := VarToStr(FormatedVariantVal(HesapKodu));
    //Bu ara hesaptan oluşturulmuş son hesap varsa silmeyi engelle
    LHesap.SelectToList(
      ' AND ' + LHesap.TableName + '.' + LHesap.AraHesapKodu.FieldName + '=' + QuotedStr(LStr) +
      ' AND ' + LHesap.TableName + '.' + LHesap.HesapTipiID.FieldName + '=' + IntToStr(Ord(htSon))
      , False, False);
    if LHesap.List.Count > 0 then
      CreateExceptionByLang('Bu hesaba bağlı Son Hesaplar oluşturulmuş! Önce bu hesaplar silinmeli.', '999999');

    Delete(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TChHesapKartiAra.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
begin
  Self.Insert(AID, APermissionControl);
end;

procedure TChHesapKartiAra.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  inherited;
end;

procedure TChHesapKartiAra.BusinessUpdate(APermissionControl: Boolean);
begin
  Self.Update(APermissionControl);
end;

constructor TChHesapKartiAra.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_karti';
  TableSourceCode := MODULE_CH_KAYIT;
  inherited Create(ADatabase);

  FSetChHesapTipi := TSetChHesapTipi.Create(Database);
  FSetChHesapPlani := TSetChHesapPlani.Create(Database);

  FHesapKodu := TFieldDB.Create('hesap_kodu', ftString, '', Self, 'Hesap Kodu');
  FHesapIsmi := TFieldDB.Create('hesap_ismi', ftString, '', Self, 'Hesap İsmi');
  FMuhasebeKodu := TFieldDB.Create('muhasebe_kodu', ftString, '', Self, 'Muhasebe Kodu');
  FHesapTipiID := TFieldDB.Create('hesap_tipi_id', ftInteger, 0, Self, 'Hesap Tipi ID');
  FHesapTipi := TFieldDB.Create(FSetChHesapTipi.HesapTipi.FieldName, FSetChHesapTipi.HesapTipi.DataType, '', Self, 'Hesap Tipi');
  FKokHesapKodu := TFieldDB.Create('kok_hesap_kodu', ftString, '', Self, 'Kök Hesap Kodu');
  FSeviyeSayisi := TFieldDB.Create(FSetChHesapPlani.SeviyeSayisi.FieldName, FSetChHesapPlani.SeviyeSayisi.DataType, 0, Self, 'Seviye Sayısı');
end;

destructor TChHesapKartiAra.Destroy;
begin
  FSetChHesapTipi.Free;
  FSetChHesapPlani.Free;

  inherited;
end;

procedure TChHesapKartiAra.SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapKodu.FieldName,
        TableName + '.' + FHesapIsmi.FieldName,
        TableName + '.' + FMuhasebeKodu.FieldName,
        TableName + '.' + FHesapTipiID.FieldName,
        addField(FSetChHesapTipi.TableName, FSetChHesapTipi.HesapTipi.FieldName, FHesapTipi.FieldName),
        TableName + '.' + FKokHesapKodu.FieldName,
        addField(FSetChHesapPlani.TableName, FSetChHesapPlani.SeviyeSayisi.FieldName, FSeviyeSayisi.FieldName)
      ], [
        addJoin(jtLeft, FSetChHesapTipi.TableName, FSetChHesapTipi.Id.FieldName, TableName, FHesapTipiID.FieldName),
        addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.TekDuzenKodu.FieldName, TableName, FKokHesapKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TChHesapKartiAra.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

    with QueryOfList do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfList, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FHesapKodu.FieldName,
        TableName + '.' + FHesapIsmi.FieldName,
        TableName + '.' + FMuhasebeKodu.FieldName,
        TableName + '.' + FHesapTipiID.FieldName,
        addField(FSetChHesapTipi.TableName, FSetChHesapTipi.HesapTipi.FieldName, FHesapTipi.FieldName),
        TableName + '.' + FKokHesapKodu.FieldName,
        addField(FSetChHesapPlani.TableName, FSetChHesapPlani.SeviyeSayisi.FieldName, FSeviyeSayisi.FieldName)
      ], [
        addJoin(jtLeft, FSetChHesapTipi.TableName, FSetChHesapTipi.Id.FieldName, TableName, FHesapTipiID.FieldName),
        addJoin(jtLeft, FSetChHesapPlani.TableName, FSetChHesapPlani.TekDuzenKodu.FieldName, TableName, FKokHesapKodu.FieldName),
        ' WHERE 1=1 ', AFilter
      ]);
      Open;

      FreeListContent();
      List.Clear;
      while NOT EOF do
      begin
        PrepareTableClassFromQuery(QueryOfList);

        List.Add(Self.Clone);

        Next;
      end;
      Close;
    end;
  end;
end;

procedure TChHesapKartiAra.Insert(out AID: Integer; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FHesapIsmi.FieldName,
        FMuhasebeKodu.FieldName,
        FHesapTipiID.FieldName,
        FKokHesapKodu.FieldName
      ]);

      PrepareInsertQueryParams;

      Open;
      if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
      then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
      else  AID := 0;

      EmptyDataSet;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChHesapKartiAra.Update(APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FHesapKodu.FieldName,
        FHesapIsmi.FieldName,
        FMuhasebeKodu.FieldName,
        FHesapTipiID.FieldName,
        FKokHesapKodu.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TChHesapKartiAra.Validate;
var
  LStr: string;
begin
  if (KokHesapKodu.Value = '') then
    CreateExceptionByLang('Kök Hesap Kodu seçilmeden devam edilemez!', '999999');

  LStr := ReverseString(VarToStr(FormatedVariantVal(HesapKodu)));
  if (LStr[1] = '-') then
    CreateExceptionByLang('Ara Hesap Kodu doğru girilmedi! Örnek Kod "120-1" gibi olmalı', '999999');
end;

function TChHesapKartiAra.Clone: TTable;
begin
  Result := TChHesapKartiAra.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
