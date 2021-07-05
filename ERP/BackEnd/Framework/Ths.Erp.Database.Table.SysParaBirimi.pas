unit Ths.Erp.Database.Table.SysParaBirimi;

interface

{$I ThsERP.inc}

uses
  System.SysUtils,
  Data.DB,
  Ths.Erp.Database,
  Ths.Erp.Database.Table;

type
  TSysParaBirimi = class(TTable)
  private
    FParaBirimi: TFieldDB;
    FSembol: TFieldDB;
    FAciklama: TFieldDB;
    FIsVarsayilan: TFieldDB;
  protected
    procedure BusinessUpdate(APermissionControl: Boolean); override;
  published
    constructor Create(ADatabase: TDatabase); override;
  public
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); override;
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); override;
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); override;
    procedure Update(APermissionControl: Boolean=True); override;

    function Clone: TTable; override;

    property ParaBirimi: TFieldDB read FParaBirimi write FParaBirimi;
    property Sembol: TFieldDB read FSembol write FSembol;
    property Aciklama: TFieldDB read FAciklama write FAciklama;
    property IsVarsayilan: TFieldDB read FIsVarsayilan write FIsVarsayilan;
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TSysParaBirimi.Create(ADatabase: TDatabase);
begin
  TableName := 'sys_para_birimi';
  TableSourceCode := MODULE_SISTEM_DIGER;
  inherited Create(ADatabase);

  FParaBirimi := TFieldDB.Create('para_birimi', ftString, '', Self, 'Para Birimi');
  FSembol := TFieldDB.Create('sembol', ftString, '', Self, 'Sembol');
  FAciklama := TFieldDB.Create('aciklama', ftString, '', Self, 'A��klama');
  FIsVarsayilan := TFieldDB.Create('is_varsayilan', ftBoolean, False, Self, 'Varsay�lan');
end;

procedure TSysParaBirimi.SelectToDatasource(AFilter: string; APermissionControl: Boolean; AAllColumn: Boolean; AHelper: Boolean);
begin
  if IsAuthorized(ptRead, APermissionControl) then
  begin
	  with QueryOfDS do
	  begin
		  Close;
		  Database.GetSQLSelectCmd(QueryOfDS, TableName, [
        TableName + '.' + Self.Id.FieldName,
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FSembol.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsVarsayilan.FieldName
      ], [
        ' WHERE 1=1 ', AFilter
      ], AAllColumn, AHelper);
		  Open;
		  Active := True;

      setFieldTitle(Self.Id, 'Id', QueryOfDS);
      setFieldTitle(FParaBirimi, 'Para Birimi', QueryOfDS);
      setFieldTitle(FSembol, 'Sembol', QueryOfDS);
      setFieldTitle(FAciklama, 'A��klama', QueryOfDS);
      setFieldTitle(FIsVarsayilan, 'Varsay�lan?', QueryOfDS);
	  end;
  end;
end;

procedure TSysParaBirimi.SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean);
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
        TableName + '.' + FParaBirimi.FieldName,
        TableName + '.' + FSembol.FieldName,
        TableName + '.' + FAciklama.FieldName,
        TableName + '.' + FIsVarsayilan.FieldName
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

procedure TSysParaBirimi.Insert(out AID: Integer; APermissionControl: Boolean);
begin
  if IsAuthorized(ptAddRecord, APermissionControl) then
  begin
	  with QueryOfInsert do
	  begin
      Close;
      SQL.Clear;
      SQL.Text := Database.GetSQLInsertCmd(TableName, QRY_PAR_CH, [
        FParaBirimi.FieldName,
        FSembol.FieldName,
        FAciklama.FieldName,
        FIsVarsayilan.FieldName
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
    Self.notify;
  end;
end;

procedure TSysParaBirimi.Update(APermissionControl: Boolean);
begin
  if IsAuthorized(ptUpdate, APermissionControl) then
  begin
	  with QueryOfUpdate do
	  begin
		  Close;
		  SQL.Clear;
		  SQL.Text := Database.GetSQLUpdateCmd(TableName, QRY_PAR_CH, [
        FParaBirimi.FieldName,
        FSembol.FieldName,
        FAciklama.FieldName,
        FIsVarsayilan.FieldName
      ]);

      PrepareUpdateQueryParams;

		  ExecSQL;
		  Close;
	  end;
    Self.notify;
  end;
end;

procedure TSysParaBirimi.BusinessUpdate(APermissionControl: Boolean);
var
  vPara: TSysParaBirimi;
  n1: Integer;
begin
  if (IsVarsayilan.Value) then
  begin
    vPara := TSysParaBirimi.Create(Database);
    try
      vPara.SelectToList('', False, False);
      for n1 := 0 to vPara.List.Count-1 do
      begin
        TSysParaBirimi(vPara.List[n1]).IsVarsayilan.Value := False;
        TSysParaBirimi(vPara.List[n1]).Update(APermissionControl);
      end;
    finally
      FreeAndNil(vPara);
    end;
  end;
  Self.Update(APermissionControl);
end;

function TSysParaBirimi.Clone: TTable;
begin
  Result := TSysParaBirimi.Create(Database);
  CloneClassContent(Self, Result);
end;

end.
