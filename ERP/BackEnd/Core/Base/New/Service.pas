unit Service;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections,
  System.Rtti, System.TypInfo, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Data.DB,
  EntityAttributes,
  SharedFormTypes, FilterCriterion, UnitOfWork, Entity, Repository;

type
  IService<T: TEntity> = interface
    ['{61C41E30-4D6E-4474-9529-6BE1133F16B2}']
    function GetUnitOfWork: TUnitOfWork;
    procedure FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);

    property UoW: TUnitOfWork read GetUnitOfWork;
  end;

  IViewService<T: TEntity> = interface(IService<T>)
    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<T>;
    function FindById(AId: Int64; ALock: Boolean): T;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>;
  end;

  ICrudService<T: TEntity> = interface(IViewService<T>)
    procedure Add(AEntity: T);
    procedure Update(AEntity: T);
    procedure Delete(AId: Int64);

    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean);

    function Clone(ASource: T): T;
  end;

  TService<T: TEntity, constructor> = class(TInterfacedObject, IService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  public
    Filter: TFilterCriteria;
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    procedure FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);
  end;

  TViewService<T: TEntity, constructor> = class(TService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  public
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;

    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;
    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<T>; virtual; abstract;
    function FindById(AId: Int64; ALock: Boolean): T; virtual; abstract;

    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T; virtual; abstract;
    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>; virtual; abstract;
  end;

  TCrudService<T: TEntity, constructor> = class(TViewService<T>)
  private
    function GetUnitOfWork: TUnitOfWork;
  public
    property UoW: TUnitOfWork read GetUnitOfWork;

    constructor Create();
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;

//    function CreateQueryForUI(AFilter: TFilterCriteria): TFDQuery; virtual; abstract;
//    function Find(AFilter: TFilterCriteria; ALock: Boolean): TList<T>; virtual; abstract;
//    function FindById(AId: Int64; ALock: Boolean): T; virtual; abstract;
    procedure Add(AEntity: T); virtual; abstract;
    procedure Update(AEntity: T); virtual; abstract;
    procedure Delete(AId: Int64); virtual; abstract;

//    function BusinessFindById(AId: Int64; AWithBegin, ALock, APermissionControl: Boolean): T; virtual; abstract;
//    function BusinessFind(AFilter: TFilterCriteria; AWithBegin, ALock, APermissionControl: Boolean): TList<T>; virtual; abstract;
    procedure BusinessInsert(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessUpdate(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;
    procedure BusinessDelete(AEntity: T; AWithBegin, AWithCommit, APermissionControl: Boolean); virtual; abstract;

    function Clone(ASource: T): T;
  end;

implementation

function TCrudService<T>.Clone(ASource: T): T;
var
  repo: IRepository<T>;
begin
  repo := TRepository<T>.Create(UoW.Connection);
  Result := repo.Clone(ASource);
  repo := nil;
end;

constructor TCrudService<T>.Create();
begin
  inherited;
end;

destructor TCrudService<T>.Destroy;
begin
  inherited;
end;

function TCrudService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

function TCrudService<T>.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
begin
  Result := Self.UoW.IsAuthorized(APermissionType, APermissionControl, AShowException);
end;

constructor TService<T>.Create;
begin
  inherited;
  Filter := TFilterCriteria.Create;
end;

destructor TService<T>.Destroy;
begin
  Filter.Free;
  inherited;
end;

procedure TService<T>.FillEntityFromDataSet(ADataSet: TFDDataSet; AEntity: T);
var
  ctx: TRttiContext;
  rType: TRttiType;
  prop: TRttiProperty;
  colAttr: Column;
  field: TField;
  val: TValue;
  ordValue: Integer;
  //enumType: PTypeInfo;
begin
  if not Assigned(AEntity) or not Assigned(ADataSet) then
    Exit;

  rType := ctx.GetType(AEntity.ClassType);

  for prop in rType.GetProperties do
  begin
    if not prop.IsWritable then
      Continue;

    colAttr := prop.GetAttribute<Column>;
    if Assigned(colAttr) then
      field := ADataSet.FindField(colAttr.Name)
    else
      field := ADataSet.FindField(prop.Name);

     if not Assigned(field) then
      Continue;

    if field.IsNull then
      prop.SetValue(TObject(AEntity), TValue.Empty);

    case prop.PropertyType.TypeKind of
      tkUString, tkString, tkLString, tkWString:
        val := field.AsString;

      tkInteger:
        begin
          // integer, enums (enumlar ordinar olarak tkInteger gelir) vs.
          //enumType := prop.PropertyType.Handle;
          if (prop.PropertyType.IsOrdinal) and (prop.PropertyType.TypeKind = tkInteger) and (prop.PropertyType.Name = '') then
            ; // fallback (rare)

          if  prop.PropertyType.IsOrdinal
          and (prop.PropertyType.TypeKind = tkInteger)
          and (prop.PropertyType.Handle <> nil)
          and (GetTypeData(prop.PropertyType.Handle)^.OrdType <> otSByte)
          then
          begin
            if prop.PropertyType.IsInstance then
              ordValue := field.AsInteger
            else
              ordValue := field.AsInteger;

            val := TValue.FromOrdinal(prop.PropertyType.Handle, ordValue);
          end
          else
            val := field.AsInteger;
        end;

      tkInt64:
        val := TValue.From<Int64>(field.AsLargeInt);

      tkFloat:
        begin
          case field.DataType of
            ftDate, ftTime, ftDateTime, ftTimeStamp:
              val := TValue.From<TDateTime>(field.AsDateTime);
          else
              val := TValue.From<Double>(field.AsFloat);
          end;
        end;

      tkEnumeration:
        begin
          if SameText(prop.PropertyType.Name, 'Boolean') then
            val := TValue.From<Boolean>(field.AsBoolean)
          else
          begin
            if field.DataType in [ftInteger, ftSmallint, ftWord, ftAutoInc] then
              ordValue := field.AsInteger
            else
              ordValue := GetEnumValue(prop.PropertyType.Handle, field.AsString);

            val := TValue.FromOrdinal(prop.PropertyType.Handle, ordValue);
          end;
        end;

      tkClass:
        begin
          // Eğer property bir entity referansı ise (ör. BelongsTo) -> atamak için özel mantık gerekebilir
          // Şimdilik atlama:
          Continue;
        end;
    else
      // bilinmeyen tipleri atla
      Continue;
    end;

    prop.SetValue(TObject(AEntity), val);
  end;
end;

function TService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

constructor TViewService<T>.Create;
begin
  inherited;
end;

destructor TViewService<T>.Destroy;
begin
  inherited;
end;

function TViewService<T>.GetUnitOfWork: TUnitOfWork;
begin
  Result := TUnitOfWork.Instance;
end;

function TViewService<T>.IsAuthorized(APermissionType: TPermissionType; APermissionControl, AShowException: Boolean): Boolean;
begin
  Result := Self.UoW.IsAuthorized(APermissionType, APermissionControl, AShowException);
end;

end.

