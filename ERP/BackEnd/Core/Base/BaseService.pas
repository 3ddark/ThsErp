unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.Client, System.Generics.Collections,
  EntityMetaProvider, UnitOfWork, BaseRepository, BaseEntity;

const
  KeyStkCinsAile = 'StkCinsAile';
  KeySysParaBirimi = 'SysParaBirimi';

type
  IBaseService<T> = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
    function GetUnitOfWork: TUnitOfWork;
    property UoW: TUnitOfWork read GetUnitOfWork;

    function CreateQueryForUI(const AFilterKey: string): string;
    function Find(AFilter: string; ALock: Boolean): TList<T>;
    function FindById(AId: Integer; ALock: Boolean): T;
    procedure Save(AEntity: T);
    procedure Delete(AId: Integer);
  end;

  TBaseService<T> = class(TInterfacedObject, IBaseService<T>)
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

    function CreateQueryForUI(const AFilterKey: string): string; virtual; abstract;
    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual; abstract;
    function FindById(AId: Integer; ALock: Boolean): T; virtual; abstract;
    procedure Save(AEntity: T); virtual; abstract;
    procedure Delete(AId: Integer); virtual; abstract;

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

