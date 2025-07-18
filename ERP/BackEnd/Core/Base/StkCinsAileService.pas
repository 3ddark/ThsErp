unit StkCinsAileService;

interface

uses
  SysUtils, Classes, Contnrs, Types, ZConnection, ZDataset, BaseService,
  StkCinsAileRepository, StkCinsAile, EntityMetaProvider;

type
  TStkCinsAileService = class(TBaseService)
  private
    FMetas: TArray<TFieldMeta>;
  protected
    FRepository: TStkCinsAileRepository;
  public
    constructor Create(AConnection: TZConnection);
    destructor destroy; override;
    function TableName: string;

    function CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TZQuery;
    procedure BusinessAdd(AEntity: TStkCinsAile);
  end;

implementation

constructor TStkCinsAileService.Create(AConnection: TZConnection);
begin
  inherited Create(AConnection);
  FRepository := TStkCinsAileRepository.Create(AConnection);
end;

function TStkCinsAileService.CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TZQuery;
begin
  Result := FRepository.CreateQueryForUI('', AOwner);
end;

destructor TStkCinsAileService.destroy;
begin
  FRepository.Free;
  inherited;
end;

function TStkCinsAileService.TableName: string;
begin
  Result := FRepository.TableName;
end;

procedure TStkCinsAileService.BusinessAdd(AEntity: TStkCinsAile);
begin
  FMetas := TEntityMetaProvider.GetFieldMeta(FRepository.TableName);

  if FRepository.ExistsByField<string>('aile', AEntity.Aile) then
    Exit;
  try
    FRepository.BeginTransaction;

    FRepository.Save(AEntity);

    FRepository.CommitTransaction;
  except
    on E: Exception do
    begin
      FRepository.RollbackTransaction;
      raise;
    end;
  end;
end;

end.

