unit SysParaBirimiService;

interface

uses
  SysUtils, Classes, Contnrs, Types, BaseService,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  SysParaBirimiRepository, SysParaBirimi, EntityMetaProvider;

type
  TSysParaBirimiService = class(TBaseService<TSysParaBirimi>)
  private
    FMetas: TArray<TFieldMeta>;
  protected
    FRepository: TSysParaBirimiRepository;
  public
    constructor Create;
    destructor Destroy; override;
    function TableName: string;

    function CreateQueryForUI(): TFDQuery;

    procedure Save(AEntity: TSysParaBirimi);
    procedure Delete(AId: Integer);

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); override;
    procedure BusinessInsert(AEntity: TSysParaBirimi; AWithBegin, AWithCommit, APermissionControl: Boolean); override;
    procedure BusinessUpdate(AEntity: TSysParaBirimi; APermissionControl: Boolean); override;
    procedure BusinessDelete(AEntity: TSysParaBirimi; APermissionControl: Boolean); override;
  end;

implementation

procedure TSysParaBirimiService.BusinessDelete(AEntity: TSysParaBirimi; APermissionControl: Boolean);
begin
//
end;

procedure TSysParaBirimiService.BusinessInsert(AEntity: TSysParaBirimi; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
//
end;

procedure TSysParaBirimiService.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
//
end;

procedure TSysParaBirimiService.BusinessUpdate(AEntity: TSysParaBirimi; APermissionControl: Boolean);
begin
//
end;

constructor TSysParaBirimiService.Create;
begin
  inherited Create;
end;

function TSysParaBirimiService.CreateQueryForUI(): TFDQuery;
begin
  Result := UoW.SysParaBirimiRepository.CreateQueryForUI();
end;

destructor TSysParaBirimiService.Destroy;
begin
  inherited;
end;

function TSysParaBirimiService.TableName: string;
begin
  Result := '';
end;

procedure TSysParaBirimiService.Save(AEntity: TSysParaBirimi);
begin
  FMetas := TEntityMetaProvider.GetFieldMeta(FRepository.TableName);

  if FRepository.ExistsByField<string>(AEntity.Para.FieldName, AEntity.Para.Value) then
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
end;

procedure TSysParaBirimiService.Delete(AId: Integer);
begin
//
end;

end.

