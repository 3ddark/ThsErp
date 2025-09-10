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
    function FindById(AId: Integer; ALock: Boolean): TStkKindFamily; override;
    procedure Save(AEntity: TStkKindFamily); override;
    procedure Delete(AId: Integer); override;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkKindFamily; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkKindFamily; APermissionControl: Boolean); override;
  end;

implementation

procedure TStkKindFamilyService.BusinessDelete(AEntity: TStkKindFamily; APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.StkCinsAileRepository.Delete(AEntity.Id.Value);
end;

procedure TStkKindFamilyService.BusinessInsert(AEntity: TStkKindFamily; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.StkCinsAileRepository.Save(AEntity);

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

{
  FMetas := TEntityMetaProvider.GetFieldMeta(FRepository.TableName);

  if FRepository.ExistsByField<string>(AEntity.Aile.FieldName, AEntity.Aile.Value) then
    Exit;
  try
    Self.UoW.BeginTransaction;

    FRepository.Save(AEntity);

    Self.UoW.Commit;
  except
    on E: Exception do
    begin
      Self.UoW.Rollback;
      raise;
    end;
  end;
}
end;

procedure TStkKindFamilyService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.StkCinsAileRepository.Find(AFilter, ALock);
end;

procedure TStkKindFamilyService.BusinessUpdate(AEntity: TStkKindFamily; APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.StkCinsAileRepository.Save(AEntity)
end;

constructor TStkKindFamilyService.Create;
begin
  inherited;
end;

function TStkKindFamilyService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.StkCinsAileRepository.CreateQueryForUI(AFilterKey);
end;

procedure TStkKindFamilyService.Delete(AId: Integer);
begin
  inherited;
//
end;

destructor TStkKindFamilyService.Destroy;
begin
  inherited;
end;

function TStkKindFamilyService.Find(AFilter: string; ALock: Boolean): TList<TStkKindFamily>;
begin
  Result := Self.Uow.StkCinsAileRepository.Find(AFilter, ALock);
end;

function TStkKindFamilyService.FindById(AId: Integer; ALock: Boolean): TStkKindFamily;
begin
  Result := Self.Uow.StkCinsAileRepository.FindById(AId, ALock);
end;

procedure TStkKindFamilyService.Save(AEntity: TStkKindFamily);
begin
  Self.Uow.StkCinsAileRepository.Save(AEntity);
end;

end.

