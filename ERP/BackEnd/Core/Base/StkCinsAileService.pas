unit StkCinsAileService;

interface

uses
  SysUtils, Classes, Contnrs, Types, BaseService,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  BaseEntity, EntityMetaProvider, UnitOfWork, StkCinsAileRepository, StkCinsAile;

type
  TStkCinsAileService = class(TBaseService<TStkCinsAile>)
  public
    constructor Create;
    destructor Destroy; override;
    function TableName: string;

    function CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TStkCinsAile; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TStkCinsAile; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TStkCinsAile; APermissionControl: Boolean); override;
  end;

implementation

procedure TStkCinsAileService.BusinessDelete(AEntity: TStkCinsAile; APermissionControl: Boolean);
begin
//
end;

procedure TStkCinsAileService.BusinessInsert(AEntity: TStkCinsAile; AWithBegin, AWithCommit, APermissionControl: Boolean);
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

procedure TStkCinsAileService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  Self.UoW.StkCinsAileRepository.Find(AFilter, ALock);
end;

procedure TStkCinsAileService.BusinessUpdate(AEntity: TStkCinsAile; APermissionControl: Boolean);
begin
//
end;

constructor TStkCinsAileService.Create;
begin
  inherited;
end;

function TStkCinsAileService.CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;
begin
  Result := Self.UoW.StkCinsAileRepository.CreateQueryForUI(AFilterKey, AOwner);
end;

destructor TStkCinsAileService.Destroy;
begin
  inherited;
end;

function TStkCinsAileService.TableName: string;
begin
  Result := '';
end;

end.

