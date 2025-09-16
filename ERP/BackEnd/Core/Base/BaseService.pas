unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.Client, System.Generics.Collections,
  SharedFormTypes, UnitOfWork;

type
  IBaseService<T> = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
    function GetUnitOfWork: TUnitOfWork;
    property UoW: TUnitOfWork read GetUnitOfWork;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;

    function CreateQueryForUI(const AFilterKey: string): string;
    function Find(AFilter: string; ALock: Boolean): TList<T>;
    function FindById(AId: Int64; ALock: Boolean): T;
    procedure Add(AEntity: T);
    procedure Update(AEntity: T);
    procedure Delete(AId: Int64);

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T;
    function BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<T>;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
  end;

  TBaseService<T> = class(TInterfacedObject, IBaseService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  public
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;

    function CreateQueryForUI(const AFilterKey: string): string; virtual; abstract;
    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual; abstract;
    function FindById(AId: Int64; ALock: Boolean): T; virtual; abstract;
    procedure Add(AEntity: T); virtual; abstract;
    procedure Update(AEntity: T); virtual; abstract;
    procedure Delete(AId: Int64); virtual; abstract;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T; virtual; abstract;
    function BusinessFind(AFilter: string; AWithBegin, ALock, APermissionControl: Boolean): TList<T>; virtual; abstract;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
  end;

implementation

constructor TBaseService<T>.Create();
begin
  inherited Create;
end;

destructor TBaseService<T>.Destroy;
begin
  inherited;
end;

function TBaseService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

function TBaseService<T>.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
begin
  Result := Self.UoW.IsAuthorized(APermissionType, APermissionControl, AShowException);
end;

end.

