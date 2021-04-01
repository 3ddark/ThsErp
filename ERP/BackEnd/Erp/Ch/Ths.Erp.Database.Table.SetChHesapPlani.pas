unit Ths.Erp.Database.Table.SetChHesapPlani;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSetChHesapPlani = class(TTable)
  private
    FTekDuzenKodu: TFieldDB;
    FAciklama: TFieldDB;
    FSeviyeSayisi: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property TekDuzenKodu: TFieldDB read FTekDuzenKodu write FTekDuzenKodu;
    Property Aciklama: TFieldDB read FAciklama write FAciklama;
    Property SeviyeSayisi: TFieldDB read FSeviyeSayisi write FSeviyeSayisi;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton,
  Ths.Erp.Database.Table.ChHesapKarti,
  Ths.Erp.Database.Table.ChHesapHareketi,
  Ths.Erp.Database.Table.SysAdres;

constructor TSetChHesapPlani.Create(ADatabase: TDatabase);
begin
  TableName := 'set_ch_hesap_plani';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FTekDuzenKodu := TFieldDB.Create('tek_duzen_kodu', ftString, '', Self, 'Tek Düzen Kodu');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'Açýklama');
  FSeviyeSayisi := TFieldDB.Create('seviye_sayisi', ftInteger, 0, Self, 'Seviye Sayýsý');
end;

procedure TSetChHesapPlani.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FTekDuzenKodu.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FSeviyeSayisi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;
    end;
  end;
end;

procedure TSetChHesapPlani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FTekDuzenKodu.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FSeviyeSayisi.FieldName
      ], [
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

procedure TSetChHesapPlani.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    with QueryOfInsert do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTekDuzenKodu.FieldName,
        FAciklama.FieldName,
        FSeviyeSayisi.FieldName
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

procedure TSetChHesapPlani.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    with QueryOfUpdate do
    begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTekDuzenKodu.FieldName,
        FAciklama.FieldName,
        FSeviyeSayisi.FieldName
      ]);

      PrepareUpdateQueryParams;

      ExecSQL;
      Close;
    end;
    Self.notify;
  end;
end;

procedure TSetChHesapPlani.BusinessDelete(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    QueryOfOther.Close;
    QueryOfOther.SQL.Clear;
    QueryOfOther.SQL.Text := 'SELECT COUNT(*) FROM ' + LHesap.TableName + ' WHERE ' +
      LHesap.TableName + '.' + LHesap.HesapKodu.FieldName + ' LIKE ' + QuotedStr(VarToStr(FormatedVariantVal(FTekDuzenKodu)) + '%') + ' AND ' +
      LHesap.TableName + '.' + LHesap.HesapTipiID.FieldName + '<>' + IntToStr(Ord(THesapTipi.htAna));
    QueryOfOther.Open;
    if (not QueryOfOther.Fields.Fields[0].IsNull) and (QueryOfOther.Fields.Fields[0].AsInteger > 0) then
      CreateExceptionByLang('Hesap Planýna baðlý Cari Hesap olan kayýtlar silinemez!' + AddLBs(2) +
                            'Önce Cari Hesap Kartýný silin!', '999999');

    Delete(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TSetChHesapPlani.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FTekDuzenKodu.Value;
    LHesap.HesapIsmi.Value := UpperCaseTr(VarToStr(FormatedVariantVal(Self.FAciklama)));
    LHesap.MuhasebeKodu.Value := Self.FTekDuzenKodu.Value;
    LHesap.KokHesapKodu.Value := Self.FTekDuzenKodu.Value;

    //120-1-2     3 seviye
    //600-1       2 seviye
    //760         1 seviye
    //Seviye 1 ise oluþan Hesap Son Hesap olur
    //Seviye 2 ise oluþan Hesap Ana Hesap olur
    //Seviye 3 ise oluþan Hesap Ana Hesap olur
    if Self.SeviyeSayisi.Value > 1
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;

    LHesap.Insert(AID, False);
    LHesap.Id.Value := AID;

    Self.Insert(AID, APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TSetChHesapPlani.BusinessUpdate(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FTekDuzenKodu.Value;
    LHesap.HesapIsmi.Value := Self.FAciklama.Value;
    LHesap.MuhasebeKodu.Value := Self.FTekDuzenKodu.Value;
    if Self.SeviyeSayisi.Value > Ord(THesapTipi.htAna)
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;
    LHesap.KokHesapKodu.Value := Self.FTekDuzenKodu.Value;

    LHesap.Update(False);

    Self.Update(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

function TSetChHesapPlani.Clone: TTable;
begin
  Result := TSetChHesapPlani.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
