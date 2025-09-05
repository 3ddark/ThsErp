unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.Client,
  EntityMetaProvider, UnitOfWork, BaseRepository, BaseEntity;

const
  KeyStkCinsAile = 'StkCinsAile';
  KeySysParaBirimi = 'SysParaBirimi';

type
  IBaseService = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
  end;

  TBaseService<T> = class(TInterfacedObject, IBaseService)
  private
    FUoW: TUnitOfWork;
    function GetUnitOfWork: TUnitOfWork;
  protected
    FMetas: TArray<TFieldMeta>;
    function IsAuthorized(): Boolean;
  public
    constructor Create();
    destructor Destroy; override;

    property UoW: TUnitOfWork read GetUnitOfWork;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); virtual;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual;
    procedure BusinessUpdate(AEntity: T; APermissionControl: Boolean); virtual;
    procedure BusinessDelete(AEntity: T; APermissionControl: Boolean); virtual;
  end;

implementation

procedure TBaseService<T>.BusinessDelete(AEntity: T; APermissionControl: Boolean);
begin
  //
end;

procedure TBaseService<T>.BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
begin
  //
end;

procedure TBaseService<T>.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  //
end;

procedure TBaseService<T>.BusinessUpdate(AEntity: T; APermissionControl: Boolean);
begin
  //
end;

constructor TBaseService<T>.Create();
begin
  inherited Create;
  //
end;

destructor TBaseService<T>.Destroy;
begin
  FUoW.Free;
  inherited;
end;

function TBaseService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := FUoW;
end;

function TBaseService<T>.IsAuthorized: Boolean;
begin
  Result := True;
end;

end.

