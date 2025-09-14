unit UnitOfWork;

interface

uses
  SysUtils, Classes, FireDAC.Comp.Client, FireDAC.Phys,FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error,
  StkKindFamilyRepository,
  SysViewColumn.Repository, SysCountry.Repository, SysRegion.Repository,
  SysCity.Repository;

type
  TUnitOfWork = class
  private
    class var FInstance: TUnitOfWork;
    class var FLock: TObject;
  private
    FConnection: TFDConnection;

    FSysViewColumnRepository: TSysViewColumnRepository;
    FSysCityRepository: TSysCityRepository;
    FSysCountryRepository: TSysCountryRepository;
    FSysRegionRepository: TSysRegionRepository;

    FStkCinsAileRepository: TStkKindFamilyRepository;

    function GetSysViewColumnRepository: TSysViewColumnRepository;
    function GetSysCityRepository: TSysCityRepository;
    function GetSysCountryRepository: TSysCountryRepository;
    function GetSysRegionRepository: TSysRegionRepository;

    function GetStkCinsAileRepository: TStkKindFamilyRepository;

    function GetConnection: TFDConnection;
  protected
    constructor Create(AConnection: TFDConnection);
  public
    destructor Destroy; override;

    class procedure Initialize(AConnection: TFDConnection);
    class function Instance: TUnitOfWork;

    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;

    property Connection: TFDConnection read GetConnection;

    property SysViewColumnRepository: TSysViewColumnRepository read GetSysViewColumnRepository;
    property SysCityRepository: TSysCityRepository read GetSysCityRepository;
    property SysCountryRepository: TSysCountryRepository read GetSysCountryRepository;
    property SysRegionRepository: TSysRegionRepository read GetSysRegionRepository;
    property StkCinsAileRepository: TStkKindFamilyRepository read GetStkCinsAileRepository;
  end;

implementation

constructor TUnitOfWork.Create(AConnection: TFDConnection);
begin
  Self.FConnection := AConnection;
end;

destructor TUnitOfWork.Destroy;
begin
  FreeAndNil(FSysViewColumnRepository);
  FreeAndNil(FSysCountryRepository);
  FreeAndNil(FSysRegionRepository);
  FreeAndNil(FStkCinsAileRepository);

  inherited;
end;

function TUnitOfWork.GetConnection: TFDConnection;
begin
  Result := FInstance.FConnection;
end;

procedure TUnitOfWork.BeginTransaction;
begin
  FInstance.FConnection.StartTransaction;
end;

procedure TUnitOfWork.Commit;
begin
  FInstance.FConnection.Commit;
end;

procedure TUnitOfWork.Rollback;
begin
  FInstance.FConnection.Rollback;
end;

function TUnitOfWork.GetSysViewColumnRepository: TSysViewColumnRepository;
begin
  if Self.FInstance.FSysViewColumnRepository = nil then
    Self.FInstance.FSysViewColumnRepository := TSysViewColumnRepository.Create(FInstance.FConnection);
  Result := Self.FInstance.FSysViewColumnRepository;
end;

function TUnitOfWork.GetSysCountryRepository: TSysCountryRepository;
begin
  if Self.FInstance.FSysCountryRepository = nil then
    Self.FInstance.FSysCountryRepository := TSysCountryRepository.Create(FInstance.FConnection);
  Result := Self.FInstance.FSysCountryRepository;
end;

function TUnitOfWork.GetSysCityRepository: TSysCityRepository;
begin
  if Self.FInstance.FSysCityRepository = nil then
    Self.FInstance.FSysCityRepository := TSysCityRepository.Create(FInstance.FConnection);
  Result := Self.FInstance.FSysCityRepository;
end;

function TUnitOfWork.GetSysRegionRepository: TSysRegionRepository;
begin
  if Self.FInstance.FSysRegionRepository = nil then
    Self.FInstance.FSysRegionRepository := TSysRegionRepository.Create(FInstance.FConnection);
  Result := Self.FInstance.FSysRegionRepository;
end;

function TUnitOfWork.GetStkCinsAileRepository: TStkKindFamilyRepository;
begin
  if Self.FInstance.FStkCinsAileRepository = nil then
    Self.FInstance.FStkCinsAileRepository := TStkKindFamilyRepository.Create(FInstance.FConnection);
  Result := Self.FInstance.FStkCinsAileRepository;
end;

class procedure TUnitOfWork.Initialize(AConnection: TFDConnection);
begin
  if FInstance = nil then
  begin
    TMonitor.Enter(FLock);
    try
      if FInstance = nil then
        FInstance := TUnitOfWork.Create(AConnection);
    finally
      TMonitor.Exit(FLock);
    end;
  end;
end;

class function TUnitOfWork.Instance: TUnitOfWork;
begin
  if FInstance = nil then
    raise Exception.Create('TUnitOfWork not initialized. Call Initialize(AConnection) first.');
  Result := FInstance;
end;

initialization
  TUnitOfWork.FLock := TObject.Create;

finalization
  TUnitOfWork.FInstance.Free;
  TUnitOfWork.FLock.Free;

end.
