unit SysCountry.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  BaseEntity, BaseService, EntityMetaProvider, UnitOfWork,
  SysCountry.Repository, SysCountry;

type
  TSysCountryService = class(TBaseService<TSysCountry>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysCountry>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysCountry; override;
    procedure Add(AEntity: TSysCountry); override;
    procedure Update(AEntity: TSysCountry); override;
    procedure Delete(AId: Int64); override;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysCountry; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysCountry; APermissionControl: Boolean); override;
  end;

implementation

constructor TSysCountryService.Create;
begin
  inherited;
end;

destructor TSysCountryService.Destroy;
begin
  inherited;
end;

procedure TSysCountryService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.SysCountryRepository.Find(AFilter, ALock);
  except
    raise;
  end;
end;

procedure TSysCountryService.BusinessInsert(AEntity: TSysCountry; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if Self.UoW.SysCountryRepository.ExistsByField(AEntity.CountryCode.FieldName, AEntity.CountryCode.Value) then
      Exit;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysCountryRepository.Add(AEntity);

    if AWithCommit and Uow.Connection.InTransaction then
      Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.Connection.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

procedure TSysCountryService.BusinessUpdate(AEntity: TSysCountry; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.SysCountryRepository.Update(AEntity);
    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TSysCountryService.BusinessDelete(AEntity: TSysCountry; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.SysCountryRepository.Delete(AEntity.Id.Value);
    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      if Uow.Connection.InTransaction then
        Self.UoW.Rollback;
      raise
    end;
  end;
end;

function TSysCountryService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.SysCountryRepository.CreateQueryForUI(AFilterKey);
end;

function TSysCountryService.Find(AFilter: string; ALock: Boolean): TList<TSysCountry>;
begin
  Result := Self.Uow.SysCountryRepository.Find(AFilter, ALock);
end;

function TSysCountryService.FindById(AId: Int64; ALock: Boolean): TSysCountry;
begin
  Result := Self.Uow.SysCountryRepository.FindById(AId, ALock);
end;

procedure TSysCountryService.Add(AEntity: TSysCountry);
begin
  Self.UoW.SysCountryRepository.Add(AEntity);
end;

procedure TSysCountryService.Update(AEntity: TSysCountry);
begin
  Self.UoW.SysCountryRepository.Update(AEntity);
end;

procedure TSysCountryService.Delete(AId: Int64);
begin
  Self.UoW.SysCountryRepository.Delete(AId);
end;

end.

