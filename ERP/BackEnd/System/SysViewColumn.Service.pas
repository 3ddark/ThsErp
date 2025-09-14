unit SysViewColumn.Service;

interface

uses
  SysUtils, Classes, Contnrs, Types, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  BaseEntity, BaseService, EntityMetaProvider, UnitOfWork,
  SysViewColumn.Repository, SysViewColumn;

type
  TSysViewColumnService = class(TBaseService<TSysViewColumn>)
  public
    constructor Create;
    destructor Destroy; override;

    function CreateQueryForUI(const AFilterKey: string): string; override;
    function Find(AFilter: string; ALock: Boolean): TList<TSysViewColumn>; override;
    function FindById(AId: Int64; ALock: Boolean): TSysViewColumn; override;
    procedure Add(AEntity: TSysViewColumn);  override;
    procedure Update(AEntity: TSysViewColumn); override;
    procedure Delete(AId: Int64); override;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TSysViewColumn; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysViewColumn; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysViewColumn; APermissionControl: Boolean); override;
  end;

implementation

constructor TSysViewColumnService.Create;
begin
  inherited;
end;

destructor TSysViewColumnService.Destroy;
begin
  inherited;
end;

procedure TSysViewColumnService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.SysViewColumnRepository.Find(AFilter, ALock);
end;

procedure TSysViewColumnService.BusinessInsert(AEntity: TSysViewColumn; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  try
    if APermissionControl then
    begin
      //CheckPermission if not throw exception
    end;

    if AWithBegin then
      Self.UoW.BeginTransaction;

    Self.UoW.SysViewColumnRepository.Add(AEntity);

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

procedure TSysViewColumnService.BusinessUpdate(AEntity: TSysViewColumn; APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.SysViewColumnRepository.Update(AEntity)
end;

procedure TSysViewColumnService.BusinessDelete(AEntity: TSysViewColumn; APermissionControl: Boolean);
begin
  if APermissionControl then
  begin
    //CheckPermission if not throw exception
  end;

  Self.UoW.SysViewColumnRepository.Delete(AEntity.Id.Value);
end;

function TSysViewColumnService.CreateQueryForUI(const AFilterKey: string): string;
begin
  Result := Self.UoW.SysViewColumnRepository.CreateQueryForUI(AFilterKey);
end;

function TSysViewColumnService.Find(AFilter: string; ALock: Boolean): TList<TSysViewColumn>;
begin
  Result := Self.Uow.SysViewColumnRepository.Find(AFilter, ALock);
end;

function TSysViewColumnService.FindById(AId: Int64; ALock: Boolean): TSysViewColumn;
begin
  Result := Self.Uow.SysViewColumnRepository.FindById(AId, ALock);
end;

procedure TSysViewColumnService.Add(AEntity: TSysViewColumn);
begin
  Self.UoW.SysViewColumnRepository.Add(AEntity);
end;

procedure TSysViewColumnService.Update(AEntity: TSysViewColumn);
begin
  Self.UoW.SysViewColumnRepository.Update(AEntity);
end;

procedure TSysViewColumnService.Delete(AId: Int64);
begin
  Self.UoW.SysViewColumnRepository.Delete(AId);
end;

end.

