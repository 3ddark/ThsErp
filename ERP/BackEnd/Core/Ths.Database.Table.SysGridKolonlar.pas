unit Ths.Database.Table.SysGridKolonlar;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Classes,
  Data.DB,
  ZDataset,
  Ths.Database,
  Ths.Database.Table;

type
  TSequenceStatus = (ssArtis, ssAzalma, ssNone);
  TSysGridKolon = class(TTable)
  private
    FTabloAdi: TFieldDB;
    FKolonAdi: TFieldDB;
    FSiraNo: TFieldDB;
    FKolonGenislik: TFieldDB;
    FVeriFormati: TFieldDB;
    FIsGorunur: TFieldDB;
    FIsHelperGorunur: TFieldDB;
    FMinDeger: TFieldDB;
    FMinRenk: TFieldDB;
    FMaxDeger: TFieldDB;
    FMaxRenk: TFieldDB;
    FMaxDegerYuzdesi: TFieldDB;
    FBarRengi: TFieldDB;
    FBarArkaRengi: TFieldDB;
    FBarYaziRengi: TFieldDB;
  protected
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
    procedure BusinessInsert(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;

    function GetMaxSequenceNo(ATableName: string): Integer;
  public
    FSeqStatus: TSequenceStatus;
    FOldValue: Integer;

    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure DoInsert(APermissionControl: Boolean=True); override;
    procedure DoUpdate(APermissionControl: Boolean=True); override;
    procedure Delete(APermissionControl: Boolean = True); override;

    function GetDistinctColumnNames(ATableName: string): TStringList;
    function HasAnyTableColumn(ATableName: string): Boolean;

    procedure Clear; override;
    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property KolonAdi: TFieldDB read FKolonAdi write FKolonAdi;
    property SiraNo: TFieldDB read FSiraNo write FSiraNo;
    property KolonGenislik: TFieldDB read FKolonGenislik write FKolonGenislik;
    property VeriFormati: TFieldDB read FVeriFormati write FVeriFormati;
    property IsGorunur: TFieldDB read FIsGorunur write FIsGorunur;
    property IsHelperGorunur: TFieldDB read FIsHelperGorunur write FIsHelperGorunur;
    property MinDeger: TFieldDB read FMinDeger write FMinDeger;
    property MinRenk: TFieldDB read FMinRenk write FMinRenk;
    property MaxDeger: TFieldDB read FMaxDeger write FMaxDeger;
    property MaxRenk: TFieldDB read FMaxRenk write FMaxRenk;
    property MaxDegerYuzdesi: TFieldDB read FMaxDegerYuzdesi write FMaxDegerYuzdesi;
    property BarRengi: TFieldDB read FBarRengi write FBarRengi;
    property BarArkaRengi: TFieldDB read FBarArkaRengi write FBarArkaRengi;
    property BarYaziRengi: TFieldDB read FBarYaziRengi write FBarYaziRengi;
  end;

implementation

uses
  Ths.Globals,
  Ths.Constants,
  Ths.Database.Table.View.SysViewColumns;

constructor TSysGridKolon.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_kolonlar';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTabloAdi := TFieldDB.Create('tablo_adi', ftWideString, '', Self, 'Tablo Adý');
  FKolonAdi := TFieldDB.Create('kolon_adi', ftWideString, '', Self, 'Kolon Adý');
  FSiraNo := TFieldDB.Create('sira_no', ftInteger, 0, Self, 'Sýra No');
  FKolonGenislik := TFieldDB.Create('kolon_genislik', ftInteger, 0, Self, 'Kolon Geniþlik');
  FVeriFormati := TFieldDB.Create('veri_formati', ftWideString, '', Self, 'Veri Formatý');
  FIsGorunur := TFieldDB.Create('is_gorunur', ftBoolean, False, Self, 'Görünür?');
  FIsHelperGorunur := TFieldDB.Create('is_helper_gorunur', ftBoolean, False, Self, 'Helper Görünür?');
  FMinDeger := TFieldDB.Create('min_deger', ftFloat, 0, Self, 'Min Deðer');
  FMinRenk := TFieldDB.Create('min_renk', ftInteger, 0, Self, 'Min Renk');
  FMaxDeger := TFieldDB.Create('maks_deger', ftFloat, 0, Self, 'Maks Deðer');
  FMaxRenk := TFieldDB.Create('maks_renk', ftInteger, 0, Self, 'Maks Renk');
  FMaxDegerYuzdesi := TFieldDB.Create('maks_deger_yuzdesi', ftFloat, 0, Self, 'Maks Deðer Yüzdesi');
  FBarRengi := TFieldDB.Create('bar_rengi', ftInteger, 0, Self, 'Bar Rengi');
  FBarArkaRengi := TFieldDB.Create('bar_arka_rengi', ftInteger, 0, Self, 'Bar Arka Rengi');
  FBarYaziRengi := TFieldDB.Create('bar_yazi_rengi', ftInteger, 0, Self, 'Bar Yazý Rengi');

  FSeqStatus := ssNone;
  FOldValue := 0;
end;

procedure TSysGridKolon.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if not IsAuthorized(ptRead, APermissionControl) then
    Exit;

  with QryOfDS do
  begin
    Close;
    Database.GetSQLSelectCmd(QryOfDS, TableName, [
      Id.QryName,
      FTabloAdi.QryName,
      FKolonAdi.QryName,
      FSiraNo.QryName,
      FKolonGenislik.QryName,
      FVeriFormati.QryName,
      FIsGorunur.QryName,
      FIsHelperGorunur.QryName,
      FMinDeger.QryName,
      FMinRenk.QryName,
      FMaxDeger.QryName,
      FMaxRenk.QryName,
      FMaxDegerYuzdesi.QryName,
      FBarRengi.QryName,
      FBarArkaRengi.QryName,
      FBarYaziRengi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ], AAllColumn, AHelper);
    Open;
  end;
end;

procedure TSysGridKolon.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
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
      Id.QryName,
      FTabloAdi.QryName,
      FKolonAdi.QryName,
      FSiraNo.QryName,
      FKolonGenislik.QryName,
      FVeriFormati.QryName,
      FIsGorunur.QryName,
      FIsHelperGorunur.QryName,
      FMinDeger.QryName,
      FMinRenk.QryName,
      FMaxDeger.QryName,
      FMaxRenk.QryName,
      FMaxDegerYuzdesi.QryName,
      FBarRengi.QryName,
      FBarArkaRengi.QryName,
      FBarYaziRengi.QryName
    ], [
      ' WHERE 1=1 ', AFilter
    ]);
    Open;

    FreeListContent();
    List.Clear;
    while NOT EOF do
    begin
      PrepareTableClassFromQuery(LQry);

      List.Add(Clone);

      Next;
    end;
  finally
    Free;
  end;
end;

procedure TSysGridKolon.DoInsert(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
      FTabloAdi.FieldName,
      FKolonAdi.FieldName,
      FSiraNo.FieldName,
      FKolonGenislik.FieldName,
      FVeriFormati.FieldName,
      FIsGorunur.FieldName,
      FIsHelperGorunur.FieldName,
      FMinDeger.FieldName,
      FMinRenk.FieldName,
      FMaxDeger.FieldName,
      FMaxRenk.FieldName,
      FMaxDegerYuzdesi.FieldName,
      FBarRengi.FieldName,
      FBarArkaRengi.FieldName,
      FBarYaziRengi.FieldName
    ]);

    PrepareInsertQueryParams(LQry);

    Open;
    Self.Id.Value := Fields.FieldByName(Id.FieldName).AsInteger;
  finally
    Free;
  end;
end;

procedure TSysGridKolon.DoUpdate(APermissionControl: Boolean);
var
  LQry: TZQuery;
begin
  LQry := Database.NewQuery();
  with LQry do
  try
    SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
      FTabloAdi.FieldName,
      FKolonAdi.FieldName,
      FSiraNo.FieldName,
      FKolonGenislik.FieldName,
      FVeriFormati.FieldName,
      FIsGorunur.FieldName,
      FIsHelperGorunur.FieldName,
      FMinDeger.FieldName,
      FMinRenk.FieldName,
      FMaxDeger.FieldName,
      FMaxRenk.FieldName,
      FMaxDegerYuzdesi.FieldName,
      FBarRengi.FieldName,
      FBarArkaRengi.FieldName,
      FBarYaziRengi.FieldName
    ]);

    PrepareUpdateQueryParams(LQry);

    ExecSQL;
  finally
    Free;
  end;
end;

procedure TSysGridKolon.Delete(APermissionControl: Boolean);
begin
  inherited;
end;

procedure TSysGridKolon.Clear;
begin
  inherited;
  FSeqStatus := ssNone;
end;

function TSysGridKolon.Clone: TTable;
begin
  Result := TSysGridKolon.Create(Database);
  CloneClassContent(Self, Result);

  TSysGridKolon(Result).FSeqStatus := FSeqStatus;
  TSysGridKolon(Result).FOldValue := FOldValue;
end;

procedure TSysGridKolon.BusinessDelete(APermissionControl: Boolean);
var
  LGridColumn: TSysGridKolon;
  n1: Integer;
begin
  Delete(APermissionControl);
  LGridColumn := TSysGridKolon.Create(Database);
  try
    LGridColumn.SelectToList(
        ' AND ' + FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.Value) +
        ' ORDER BY ' + FSiraNo.QryName + ' ASC ', False, False);
    for n1 := 0 to LGridColumn.List.Count-1 do
    begin
      TSysGridKolon(LGridColumn.List[n1]).SiraNo.Value := n1+1;
      TSysGridKolon(LGridColumn.List[n1]).Update(False);
    end;
  finally
    LGridColumn.Free;
  end;
end;

procedure TSysGridKolon.BusinessInsert(APermissionControl: Boolean);
var
  LGridColumn: TSysGridKolon;
  n1: Integer;
begin
  LGridColumn := TSysGridKolon.Create(Database);
  try
    LGridColumn.SelectToList(
        ' AND ' + FTabloAdi.QryName + '=' + QuotedStr(VarToStr(FTabloAdi.Value)) +
        ' AND ' + FSiraNo.QryName + ' >= ' + VarToStr(FSiraNo.Value) +
        ' ORDER BY ' + FSiraNo.QryName + ' DESC ', False, False);

    for n1 := 0 to LGridColumn.List.Count-1 do
    begin
      TSysGridKolon(LGridColumn.List[n1]).FSiraNo.Value := TSysGridKolon(LGridColumn.List[n1]).FSiraNo.Value + 1;
      TSysGridKolon(LGridColumn.List[n1]).Update(False);
    end;

    Insert(APermissionControl);
  finally
    FreeAndNil(LGridColumn);
  end;
end;

procedure TSysGridKolon.BusinessUpdate(APermissionControl: Boolean);
var
  LGridColumn: TSysGridKolon;
  n1: Integer;
begin
  LGridColumn := TSysGridKolon.Create(Database);
  try
    LGridColumn.SelectToList(
        ' AND ' + FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.Value) +
        ' AND ' + FSiraNo.QryName + '=' + FSiraNo.Value +
        ' AND ' + Id.QryName + '<>' + Id.AsString +
        ' ORDER BY ' + FSiraNo.QryName + ' ASC ', False, APermissionControl);

    if LGridColumn.List.Count > 0 then
    begin
      if FSeqStatus = ssArtis then
      begin
        LGridColumn.SelectToList(
          ' AND ' + FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.Value) +
          ' AND ' + FSiraNo.QryName + ' BETWEEN ' + IntToStr(FOldValue) + ' AND ' + FSiraNo.Value +
          ' AND ' + Id.QryName + '<>' + Id.AsString +
          ' ORDER BY ' + FSiraNo.QryName + ' ASC ', False, APermissionControl);

        FSiraNo.Value := FSiraNo.Value + 1000;
        Update(APermissionControl);

        for n1 := 0 to LGridColumn.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FOldValue+n1) then
          begin
            TSysGridKolon(LGridColumn.List[n1]).SiraNo.Value := FOldValue+n1;
            TSysGridKolon(LGridColumn.List[n1]).Update(APermissionControl);
          end;
        end;

        FSiraNo.Value := FSiraNo.Value - 1000;
      end
      else if FSeqStatus = ssAzalma then
      begin
        LGridColumn.SelectToList(
            ' AND ' + FTabloAdi.QryName + '=' + QuotedStr(FTabloAdi.AsString) +
            ' AND ' + FSiraNo.QryName + ' BETWEEN ' + FSiraNo.AsString + ' AND ' + IntToStr(FOldValue) +
            ' AND ' + Id.QryName + '<>' + Id.AsString +
            ' ORDER BY ' + FSiraNo.QryName + ' ASC ', False, False);

        FSiraNo.Value := FSiraNo.Value + 1000;
        Update(APermissionControl);

        for n1 := 0 to LGridColumn.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FOldValue+n1) then
          begin
            TSysGridKolon(LGridColumn.List[n1]).SiraNo.Value := (FSiraNo.Value - 1000) + 1 + n1+100;
            TSysGridKolon(LGridColumn.List[n1]).Update(APermissionControl);
          end;
        end;

        for n1 := 0 to LGridColumn.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FSiraNo.Value - 1000) + 1 + n1 then
          begin
            TSysGridKolon(LGridColumn.List[n1]).SiraNo.Value := (FSiraNo.Value - 1000) + 1 + n1;
            TSysGridKolon(LGridColumn.List[n1]).Update(APermissionControl);
          end;
        end;

        FSiraNo.Value := FSiraNo.Value - 1000;
      end;
    end;
    Update(APermissionControl);
  finally
    LGridColumn.Free;
  end;
end;

function TSysGridKolon.GetDistinctColumnNames(ATableName: string): TStringList;
var
  LQry: TZQuery;
  LViewCol: TSysViewColumns;
begin
  Result := TStringList.Create;

  LViewCol := TSysViewColumns.Create(Database);
  LQry := GDataBase.NewQuery;
  try
    LQry.Close;
    LQry.SQL.Text :=
      'SELECT distinct ' + LViewCol.ColumnName.QryName + ',' + LViewCol.OrdinalPosition.QryName + ' FROM ' + LViewCol.TableName + ' ' +
      ' LEFT JOIN ' + Self.TableName + ' ON ' + Self.TabloAdi.QryName + '=' + LViewCol.TabloAdi.QryName + ' and ' + Self.KolonAdi.QryName + '=' + LViewCol.ColumnName.QryName +
      ' WHERE ' + LViewCol.TabloAdi.QryName + '=' + QuotedStr(ATableName) + ' and ' + Self.KolonAdi.QryName + ' is null ' +
      ' GROUP BY ' + LViewCol.ColumnName.QryName + ',' + LViewCol.OrdinalPosition.QryName +
      ' ORDER BY ' + LViewCol.OrdinalPosition.QryName + ' ASC ';
    LQry.Open;
    while NOT LQry.EOF do
    begin
      Result.Add(LQry.Fields.Fields[0].AsString);
      LQry.Next;
    end;
    LQry.EmptyDataSet;
    LQry.Close;
  finally
    LQry.Free;
    LViewCol.Free;
  end;
end;

function TSysGridKolon.GetMaxSequenceNo(ATableName: string): Integer;
var
  LGridColumn: TSysGridKolon;
begin
  Result := 0;
  LGridColumn := TSysGridKolon.Create(Database);
  try
    LGridColumn.SelectToList(
      ' AND ' + TabloAdi.QryName + '=' + QuotedStr(ATableName) +
      ' ORDER BY ' + FSiraNo.QryName + ' DESC ', False, False);
    if LGridColumn.List.Count > 0 then
      Result := TSysGridKolon(LGridColumn.List[0]).FSiraNo.Value;
  finally
    LGridColumn.Free;
  end;
end;

function TSysGridKolon.HasAnyTableColumn(ATableName: string): Boolean;
var
  n1: Integer;
begin
  Result := False;
  for n1 := 0 to Self.List.Count-1 do
  begin
    if TSysGridKolon(Self.List[n1]).TabloAdi.AsString = ATableName then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
