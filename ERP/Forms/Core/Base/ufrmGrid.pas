unit ufrmGrid;

// Liste ekranı tabanı: TfrmGridBase (tipten bağımsız tüm davranış) + Service / Table köprüsü.
// Kullanım: TfrmXxxs = class(TfrmGrid<TXxx, TXxxService>)

interface

uses
  System.SysUtils, System.Classes, System.Rtti, System.TypInfo, Vcl.Forms, Data.DB,
  FireDAC.Comp.Client, SharedFormTypes, Entity, Service, UnitOfWork, ufrmGridBase;

type
  TfrmGrid<TE: TEntity, constructor; TS: TCrudService<TE>> = class(TfrmGridBase)
  private
    FService: TS;
    FTable: TE;
  protected
    function CreateGridQuery: TFDQuery; override;
    function GetUoW: TUnitOfWork; override;
    function EntityClass: TClass; override;
    function CurrentRecordId: Int64; override;
    function IsAuthorizedFor(APermissionType: TPermissionType): Boolean; override;
  public
    property Service: TS read FService write FService;
    property Table: TE read FTable write FTable;

    // Grid servisi ve Table'ı sahiplenir (form kapanınca serbest bırakılır)
    constructor Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase: Boolean = True; AUseHelper: Boolean = False); reintroduce; overload;
    destructor Destroy; override;

    procedure SetSelectedItem; override;
    procedure FillNotMappedFromDataSet;
    procedure ShowInputForm(Sender: TObject; AFormType: TInputFormMode); override;
  end;

implementation

uses
  EntityAttributes;

constructor TfrmGrid<TE, TS>.Create(AOwner: TComponent; AService: TS; ATable: TE; ACreateNewBase, AUseHelper: Boolean);
begin
  // Taban kurulum sorguyu servisten ister (CreateGridQuery): önce servis / tablo atanır
  FService := AService;
  FTable := ATable;
  inherited CreateGrid(AOwner, ACreateNewBase, AUseHelper);
end;

destructor TfrmGrid<TE, TS>.Destroy;
begin
  // Sorgu servisin bağlantısını kullanır: servisten önce kapanıp serbest kalır
  ReleaseGridData;
  FreeAndNil(FService);
  FreeAndNil(FTable);
  inherited;
end;

function TfrmGrid<TE, TS>.CreateGridQuery: TFDQuery;
begin
  Result := FService.CreateQueryForUI(nil);
end;

function TfrmGrid<TE, TS>.GetUoW: TUnitOfWork;
begin
  Result := nil;
  if Assigned(FService) then
    Result := FService.UoW;
end;

function TfrmGrid<TE, TS>.EntityClass: TClass;
begin
  Result := TE;
end;

function TfrmGrid<TE, TS>.CurrentRecordId: Int64;
begin
  Result := 0;
  if Assigned(FTable) then
    Result := FTable.Id;
end;

function TfrmGrid<TE, TS>.IsAuthorizedFor(APermissionType: TPermissionType): Boolean;
begin
  Result := Service.IsAuthorized(APermissionType, True);
end;

procedure TfrmGrid<TE, TS>.SetSelectedItem;
begin
  Service.FillEntityFromDataSet(Qry, Table);
  FillNotMappedFromDataSet;
end;

// [NotMapped] metin özelliklerini (görünen adlar: UomName, CountryName ...) aynı adlı snake_case
// grid kolonundan doldurur; helper dönüşünde edit'e yazılan ad override unutulsa da boş kalmaz
procedure TfrmGrid<TE, TS>.FillNotMappedFromDataSet;
var
  LCtx: TRttiContext;
  LProp: TRttiProperty;
  LAttr: TCustomAttribute;
  LIsNotMapped: Boolean;
  LField: TField;
  LName: string;
  i: Integer;
begin
  if not Assigned(Qry) or not Qry.Active or Qry.IsEmpty or not Assigned(Table) then
    Exit;

  for LProp in LCtx.GetType(TClass(TE)).GetProperties do
  begin
    if not LProp.IsWritable or (LProp.PropertyType.TypeKind <> tkUString) then
      Continue;

    LIsNotMapped := False;
    for LAttr in LProp.GetAttributes do
      if LAttr is NotMapped then
        LIsNotMapped := True;
    if not LIsNotMapped then
      Continue;

    LName := '';
    for i := 1 to Length(LProp.Name) do
      if CharInSet(LProp.Name[i], ['A'..'Z']) then
      begin
        if i > 1 then
          LName := LName + '_';
        LName := LName + LowerCase(LProp.Name[i]);
      end
      else
        LName := LName + LProp.Name[i];

    LField := Qry.FindField(LName);
    if Assigned(LField) then
      LProp.SetValue(TObject(Table), LField.AsString);
  end;
end;

procedure TfrmGrid<TE, TS>.ShowInputForm(Sender: TObject; AFormType: TInputFormMode);
var
  LForm: TForm;
  LId: Int64;
begin
  // Yetki yoksa form açılmadan uyar (F7 / menü / buton hangisiyle gelinirse gelsin)
  if (AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord) then
    Service.UoW.EnsureAuthorized(Service.PermissionCode, ptAddRecord, True);

  if (AFormType = ifmRewiev)
  or ((not Service.UoW.InTransaction) and ((AFormType = ifmNewRecord) or (AFormType = ifmCopyNewRecord)))
  then
  begin
    if (AFormType = ifmRewiev) or (AFormType = ifmCopyNewRecord) then
    begin
      LId := Table.Id;
      FreeAndNil(FTable);
      FTable := Service.BusinessFindById(LId, False, False, True);
    end;
    LForm := CreateInputForm(Sender, AFormType);
    // Salt okunur listelerde giriş formu yok (CreateInputForm = nil): çift tık / Enter AV vermesin
    if LForm = nil then
      Exit;
    LForm.Show;
  end
  else
    raise Exception.Create('Başka bir pencere giriş veya güncelleme için açılmış, önce bu işlemi tamamlayın.');
end;

end.
