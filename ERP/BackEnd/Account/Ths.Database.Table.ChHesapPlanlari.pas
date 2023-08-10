unit Ths.Database.Table.ChHesapPlanlari;

interface

{$I Ths.inc}

uses
  System.SysUtils,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TChHesapPlani = class(TTable)
  private
    FPlanKodu: TFieldDB;
    FPlanAdi: TFieldDB;
    FSeviye: TFieldDB;
  protected
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property PlanKodu: TFieldDB read FPlanKodu write FPlanKodu;
    Property PlanAdi: TFieldDB read FPlanAdi write FPlanAdi;
    Property Seviye: TFieldDB read FSeviye write FSeviye;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.ChHesapKarti,
  Ths.Database.Table.ChHesapHareketi;

constructor TChHesapPlani.Create(ADatabase: TDatabase);
begin
  TableName := 'ch_hesap_planlari';
  TableSourceCode := MODULE_CH_AYAR;
  inherited Create(ADatabase);

  FPlanKodu := TFieldDB.Create('plan_kodu', ftString, '', Self, 'Plan Kodu');
  FPlanAdi := TFieldDB.Create('plan_adi', ftString, '', Self, 'Plan Adý');
  FSeviye := TFieldDB.Create('seviye', ftInteger, 0, Self, 'Seviye Sayýsý');
end;

procedure TChHesapPlani.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FPlanKodu.FieldName,
      TableName + '.' + FPlanAdi.FieldName,
      TableName + '.' + FSeviye.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TChHesapPlani.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  AFilter := GetLockSQL(AFilter, ALock);

  LQry := Database.NewQuery();
  with LQry do
  try
    Database.GetSQLSelectCmd(LQry, TableName, [
      TableName + '.' + Self.Id.FieldName,
      TableName + '.' + FPlanKodu.FieldName,
      TableName + '.' + FPlanAdi.FieldName,
      TableName + '.' + FSeviye.FieldName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Self.Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TChHesapPlani.DoInsert(out AID: Integer; APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FPlanKodu.FieldName,
      FPlanAdi.FieldName,
      FSeviye.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull)
    then  AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
    else  AID := 0;
  finally
    Free;
  end;
end;

procedure TChHesapPlani.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FPlanKodu.FieldName,
      FPlanAdi.FieldName,
      FSeviye.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TChHesapPlani.BusinessDelete(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    with Database.NewQuery do
    try
      Close;
      SQL.Clear;
      SQL.Text := 'SELECT COUNT(*) FROM ' + LHesap.TableName + ' WHERE ' +
        LHesap.HesapKodu.QryName + ' LIKE ' + QuotedStr(FPlanKodu.AsString + '%') + ' AND ' +
        LHesap.HesapTipiID.QryName + '<>' + IntToStr(Ord(THesapTipi.htAna));
      Open;

      if (not Fields.Fields[0].IsNull) and (Fields.Fields[0].AsInteger > 0) then
        CreateExceptionByLang('Hesap Planýna baðlý Cari Hesap olan kayýtlar silinemez!' + AddLBs(2) +
                              'Önce Cari Hesap Kartýný silin!', '999999');
    finally
      Free;
    end;
    Delete(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TChHesapPlani.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FPlanKodu.Value;
    LHesap.HesapIsmi.Value := UpperCaseTr(Self.FPlanAdi.AsString);
    LHesap.KokKod.Value := Self.FPlanKodu.Value;

    //120-1-2     3 seviye
    //600-1       2 seviye
    //760         1 seviye
    //Seviye 1 ise oluþan Hesap Son Hesap olur
    //Seviye 2 ise oluþan Hesap Ana Hesap olur
    //Seviye 3 ise oluþan Hesap Ana Hesap olur
    if Self.Seviye.Value > 1
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;

    LHesap.Insert(AID, False);
    LHesap.Id.Value := AID;

    Self.Insert(AID, APermissionControl);
  finally
    LHesap.Free;
  end;
end;

procedure TChHesapPlani.BusinessUpdate(APermissionControl: Boolean);
var
  LHesap: TChHesapKarti;
begin
  LHesap := TChHesapKarti.Create(Database);
  try
    LHesap.HesapKodu.Value := Self.FPlanKodu.Value;
    LHesap.HesapIsmi.Value := Self.FPlanAdi.Value;
    if Self.Seviye.Value > Ord(THesapTipi.htAna)
    then  LHesap.HesapTipiID.Value := THesapTipi.htAna
    else  LHesap.HesapTipiID.Value := THesapTipi.htSon;
    LHesap.KokKod.Value := Self.FPlanKodu.Value;

    LHesap.Update(False);

    Self.Update(APermissionControl);
  finally
    LHesap.Free;
  end;
end;

function TChHesapPlani.Clone: TTable;
begin
  Result := TChHesapPlani.Create(Database);
  CloneClassContent(Self, Result);
end;

end.



