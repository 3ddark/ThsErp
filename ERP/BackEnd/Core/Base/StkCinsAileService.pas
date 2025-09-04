unit StkCinsAileService;

interface

uses
  SysUtils, Classes, Contnrs, Types, BaseService,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  StkCinsAileRepository, StkCinsAile, EntityMetaProvider;

type
  TStkCinsAileService = class(TBaseService)
  protected
    FRepository: TStkCinsAileRepository;
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
    function GetConnection: TFDConnection; override;
    function TableName: string;

    function CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;
    procedure BusinessAdd(AEntity: TStkCinsAile);
  end;

implementation

constructor TStkCinsAileService.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
  FRepository := TStkCinsAileRepository.Create(AConnection);
end;

function TStkCinsAileService.CreateQueryForUI(const AFilterKey: string; AOwner: TComponent): TFDQuery;
begin
  Result := FRepository.CreateQueryForUI('', AOwner);
end;

destructor TStkCinsAileService.Destroy;
begin
  FRepository.Free;
  inherited;
end;

function TStkCinsAileService.GetConnection: TFDConnection;
begin
  Result := FRepository.Connection;
end;

function TStkCinsAileService.TableName: string;
begin
  Result := FRepository.TableName;
end;

procedure TStkCinsAileService.BusinessAdd(AEntity: TStkCinsAile);
begin
  FMetas := TEntityMetaProvider.GetFieldMeta(FRepository.TableName);

  if FRepository.ExistsByField<string>('aile', AEntity.Aile.Value) then
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

