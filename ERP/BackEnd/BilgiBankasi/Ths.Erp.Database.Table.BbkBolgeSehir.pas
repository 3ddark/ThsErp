unit Ths.Erp.Database.Table.BbkBolgeSehir;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  , Ths.Erp.Database.Table.SetBbkBolge
  , Ths.Erp.Database.Table.SysSehir
  , Ths.Erp.Database.Table.SysUlke
  ;

type

  TBbkBolgeSehir = class(TTable)
  private
    FSehirID: TFieldDB;
    FSehir: TFieldDB;
    FUlkeID: TFieldDB;
    FUlke: TFieldDB;
    FBolgeID: TFieldDB;
    FBolge: TFieldDB;
  protected
    FBbkBolge: TSetBbkBolge;
    FCity: TSysSehir;
    FCountry: TSysUlke;
  published
    constructor Create(ADatabase: TDatabase); override;
    destructor Destroy; override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property SehirID: TFieldDB read FSehirID write FSehirID;
    Property Sehir: TFieldDB read FSehir write FSehir;
    Property UlkeID: TFieldDB read FUlkeID write FUlkeID;
    Property Ulke: TFieldDB read FUlke write FUlke;
    Property BolgeID: TFieldDB read FBolgeID write FBolgeID;
    Property Bolge: TFieldDB read FBolge write FBolge;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TBbkBolgeSehir.Create(ADatabase: TDatabase);
begin
  TableName := 'bbk_bolge_sehir';
  TableSourceCode := '6521';
  inherited Create(ADatabase);

  FBbkBolge := TSetBbkBolge.Create(Database);
  FCity := TSysSehir.Create(Database);
  FCountry := TSysUlke.Create(Database);

  FSehirID := TFieldDB.Create('sehir_id', ftInteger, 0, Self, '');
  FSehir := TFieldDB.Create(FCity.SehirAdi.FieldName, FCity.SehirAdi.DataType, '', Self, '');
  FUlkeID := TFieldDB.Create(FCity.UlkeID.FieldName, FCity.UlkeID.DataType, 0, Self, '');
  FUlke := TFieldDB.Create(FCity.UlkeAdi.FieldName, FCity.UlkeAdi.DataType, '', Self, '');
  FBolgeID := TFieldDB.Create('bolge_id', ftInteger, 0, Self, '');
  FBolge := TFieldDB.Create(FBbkBolge.Bolge.FieldName, FBbkBolge.Bolge.DataType, '', Self, '');
end;

destructor TBbkBolgeSehir.Destroy;
begin
  FreeAndNil(FBbkBolge);
  FreeAndNil(FCity);
  FreeAndNil(FCountry);

  inherited;
end;

procedure TBbkBolgeSehir.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FSehirID.FieldName,
        addField(FCity.TableName, FCity.SehirAdi.FieldName, FSehir.FieldName),
        addField(FCountry.TableName, FCountry.Id.FieldName, FUlkeID.FieldName),
        addField(FCountry.TableName, FCountry.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addField(FBbkBolge.TableName, FBbkBolge.Bolge.FieldName, FBolge.FieldName)
      ], [
        addJoin(jtLeft, FCity.TableName, FCity.Id.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FCountry.TableName, FCountry.Id.FieldName, FCity.TableName, FCity.UlkeID.FieldName),
        addJoin(jtLeft, FBbkBolge.TableName, FBbkBolge.Id.FieldName, TableName, FBolgeID.FieldName),
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FSehirID, 'Þehir ID', QueryOfDS);
      setFieldTitle(FSehir, 'Þehir', QueryOfDS);
      setFieldTitle(FUlkeID, 'Ülke ID', QueryOfDS);
      setFieldTitle(FUlke, 'Ülke', QueryOfDS);
      setFieldTitle(FBolgeID, 'Bölge ID', QueryOfDS);
      setFieldTitle(FBolge, 'Bölge', QueryOfDS);
    end;
  end;
end;

procedure TBbkBolgeSehir.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FSehirID.FieldName,
        addField(FCity.TableName, FCity.SehirAdi.FieldName, FSehir.FieldName),
        addField(FCountry.TableName, FCountry.Id.FieldName, FUlkeID.FieldName),
        addField(FCountry.TableName, FCountry.UlkeAdi.FieldName, FUlke.FieldName),
        TableName + '.' + FBolgeID.FieldName,
        addField(FBbkBolge.TableName, FBbkBolge.Bolge.FieldName, FBolge.FieldName)
      ], [
        addJoin(jtLeft, FCity.TableName, FCity.Id.FieldName, TableName, FSehirID.FieldName),
        addJoin(jtLeft, FCountry.TableName, FCountry.Id.FieldName, FCity.TableName, FCity.UlkeID.FieldName),
        addJoin(jtLeft, FBbkBolge.TableName, FBbkBolge.Id.FieldName, TableName, FBolgeID.FieldName),
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

procedure TBbkBolgeSehir.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpInsert.ExecProc;
      AID := SpInsert.ParamByName('result').AsInteger;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfInsert do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
          FSehirID.FieldName,
          FBolgeID.FieldName
        ]);

        PrepareInsertQueryParams;

        Open;
        if (Fields.Count > 0) and (not Fields.FieldByName(Self.Id.FieldName).IsNull) then
          AID := Fields.FieldByName(Self.Id.FieldName).AsInteger
        else
          AID := 0;

        EmptyDataSet;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

procedure TBbkBolgeSehir.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpUpdate.ExecProc;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfUpdate do
      begin
        Close;
        SQL.Clear;
        SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
          FSehirID.FieldName,
          FBolgeID.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

function TBbkBolgeSehir.Clone: TTable;
begin
  Result := TBbkBolgeSehir.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
