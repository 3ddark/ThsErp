unit BaseService;

interface

uses
  SysUtils, Classes, Types, FireDAC.Comp.Client, System.Generics.Collections,
  UnitOfWork, BaseRepository, BaseEntity;

type
  IBaseService<T> = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
    function GetUnitOfWork: TUnitOfWork;
    property UoW: TUnitOfWork read GetUnitOfWork;

    function CreateQueryForUI(const AFilterKey: string): string;
    function Find(AFilter: string; ALock: Boolean): TList<T>;
    function FindById(AId: Int64; ALock: Boolean): T;
    procedure Add(AEntity: T);
    procedure Update(AEntity: T);
    procedure Delete(AId: Int64);

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessUpdate(AEntity: T; APermissionControl: Boolean);
    procedure BusinessDelete(AEntity: T; APermissionControl: Boolean);
  end;

  TBaseService<T> = class(TInterfacedObject, IBaseService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  protected
    function IsAuthorized(): Boolean;
  public
    constructor Create();
    destructor Destroy; override;

    property UoW: TUnitOfWork read GetUnitOfWork;

    function CreateQueryForUI(const AFilterKey: string): string; virtual; abstract;
    function Find(AFilter: string; ALock: Boolean): TList<T>; virtual; abstract;
    function FindById(AId: Int64; ALock: Boolean): T; virtual; abstract;
    procedure Add(AEntity: T); virtual; abstract;
    procedure Update(AEntity: T); virtual; abstract;
    procedure Delete(AId: Int64); virtual; abstract;

    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessUpdate(AEntity: T; APermissionControl: Boolean); virtual; abstract;
    procedure BusinessDelete(AEntity: T; APermissionControl: Boolean); virtual; abstract;
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

function TBaseService<T>.IsAuthorized: Boolean;
begin
  Result := True;
end;

end.

