unit Ths.Database;

interface

{$I Ths.inc}

uses
  System.DateUtils, System.StrUtils, System.Classes, System.SysUtils,
  System.Variants, System.Rtti, Vcl.Forms, Vcl.Dialogs, Data.DB,
  FireDAC.Phys, FireDAC.Phys.Intf, FireDAC.Phys.PGDef, FireDAC.Phys.PG,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Stan.Param, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.DatS, FireDAC.DApt, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Ths.Database.Sql.Builder;

{$M+}

type
  TPermissionType = (ptRead, ptAddRecord, ptUpdate, ptDelete, ptSpecial);

type
  TDatabase = class
  private
    FConnection: TFDConnection;
    FEventAlerter: TFDEventAlerter;
    FPhysPG: TFDPhysPgDriverLink;
    FQueryOfDatabase: TFDQuery;
    FSQLBuilder: TThsSqlBuilder;

    FNewRecordId: Integer;

    FDateDB: TDate;//Used for today date controls. Data came from the SQL server during the login process
  protected
    property QueryOfDataBase: TFDQuery read FQueryOfDatabase;

    procedure ConnBeforeConnect(Sender: TObject);
    procedure ConnBeforeDisconnect(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
    procedure ConnAfterDisconnect(Sender: TObject);
    procedure ConnOnStartTransaction(Sender: TObject);
    procedure ConnOnCommit(Sender: TObject);
    procedure ConnOnRollback(Sender: TObject);

    procedure DoAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
  public
    property Connection: TFDConnection read FConnection write FConnection;
    property EventAlerter: TFDEventAlerter read FEventAlerter write FEventAlerter;
    property NewRecordId: Integer read FNewRecordId write FNewRecordId;
    property DateDB: TDate read FDateDB write FDateDB;

    property SQLBuilder: TThsSqlBuilder read FSQLBuilder write FSQLBuilder;

    constructor Create;
    function GetNewRecordId: Integer;

    function NewQuery(AConnection: TFDConnection = nil): TFDQuery;
    function NewStoredProcedure(AConnection: TFDConnection = nil): TFDStoredProc;
    function NewDataSource(ADataset: TDataSet): TDataSource;
    class function NewConnection: TFDConnection;

    procedure AddListenEventName(AEventName: string);
    procedure RemoveListenEventName(AEventName: string; AForm: TForm);
  published
    destructor Destroy; override;
    function GetToday: TDateTime;
    function GetNow(AOnlyTime: Boolean = True): TDateTime;
    procedure ConfigureConnection(AHostName, ADatabase, AUser, APassword: string; APort: Integer);
    function GetConnectionPID: Integer;
  end;

implementation

uses
  Ths.Globals, Ths.Database.Table, ufrmBaseDBGrid;

procedure TDatabase.AddListenEventName(AEventName: string);
begin
  //Aktif ise önce Pasif yapıp Names kısmını dolduruyoruz.
  //Active işleminde Names içindeki bilgileri dinliyor. Sonradan ekleme ile çalışmıyor
  if Self.EventAlerter.Active then
    Self.EventAlerter.Active := False;
  if Self.EventAlerter.Names.IndexOf(AEventName) = -1 then
    Self.EventAlerter.Names.Add(AEventName);
  if not Self.EventAlerter.Active then
    Self.EventAlerter.Active := True;
end;

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

    FConnection := TDatabase.NewConnection;
    FConnection.BeforeConnect       := ConnBeforeConnect;
    FConnection.BeforeDisconnect    := ConnBeforeDisconnect;
    FConnection.AfterConnect        := ConnAfterConnect;
    FConnection.AfterDisconnect     := ConnAfterDisconnect;
    FConnection.BeforeStartTransaction := ConnOnStartTransaction;
    FConnection.AfterCommit         := ConnOnCommit;
    FConnection.AfterRollback       := ConnOnRollback;

    EventAlerter := TFDEventAlerter.Create(nil);
    EventAlerter.Connection := FConnection;
    EventAlerter.OnAlert := DoAlert;
    EventAlerter.Options.Kind := 'Notifies';
    EventAlerter.Options.Synchronize := True;
    EventAlerter.Options.Timeout := 10000;


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
  FEventAlerter.Free;
  inherited;
end;

procedure TDatabase.DoAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
var
  n1: Integer;
  x: TObject;
begin
  if AEventName <> '' then
  begin
    x := TObject.Create;
    try
      System.TMonitor.Enter(x);

      for n1 := 0 to Screen.FormCount-1 do
      begin
        if Screen.Forms[n1].ClassParent = TfrmBaseDBGrid then
        begin
          if TfrmBaseDBGrid(Screen.Forms[n1]).Table.TableName = AEventName then
          begin
            if  Assigned(TfrmBaseDBGrid(Screen.Forms[n1]).grd)
            and Assigned(TfrmBaseDBGrid(Screen.Forms[n1]).grd.DataSource)
            and Assigned(TfrmBaseDBGrid(Screen.Forms[n1]).grd.DataSource.DataSet)
            then
              TfrmBaseDBGrid(Screen.Forms[n1]).grd.DataSource.DataSet.Refresh;
          end;
        end;
      end;
    finally
      System.TMonitor.Exit(x);
      x.Free;
    end;
  end
  else
    ShowMessage('Else Event');
end;

function TDatabase.GetConnectionPID: Integer;
begin
  Result := 0;

  with NewQuery() do
  try
    Close;
    SQL.Text := 'SELECT pg_backend_pid()';
    Open;
    while not EOF do
    begin
      Result := Fields.Fields[0].AsInteger;
      Next;
    end;
    EmptyDataSet;
    Close;
  finally
    Free;
  end;
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

class function TDatabase.NewConnection: TFDConnection;
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

procedure TDatabase.RemoveListenEventName(AEventName: string; AForm: TForm);
var
  n1, LCount: Integer;
begin
  Self.EventAlerter.Active := False;
  try
    if Self.EventAlerter.Names.Count > 0 then
    begin
      LCount := 0;
      for n1 := 0 to Screen.FormCount-1 do
      begin
        if Screen.Forms[n1].ClassParent = TfrmBaseDBGrid then
        begin
          if Screen.Forms[n1] <> AForm then
          begin
            if TfrmBaseDBGrid(Screen.Forms[n1]).Table.TableName = AEventName then
              Inc(LCount);
            Break;
          end;
        end;
      end;
      if (LCount = 0) and (Self.EventAlerter.Names.IndexOf(AEventName) > -1) then
        Self.EventAlerter.Names.Delete(Self.EventAlerter.Names.IndexOf(AEventName));
    end;
  finally
    Self.EventAlerter.Active := (Self.EventAlerter.Names.Count > 0);
  end;
end;

function TDatabase.NewDataSource(ADataset: TDataSet): TDataSource;
begin
  Result := TDataSource.Create(nil);
  Result.DataSet := ADataset;
  Result.Enabled := True;
  Result.AutoEdit := True;
end;

end.
