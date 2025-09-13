unit StkKindFamilyService;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  BaseEntity, BaseService, EntityMetaProvider, UnitOfWork,
  StkKindFamilyRepository, StkKindFamily;

type
  TStkKindFamilyService = class(TBaseService<TStkKindFamily>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TStkKindFamily>; override;
    function FindById(AId: Int64; ALock: Boolean): TStkKindFamily; override;
    procedure Add(AEntity: TStkKindFamily); override;
    procedure Update(AEntity: TStkKindFamily); override;
    procedure Delete(AId: Int64); override;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKindFamily; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKindFamily; APermissionControl: Boolean); override;
  end;

implementation

constructor TStkKindFamilyService.Create;
begin
  inherited;
end;

destructor TStkKindFamilyService.Destroy;
begin
  inherited;
end;

procedure TStkKindFamilyService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.StkCinsAileRepository.Find(AFilter, ALock);
  except
    raise;
  end;
end;

procedure TStkKindFamilyService.BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if Self.UoW.StkCinsAileRepository.ExistsByField(AEntity.Family.FieldName, AEntity.Family.Value) then
      Exit;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.StkCinsAileRepository.Add(AEntity);

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

procedure TStkKindFamilyService.BusinessUpdate(AEntity: TStkKindFamily; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.StkCinsAileRepository.Update(AEntity);
    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      Self.UoW.Rollback;
      raise;
    end;
  end;
end;

procedure TStkKindFamilyService.BusinessDelete(AEntity: TStkKindFamily; APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    Self.UoW.BeginTransaction;
    Self.UoW.StkCinsAileRepository.Delete(AEntity.Id.Value);
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

function TStkKindFamilyService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.StkCinsAileRepository.CreateQueryForUI(AFilterKey);
end;

function TStkKindFamilyService.Find(AFilter: string; ALock: Boolean): TList<TStkKindFamily>;
begin
  Result := Self.Uow.StkCinsAileRepository.Find(AFilter, ALock);
end;

function TStkKindFamilyService.FindById(AId: Int64; ALock: Boolean): TStkKindFamily;
begin
  Result := Self.Uow.StkCinsAileRepository.FindById(AId, ALock);
end;

procedure TStkKindFamilyService.Add(AEntity: TStkKindFamily);
begin
  Self.UoW.StkCinsAileRepository.Add(AEntity);
end;

procedure TStkKindFamilyService.Update(AEntity: TStkKindFamily);
begin
  Self.UoW.StkCinsAileRepository.Update(AEntity);
end;

procedure TStkKindFamilyService.Delete(AId: Int64);
begin
  Self.UoW.StkCinsAileRepository.Delete(AId);
end;

end.

