unit Ths.Erp.Database.Table.SetUtdDosyaUzantisi;

interface

{$I ThsERP.inc}

uses
    System.SysUtils
  , Data.DB
  , Ths.Erp.Database
  , Ths.Erp.Database.Table
  ;

type
  TSetUtdDosyaUzantisi = class(TTable)
  private
    FFakeDosyaUzantisi: TFieldDB;
    FDosyaUzantisi: TFieldDB;
  protected
  published
    constructor Create(ADataBase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    Property FakeDosyaUzantisi: TFieldDB read FFakeDosyaUzantisi write FFakeDosyaUzantisi;
    Property DosyaUzantisi: TFieldDB read FDosyaUzantisi write FDosyaUzantisi;
  end;

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  ;

constructor TSetUtdDosyaUzantisi.Create(ADataBase: TDatabase);
begin
  TableName := 'set_utd_dosya_uzantisi';
  TableSourceCode := '7410';
  inherited Create(ADataBase);

  FFakeDosyaUzantisi := TFieldDB.Create('fake_dosya_uzantisi', ftString, '', Self, 'Sahte Dosya Uzantýsý');
  FDosyaUzantisi := TFieldDB.Create('dosya_uzantisi', ftString, '', Self, 'Dosya Uzantýsý');
end;

procedure TSetUtdDosyaUzantisi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
    with QueryOfDS do
    begin
      Close;
      Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FFakeDosyaUzantisi.FieldName,
        TableName + '.' + FDosyaUzantisi.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
      Open;
      Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FFakeDosyaUzantisi, 'Sahte Dosya Uzantýsý', QueryOfDS);
      setFieldTitle(FDosyaUzantisi, 'Dosya Uzantýsý', QueryOfDS);
    end;
  end;
end;

procedure TSetUtdDosyaUzantisi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FFakeDosyaUzantisi.FieldName,
        TableName + '.' + FDosyaUzantisi.FieldName
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

procedure TSetUtdDosyaUzantisi.Insert(out AID: Integer; APermissionControl: Boolean);
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
          FFakeDosyaUzantisi.FieldName,
          FDosyaUzantisi.FieldName
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

procedure TSetUtdDosyaUzantisi.Update(APermissionControl: Boolean);
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
          FFakeDosyaUzantisi.FieldName,
          FDosyaUzantisi.FieldName
        ]);

        PrepareUpdateQueryParams;

        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

function TSetUtdDosyaUzantisi.Clone: TTable;
begin
  Result := TSetUtdDosyaUzantisi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
