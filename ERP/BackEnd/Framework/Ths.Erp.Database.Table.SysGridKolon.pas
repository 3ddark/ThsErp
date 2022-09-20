unit Ths.Erp.Database.Table.SysGridKolon;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysGridKolon = class(TTable)
  private
    FTabloAdi: TFieldDB;
    FKolonAdi: TFieldDB;
    FSiraNo: TFieldDB;
    FGenislik: TFieldDB;
    FDataFormat: TFieldDB;
    FIsGorunsun: TFieldDB;
    FIsGorunsunHelperForm: TFieldDB;
    FMinDeger: TFieldDB;
    FMinRenk: TFieldDB;
    FMaksDeger: TFieldDB;
    FMaksRenk: TFieldDB;
    FMaksDegerYuzde: TFieldDB;
    FRenkBar: TFieldDB;
    FRenkBarArka: TFieldDB;
    FRenkBarYazi: TFieldDB;
    FOzetTipi: TFieldDB;
    FOzetFormat: TFieldDB;
    //veri tabaný alaný deðil
    FSiraDurum: TSequenceStatus;
    FEskiDeger: Integer;
  protected
    procedure BusinessUpdate(APermissionControl: Boolean); override;
    procedure BusinessDelete(APermissionControl: Boolean); override;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;

    function GetMaxSequenceNo(ATableName: string): Integer;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    procedure Clear; override;
    function Clone: TTable; override;

    Property TabloAdi: TFieldDB read FTabloAdi write FTabloAdi;
    Property KolonAdi: TFieldDB read FKolonAdi write FKolonAdi;
    property SiraNo: TFieldDB read FSiraNo write FSiraNo;
    property Genislik: TFieldDB read FGenislik write FGenislik;
    property DataFormat: TFieldDB read FDataFormat write FDataFormat;
    property IsGorunsun: TFieldDB read FIsGorunsun write FIsGorunsun;
    property IsGorunsunHelperForm: TFieldDB read FIsGorunsunHelperForm write FIsGorunsunHelperForm;
    property MinDeger: TFieldDB read FMinDeger write FMinDeger;
    property MinRenk: TFieldDB read FMinRenk write FMinRenk;
    property MaksDeger: TFieldDB read FMaksDeger write FMaksDeger;
    property MaksRenk: TFieldDB read FMaksRenk write FMaksRenk;
    property MaksDegerYuzde: TFieldDB read FMaksDegerYuzde write FMaksDegerYuzde;
    property RenkBar: TFieldDB read FRenkBar write FRenkBar;
    property RenkBarArka: TFieldDB read FRenkBarArka write FRenkBarArka;
    property RenkBarYazi: TFieldDB read FRenkBarYazi write FRenkBarYazi;
    property OzetTipi: TFieldDB read FOzetTipi write FOzetTipi;
    property OzetFormat: TFieldDB read FOzetFormat write FOzetFormat;
    //veri tabaný alaný deðil
    property SiraDurum: TSequenceStatus read FSiraDurum write FSiraDurum;
    property EskiDeger: Integer read FEskiDeger write FEskiDeger;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants;

constructor TSysGridKolon.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_grid_kolon';
  TableSourceCode := MODULE_SISTEM_AYAR;
  inherited Create(ADatabase);

  FTabloAdi := TFieldDB.Create('tablo_adi', ftWideString, '', Self, 'Tablo Adý');
  FKolonAdi := TFieldDB.Create('kolon_adi', ftWideString, '', Self, 'Kolon Adý');
  FSiraNo := TFieldDB.Create('sira_no', ftInteger, 0, Self, 'Sýra No');
  FGenislik := TFieldDB.Create('genislik', ftInteger, 0, Self, 'Geniþlik');
  FDataFormat := TFieldDB.Create('data_format', ftWideString, '', Self, 'Data Format');
  FIsGorunsun := TFieldDB.Create('is_gorunsun', ftBoolean, False, Self, 'Görünsün?');
  FIsGorunsunHelperForm := TFieldDB.Create('is_gorunsun_helper_form', ftBoolean, False, Self, 'Görünsün Helper?');
  FMinDeger := TFieldDB.Create('min_deger', ftFloat, 0, Self, 'Min Deðer');
  FMinRenk := TFieldDB.Create('min_renk', ftInteger, 0, Self, 'Min Renk');
  FMaksDeger := TFieldDB.Create('maks_deger', ftFloat, 0, Self, 'Maks Deðer');
  FMaksRenk := TFieldDB.Create('maks_renk', ftInteger, 0, Self, 'Maks Renk');
  FMaksDegerYuzde := TFieldDB.Create('maks_deger_yuzde', ftFloat, 0, Self, 'Maks Deðer Yüzde');
  FRenkBar := TFieldDB.Create('renk_bar', ftInteger, 0, Self, 'Renk Bar');
  FRenkBarArka := TFieldDB.Create('renk_bar_arka', ftInteger, 0, Self, 'Renk Bar Arka');
  FRenkBarYazi := TFieldDB.Create('renk_bar_yazi', ftInteger, 0, Self, 'Renk Bar Yazý');
  FOzetTipi := TFieldDB.Create('ozet_tipi', ftInteger, 0, Self, 'Özet Tipi');
  FOzetFormat := TFieldDB.Create('ozet_format', ftWideString, '', Self, 'Özet Format');

  FSiraDurum := ssNone;
  FEskiDeger := 0;
end;

procedure TSysGridKolon.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        Self.Id.QryName,
        FTabloAdi.QryName,
        FKolonAdi.QryName,
        FSiraNo.QryName,
        FGenislik.QryName,
        FDataFormat.QryName,
        FIsGorunsun.QryName,
        FIsGorunsunHelperForm.QryName,
        FMinDeger.QryName,
        FMinRenk.QryName,
        FMaksDeger.QryName,
        FMaksRenk.QryName,
        FMaksDegerYuzde.QryName,
        FRenkBar.QryName,
        FRenkBarArka.QryName,
        FRenkBarYazi.QryName,
        FOzetTipi.QryName,
        FOzetFormat.QryName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
	  end;
  end;
end;

procedure TSysGridKolon.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  if (ALock) then
		  AFilter := AFilter + ' FOR UPDATE OF ' + TableName + ' NOWAIT';

	  with QueryOfList do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfList, TableName, [
        Self.Id.QryName,
        FTabloAdi.QryName,
        FKolonAdi.QryName,
        FSiraNo.QryName,
        FGenislik.QryName,
        FDataFormat.QryName,
        FIsGorunsun.QryName,
        FIsGorunsunHelperForm.QryName,
        FMinDeger.QryName,
        FMinRenk.QryName,
        FMaksDeger.QryName,
        FMaksRenk.QryName,
        FMaksDegerYuzde.QryName,
        FRenkBar.QryName,
        FRenkBarArka.QryName,
        FRenkBarYazi.QryName,
        FOzetTipi.QryName,
        FOzetFormat.QryName
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
		  EmptyDataSet;
		  Close;
	  end;
  end;
end;

procedure TSysGridKolon.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FKolonAdi.FieldName,
        FSiraNo.FieldName,
        FGenislik.FieldName,
        FDataFormat.FieldName,
        FIsGorunsun.FieldName,
        FIsGorunsunHelperForm.FieldName,
        FMinDeger.FieldName,
        FMinRenk.FieldName,
        FMaksDeger.FieldName,
        FMaksRenk.FieldName,
        FMaksDegerYuzde.FieldName,
        FRenkBar.FieldName,
        FRenkBarArka.FieldName,
        FRenkBarYazi.FieldName,
        FOzetTipi.FieldName,
        FOzetFormat.FieldName
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

procedure TSysGridKolon.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FTabloAdi.FieldName,
        FKolonAdi.FieldName,
        FSiraNo.FieldName,
        FGenislik.FieldName,
        FDataFormat.FieldName,
        FIsGorunsun.FieldName,
        FIsGorunsunHelperForm.FieldName,
        FMinDeger.FieldName,
        FMinRenk.FieldName,
        FMaksDeger.FieldName,
        FMaksRenk.FieldName,
        FMaksDegerYuzde.FieldName,
        FRenkBar.FieldName,
        FRenkBarArka.FieldName,
        FRenkBarYazi.FieldName,
        FOzetTipi.FieldName,
        FOzetFormat.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysGridKolon.Clear;
begin
  inherited;
  FSiraDurum := ssNone;
end;

function TSysGridKolon.Clone: TTable;
begin
  Result := TSysGridKolon.Create(Database);
  CloneClassContent(Self, Result);

  TSysGridKolon(Result).FSiraDurum := FSiraDurum;
  TSysGridKolon(Result).FEskiDeger := FEskiDeger;
end;

procedure TSysGridKolon.BusinessDelete(APermissionControl: Boolean);
var
  LGridKolon: TSysGridKolon;
  n1: Integer;
begin
  Self.Delete(APermissionControl);
  LGridKolon := TSysGridKolon.Create(Database);
  try
    LGridKolon.SelectToList(
        ' AND ' + TableName + '.' + FTabloAdi.FieldName + '=' + QuotedStr(FTabloAdi.Value) +
        ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' ASC ', False, False);
    for n1 := 0 to LGridKolon.List.Count-1 do
    begin
      TSysGridKolon(LGridKolon.List[n1]).SiraNo.Value := n1+1;
      TSysGridKolon(LGridKolon.List[n1]).Update(False);
    end;
  finally
    LGridKolon.Free;
  end;
end;

procedure TSysGridKolon.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
var
  LGridKolon: TSysGridKolon;
  n1: Integer;
begin
  LGridKolon := TSysGridKolon.Create(Database);
  try
    LGridKolon.SelectToList(
        ' AND ' + TableName + '.' + FTabloAdi.FieldName + '=' + QuotedStr(VarToStr(FTabloAdi.Value)) +
        ' AND ' + TableName + '.' + FSiraNo.FieldName + ' >= ' + VarToStr(FSiraNo.Value) +
        ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' DESC ', False, False);

    for n1 := 0 to LGridKolon.List.Count-1 do
    begin
      TSysGridKolon(LGridKolon.List[n1]).FSiraNo.Value := TSysGridKolon(LGridKolon.List[n1]).FSiraNo.Value + 1;
      TSysGridKolon(LGridKolon.List[n1]).Update(False);
    end;

    Self.Insert(AID, APermissionControl);
  finally
    FreeAndNil(LGridKolon);
  end;
end;

procedure TSysGridKolon.BusinessUpdate(APermissionControl: Boolean);
var
  LGridKolon: TSysGridKolon;
  n1: Integer;
begin
  LGridKolon := TSysGridKolon.Create(Database);
  try
    LGridKolon.SelectToList(
        ' AND ' + TableName + '.' + FTabloAdi.FieldName + '=' + QuotedStr(FTabloAdi.Value) +
        ' AND ' + TableName + '.' + FSiraNo.FieldName + '=' + FSiraNo.Value +
        ' AND ' + TableName + '.' + Self.Id.FieldName + '<>' + IntToStr(Self.Id.Value) +
        ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' ASC ', False, APermissionControl);

    if LGridKolon.List.Count > 0 then
    begin
      if FSiraDurum = ssArtis then
      begin
        LGridKolon.SelectToList(
          ' AND ' + TableName + '.' + FTabloAdi.FieldName + '=' + QuotedStr(FTabloAdi.Value) +
          ' AND ' + TableName + '.' + FSiraNo.FieldName + ' BETWEEN ' + IntToStr(FEskiDeger) + ' AND ' + FSiraNo.Value +
          ' AND ' + TableName + '.' + Self.Id.FieldName + '<>' + IntToStr(Self.Id.Value) +
          ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' ASC ', False, APermissionControl);

        FSiraNo.Value := FSiraNo.Value + 1000;
        Self.Update();

        for n1 := 0 to LGridKolon.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FEskiDeger+n1) then
          begin
            TSysGridKolon(LGridKolon.List[n1]).SiraNo.Value := FEskiDeger+n1;
            TSysGridKolon(LGridKolon.List[n1]).Update(APermissionControl);
          end;
        end;

        FSiraNo.Value := FSiraNo.Value - 1000;
      end
      else if FSiraDurum = ssAzalma then
      begin
        LGridKolon.SelectToList(
            ' AND ' + TableName + '.' + FTabloAdi.FieldName + '=' + QuotedStr(VarToStr(FTabloAdi.Value)) +
            ' AND ' + TableName + '.' + FSiraNo.FieldName + ' BETWEEN ' + VarToStr(FSiraNo.Value) + ' AND ' + IntToStr(FEskiDeger) +
            ' AND ' + TableName + '.' + Self.Id.FieldName + '<>' + VarToStr(Self.Id.Value) +
            ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' ASC ', False, False);

        FSiraNo.Value := FSiraNo.Value + 1000;
        Self.Update(APermissionControl);

        for n1 := 0 to LGridKolon.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FEskiDeger+n1) then
          begin
            TSysGridKolon(LGridKolon.List[n1]).SiraNo.Value := (FSiraNo.Value - 1000) + 1 + n1+100;
            TSysGridKolon(LGridKolon.List[n1]).Update(APermissionControl);
          end;
        end;

        for n1 := 0 to LGridKolon.List.Count-1 do
        begin
          if (FSiraNo.Value - 1000) <> (FSiraNo.Value - 1000) + 1 + n1 then
          begin
            TSysGridKolon(LGridKolon.List[n1]).SiraNo.Value := (FSiraNo.Value - 1000) + 1 + n1;
            TSysGridKolon(LGridKolon.List[n1]).Update(APermissionControl);
          end;
        end;

        FSiraNo.Value := FSiraNo.Value - 1000;
      end;
    end;
    Self.Update(APermissionControl);
  finally
    LGridKolon.Free;
  end;
end;

function TSysGridKolon.GetMaxSequenceNo(ATableName: string): Integer;
var
  LGridKolon: TSysGridKolon;
begin
  Result := 0;
  LGridKolon := TSysGridKolon.Create(Database);
  try
    LGridKolon.SelectToList(
      ' AND ' + TableName + '.' + TabloAdi.FieldName + '=' + QuotedStr(ATableName) +
      ' ORDER BY ' + TableName + '.' + FSiraNo.FieldName + ' DESC ', False, False);
    if LGridKolon.List.Count > 0 then
      Result := TSysGridKolon(LGridKolon.List[0]).FSiraNo.Value;
  finally
    LGridKolon.Free;
  end;
end;

end.
