unit Ths.Database;

interface

{$I Ths.inc}

uses
  System.DateUtils, System.StrUtils, System.Classes, System.SysUtils,
  System.Variants, System.Rtti, Vcl.Forms, Vcl.Dialogs, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt,
  FireDAC.Phys.PGDef, FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Comp.DataSet,
  Ths.Database.Sql.Builder;

{$M+}

type
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

type
  TDatabase = class
  private
    FConnection: TFDConnection;
    FPhysPG: TFDPhysPgDriverLink;
    FQueryOfDatabase: TFDQuery;
    FSQLBuilder: TThsSqlBuilder;

    FNewRecordId: Integer;

    FDateDB: TDate; //Used for today date controls. Data came from the SQL server during the login process
  protected
    property QueryOfDataBase: TFDQuery read FQueryOfDatabase;

    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnBeforeDisconnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
    procedure ConnAfterDisconnect(Sender: TObject);
    procedure ConnOnStartTransaction(Sender: TObject);
    procedure ConnOnCommit(Sender: TObject);
    procedure ConnOnRollback(Sender: TObject);
  public
    property Connection: TFDConnection read FConnection write FConnection;
    property NewRecordId: Integer read FNewRecordId write FNewRecordId;
    property DateDB: TDate read FDateDB write FDateDB;

    property SQLBuilder: TThsSqlBuilder read FSQLBuilder write FSQLBuilder;

    constructor Create;
    function GetNewRecordId: Integer;

    function NewQuery(AConnection: TFDConnection = nil): TFDQuery;
    function NewStoredProcedure(AConnection: TFDConnection = nil): TFDStoredProc;
    function NewDataSource(ADataset: TDataSet): TDataSource;
    function NewConnection: TFDConnection;
  published
    destructor Destroy; override;
    function GetToday: TDateTime;
    function GetNow(AOnlyTime: Boolean = True): TDateTime;
    procedure ConfigureConnection(AHostName, ADatabase, AUser, APassword: string; APort: Integer);
  end;

implementation

uses
  Ths.Globals,
  Ths.Database.Table;

procedure TDatabase.ConfigureConnection(AHostName, ADatabase, AUser, APassword: string; APort: Integer);
begin
  if FConnection.Connected then
    FConnection.Close;

  FConnection.Name := 'ConApp';
  FConnection.DriverName := 'PG';
  with FConnection.Params as TFDPhysPGConnectionDefParams do
  begin
    Server := AHostName;
    Database := ADatabase;
    UserName := AUser;
    Password := APassword;
    Port := APort;
    CharacterSet := TFDPGCharacterSet.csUTF8;
  end;
  FConnection.LoginPrompt := False;

  FPhysPG := TFDPhysPgDriverLink.Create(nil);
  FPhysPG.VendorLib := GUygulamaAnaDizin + PathDelim + 'lib' + PathDelim + 'libpq.dll';
end;

procedure TDatabase.ConnBeforeConnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnAfterConnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnBeforeDisconnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnAfterDisconnect(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnOnStartTransaction(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnOnCommit(Sender: TObject);
begin
//
end;

procedure TDatabase.ConnOnRollback(Sender: TObject);
begin
//
end;

constructor TDatabase.Create();
begin
  if Self.FConnection <> nil then
    Abort
  else
  begin
    inherited;

    GUygulamaAnaDizin := ExtractFilePath(Application.ExeName);

    FConnection := TFDConnection.Create(nil);
    FConnection.BeforeConnect       := ConnBeforeConnect;
    FConnection.BeforeDisconnect    := ConnBeforeDisconnect;
    FConnection.AfterConnect        := ConnAfterConnect;
    FConnection.AfterDisconnect     := ConnAfterDisconnect;
    FConnection.BeforeStartTransaction := ConnOnStartTransaction;
    FConnection.AfterCommit         := ConnOnCommit;
    FConnection.AfterRollback       := ConnOnRollback;

    FQueryOfDatabase := NewQuery;

    FSQLBuilder := TThsSqlBuilder.Create;
  end;
end;

destructor TDatabase.Destroy;
begin
  FSQLBuilder.Free;
  FQueryOfDatabase.Free;
  FConnection.Free;
  FPhysPG.Free;
  inherited;
end;

function TDatabase.GetNewRecordId: Integer;
begin
  Dec(FNewRecordId, 1);
  Result := FNewRecordId;
end;

function TDatabase.GetNow(AOnlyTime: Boolean = True): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT cast(NOW() as timestamp without time zone);';
    Open;
    while not EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;

  if AOnlyTime then
    Result := TimeOf(Result);
end;

function TDatabase.GetToday(): TDateTime;
begin
  Result := 0;
  with QueryOfDataBase do
  begin
    Close;
    SQL.Text := 'SELECT CURRENT_DATE;';
    Open;
    while NOT EOF do
    begin
      Result := Fields.Fields[0].AsDateTime;
      Next;
    end;
    EmptyDataSet;
    Close;
  end;
end;

function TDatabase.NewConnection: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
end;

function TDatabase.NewQuery(AConnection: TFDConnection = nil): TFDQuery;
begin
  Result := TFDQuery.Create(nil);

  if AConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := AConnection;
end;

function TDatabase.NewStoredProcedure(AConnection: TFDConnection = nil): TFDStoredProc;
begin
  Result := TFDStoredProc.Create(nil);

  if AConnection = nil then
    Result.Connection := Self.FConnection
  else
    Result.Connection := AConnection;
end;

function TDatabase.NewDataSource(ADataset: TDataSet): TDataSource;
begin
  Result := TDataSource.Create(nil);
  Result.DataSet := ADataset;
  Result.Enabled := True;
  Result.AutoEdit := True;
end;

end.
