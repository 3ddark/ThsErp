unit Ths.Erp.Database.Table;

interface

{$I ThsERP.inc}

uses
  Forms,
  SysUtils,
  Windows,
  Classes,
  Dialogs,
  Messages,
  StrUtils,
  System.Variants,
  System.Generics.Collections,
  Graphics,
  Controls,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  System.UITypes,
  System.Rtti,
  Data.DB,
  WinSock,

  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.Stan.Option,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Intf,

  Ths.Erp.Helper.BaseTypes,
  Ths.Erp.Helper.Edit,
  Ths.Erp.Helper.Combobox,
  Ths.Erp.Helper.Memo,
  Ths.Erp.Database;

{$M+}

type
  TJoinType = (jtLeft, jtRight, jtInner, jtFullOuter);

  TProductPrice = (ppBuying, ppRawBuying, ppSales, ppExport);
  TTableAction = (taSelect, taInsert, taUpdate, taDelete);
  TSequenceStatus = (ssArtis, ssAzalma, ssNone);
  THesapTipi = (htAna=1, htAra, htSon);

  //forward declaration
  TTable = class;

  TFieldDB = class
  private
    FFieldName: string;
    FDataType: TFieldType;
    FValue: Variant;
    FSize: Integer;
    FIsNullable: Boolean;
    FOtherFieldName: string;
    FOwnerTable: TTable;
    FTitle: string;
    function GetValue: Variant;
    procedure SetValue(const Value: Variant);
  public
    destructor Destroy; override;
    property FieldName: string read FFieldName write FFieldName;
    property DataType: TFieldType read FDataType write FDataType;
    property Value: Variant read GetValue write SetValue;
    property Size: Integer read FSize write FSize default 0;
    property IsNullable: Boolean read FIsNullable write FIsNullable default True;
    property OtherFieldName: string read FOtherFieldName write FOtherFieldName;
    property OwnerTable: TTable read FOwnerTable write FOwnerTable;
    property Title: string read FTitle write FTitle;

    constructor Create(const AFieldName: string;
                       const AFieldType: TFieldType;
                       const AValue: Variant;
                       AOwnerTable: TTable;
                       const ATitle: string;
                       const AOtherFieldName: string = '';
                       const AMaxLength: Integer=0;
                       const AIsNullable: Boolean=True);

    procedure Clone(var pField: TFieldDB);
    //procedure SetControlProperty(const pTableName: string; pControl: TWinControl);
    function QryName: string;
    function AsString: string;
  end;

  TTable = class
  private
    FTableName: string; //database table name
    FTableSourceCode: string; //access source code

    FDatabase: TDatabase; //pointer singleton database

    FFields: TArray<TFieldDB>;

    function GetTableName(): string;
    procedure SetTableName(ATableName: string);
  protected
    //record list storage in selected rows
    FList: TList;
    //for dbgrid use
    FDataSource: TDataSource;

{$IFDEF CRUD_MODE_SP}
    FQueryOfDS: TFDStoredProc;
    FQueryOfList: TFDStoredProc;
    FQueryOfInsert: TFDStoredProc;
    FQueryOfUpdate: TFDStoredProc;
    FQueryOfDelete: TFDStoredProc;
{$ELSE IFDEF CRUD_MODE_PURE_SQL}
    FQueryOfDS: TFDQuery;
    FQueryOfList: TFDQuery;
    FQueryOfInsert: TFDQuery;
    FQueryOfUpdate: TFDQuery;
    FQueryOfDelete: TFDQuery;
{$ENDIF}
    //for other special sql execute
    FQueryOfOther: TFDQuery;
    FQueryOfInfo: TFDQuery;

    procedure FreeListContent(); virtual;

    //protected business function
    procedure BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean); virtual;
    procedure BusinessInsert(out AID: Integer; var APermissionControl: Boolean); virtual;
    procedure BusinessUpdate(APermissionControl: Boolean); virtual;
    procedure BusinessDelete(APermissionControl: Boolean); virtual;
  published
    constructor Create(ADatabase: TDatabase); virtual;
    destructor Destroy; override;

    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
  public
    Deleted: Boolean;

    Id: TFieldDB;//property olarak tanımlamıyoruz. Field Clone içinde hata veriyor

    property TableName: string read GetTableName write SetTableName;
    property TableSourceCode: string read FTableSourceCode write FTableSourceCode;
    property Database: TDatabase read FDatabase;

    property List: TList read FList;  //TDictionary<string, TTable>
    property DataSource: TDataSource read FDataSource;

    property Fields: TArray<TFieldDB> read FFields write FFields;

{$IFDEF CRUD_MODE_SP}
    property QueryOfDS: TFDStoredProc read FQueryOfDS write FQueryOfDS;
    property QueryOfList: TFDStoredProc read FQueryOfList write FQueryOfList;
    property QueryOfInsert: TFDStoredProc read FQueryOfInsert write FQueryOfInsert;
    property QueryOfUpdate: TFDStoredProc read FQueryOfUpdate write FQueryOfUpdate;
    property QueryOfDelete: TFDStoredProc read FQueryOfDelete write FQueryOfDelete;
{$ELSE IFDEF CRUD_MODE_PURE_SQL}
    property QueryOfDS: TFDQuery read FQueryOfDS write FQueryOfDS;
    property QueryOfList: TFDQuery read FQueryOfList write FQueryOfList;
    property QueryOfInsert: TFDQuery read FQueryOfInsert write FQueryOfInsert;
    property QueryOfUpdate: TFDQuery read FQueryOfUpdate write FQueryOfUpdate;
    property QueryOfDelete: TFDQuery read FQueryOfDelete write FQueryOfDelete;
{$ENDIF}
    property QueryOfOther: TFDQuery read FQueryOfOther write FQueryOfOther;
    property QueryOfInfo: TFDQuery read FQueryOfInfo write FQueryOfInfo;

    //for Postgres
    procedure Listen(); virtual;
    procedure Unlisten(); virtual;
    procedure Notify(); virtual;

    //get records from the database for dbgrid
    procedure SelectToDatasource(AFilter: string; APermissionControl: Boolean=True; AAllColumn: Boolean=True; AHelper: Boolean=False); virtual; abstract;
    //get records from the database into the list
    procedure SelectToList(AFilter: string; ALock: Boolean; APermissionControl: Boolean=True); virtual; abstract;
    //insert record to database
    procedure Insert(out AID: Integer; APermissionControl: Boolean=True); virtual; abstract;
    //update record to database
    procedure Update(APermissionControl: Boolean=True); virtual; abstract;
    //delete record from the database
    procedure Delete(APermissionControl: Boolean=True); virtual;
    //delete record from the database with filter
    procedure DeleteWith(AIDs: TArray<Integer>; APermissionControl: Boolean=True); virtual;
    procedure DeleteWithCustom(AIDs: TArray<Integer>; ATableName: string; APermissionControl: Boolean=True); virtual;

    //clear to class attributes
    procedure Clear; virtual;
    //clone to class attribute into new class
    function Clone: TTable; virtual; abstract;

    //public business functions
    function LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean):Boolean; virtual;
    function LogicalInsert(out AID: Integer; AWithBegin, AWithCommit, APermissionControl: Boolean):Boolean; virtual;
    function LogicalUpdate(AWithCommit, APermissionControl: Boolean):Boolean; virtual;
    function LogicalDelete(AWithCommit, APermissionControl: Boolean):Boolean; virtual;

    procedure PrepareTableClassFromQuery(AQuery: TFDQuery);
    procedure PrepareInsertQueryParams;
    procedure PrepareUpdateQueryParams;

    procedure CloneClassContent(ASrc, ADes: TTable);

    function GetFieldByFieldName(AFieldName: string): TFieldDB;

    procedure SetFieldDBPropsFromDbInfo;

    function FindField(AFieldName: string): TFieldDB;
  end;

  /// <summary>
  ///  SelectToDatasource kısmında Kolon başlıkları(Title) düzenlemek için kullanılır.
  /// </summary>
  procedure setFieldTitle(AField: TFieldDB; ATitle: string; ADataSet: TDataSet);

  /// <summary>
  ///  SelectToList kısmında Sınıfa ait Field Value değerini Query içinden almak için kullanılır.
  /// </summary>
  procedure setFieldValue(AField: TFieldDB; ADataSet: TDataSet);

  /// <summary>
  ///  Grid üzerinde gösterilen kayıtlarda String Formatlama yapmak için kullanılıyor.
  /// </summary>
  procedure setDisplayFormatString(AFieldName: string; AFormat: string; ADataSet: TDataSet);

  /// <summary>
  ///  Grid üzerinde gösterilen kayıtlarda Integer Formatlama yapmak için kullanılıyor.
  /// </summary>
  procedure setDisplayFormatInteger(AFieldName: string; AFormat: string; ADataSet: TDataSet);

  /// <summary>
  ///  Grid üzerinde gösterilen kayıtlarda Integer Formatlama yapmak için kullanılıyor.
  /// </summary>
  procedure setDisplayFormatFloat(AFieldName: string; AFormat: string; ADataSet: TDataSet);

  /// <summary>
  ///  Grid üzerinde gösterilen kayıtlarda Date Formatlama yapmak için kullanılıyor.
  /// </summary>
  procedure setDisplayFormatDate(AFieldName: string; AFormat: string; ADataSet: TDataSet);

  /// <summary>
  ///  Kaydın Lisan karşılığı alınacak ise ve Kolonun başka tablo ile ilişkisi yoksa,
  ///  "IsPureData" parametresi True gönderilir.
  ///  Bu şekilde sys_lang_data_content tablosunda kaydın lisan karşılığı getirilir.
  /// </summary>
  function addLeftJoin(AFieldName, AIDFieldName, ATableName: string; IsPureData: Boolean = False): string;

  function addJoin(AJoin: TJoinType; ARefTable, ARefField, ATableName, AFieldName: string; ARefTableAlias: string = ''; ACustSQL: string = ''): string;
  function addField(ARefTable, ARefField, AFieldName: string; ARefTableAlias: string = ''): string;

  /// <summary>
  ///  Kaydın Lisan karşılığı alınacaksa önce "addLeftJoin" fonksiyonu gerekli şekilde çağırılır
  ///  Sonra bu fonksiyon ile kolonlar özel olarak eklenir
  /// </summary>
  function addLangField(AFieldName: string; ADataFieldNameDiff: string = ''; IsPureData: Boolean = False): string;

  function GetVarArrayByteSize(AField: TFieldDB): Int64;

  /// <summary>
  ///  Saklanan resim verilernin byte array olarak dönüþtürülmüþ Value deðeri
  /// </summary>
  procedure setValueFromImage(AField: TFieldDB; AImage: TImage);

  /// <summary>
  ///  Veri tabanýnda bytea(blob) olarak saklanan resim dosyalarýný bir resim içinde göstermek için kullanýlýr
  //   Veri tipi ftBytes olmak zorunda
  /// </summary>
  procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);

implementation

uses
    Ths.Erp.Globals
  , Ths.Erp.Constants
  , Ths.Erp.Database.Singleton
  , Ths.Erp.Database.Table.View.SysViewColumns
  , Ths.Erp.Database.Table.SysLisanDataIcerik
  , Ths.Erp.Database.Table.SysErisimHakki
  , Ths.Erp.Database.Table.SysKaynak
  ;

procedure setFieldTitle(AField: TFieldDB; ATitle: string; ADataSet: TDataSet);
var
  AFld: TField;
begin
  AFld := ADataSet.FindField(AField.FieldName);
  if AFld <> nil then
    AFld.DisplayLabel := ATitle;
end;

procedure setFieldValue(AField: TFieldDB; ADataSet: TDataSet);
var
  AFld: TField;
begin
  AFld := ADataSet.FindField(AField.FieldName);
  if AFld <> nil then
  begin
    AField.Value := FormatedVariantVal(AFld.DataType, AFld.Value);
    if (AField.DataType = ftBytes) and AFld.IsBlob then
    begin
      AField.Value := TBlobField(AFld).Value;
    end;
  end;
end;

procedure setDisplayFormatString(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TIntegerField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatInteger(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TIntegerField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatFloat(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TFloatField(AField).DisplayFormat := AFormat;
end;

procedure setDisplayFormatDate(AFieldName: string; AFormat: string; ADataSet: TDataSet);
var
  AField: TField;
begin
  AField := ADataSet.FindField(AFieldName);
  if AField <> nil then
    TDateField(AField).DisplayFormat := AFormat;
end;

function addLeftJoin(AFieldName, AIDFieldName, ATableName: string; IsPureData: Boolean): string;
var
  LTableAlias: string;
  LRowFieldName: string;
  LSysLangData: TSysLisanDataIcerik;
begin
  if  (GDataBase.ConnSetting.Language <> GSysUygulamaAyari.UygulamaLisan.Value)
  and (GSysUygulamaAyari.UygulamaLisan.Value <> '')
  then
  begin
    //farklı lisan olunca lisan karşılığını ara
    LTableAlias := 'data_' + AFieldName;
    if IsPureData then
      LRowFieldName := ATableName + '.id'
    else
      LRowFieldName := AIDFieldName;

    LSysLangData := TSysLisanDataIcerik.Create(GDataBase);
    try
      Result :=
        'LEFT JOIN ' + LSysLangData.TableName + ' AS ' + LTableAlias + ' ON ' +
          LTableAlias + '.' + LSysLangData.KolonAdi.FieldName + '=' + QuotedStr(AFieldName) + ' AND ' +
          LTableAlias + '.' + LSysLangData.TabloAdi.FieldName + '=' + QuotedStr(ATableName) + ' AND ' +
          LTableAlias + '.' + LSysLangData.RowID.FieldName + '=' + LRowFieldName + ' AND ' +
          LTableAlias + '.' + LSysLangData.Lisan.FieldName + '=' + QuotedStr(GDataBase.ConnSetting.Language) + ' ';
    finally
      LSysLangData.Free;
    end;
  end
  else
  begin
    if IsPureData then
    begin

    end
    else
    begin
      //aynı lisan olunca id karşılığı verileri aynı tablodan çek
      LTableAlias := 'data_' + AFieldName;
      Result := 'LEFT JOIN ' + ATableName + ' AS ' + LTableAlias + ' ON ' + LTableAlias + '.id=' + AIDFieldName + ' ';
    end;
  end;
end;

function addJoin(AJoin: TJoinType; ARefTable, ARefField, ATableName, AFieldName: string; ARefTableAlias: string; ACustSQL: string): string;
var
  LJoin, LTable: string;
begin
  case AJoin of
    jtLeft: LJoin := ' LEFT JOIN ';
    jtRight: LJoin := ' RIGHT JOIN ';
    jtInner: LJoin := ' INNER JOIN ';
    jtFullOuter: LJoin := ' FULL JOIN ';
  end;

  if ARefTableAlias <> '' then
    LTable := ARefTableAlias
  else
    LTable := ARefTable;

  Result := LJoin + ARefTable + ' ' + ARefTableAlias + ' ON ' + LTable + '.' + ARefField + '=' + ATableName + '.' + AFieldName + ACustSQL;
end;

function addField(ARefTable, ARefField, AFieldName: string; ARefTableAlias: string): string;
var
  LTable: string;
begin
  if ARefTableAlias <> '' then
    LTable := ARefTableAlias
  else
    LTable := ARefTable;

  Result := LTable + '.' + ARefField + ' ' + AFieldName;
end;

function addLangField(AFieldName: string; ADataFieldNameDiff: string; IsPureData: Boolean): string;
begin
  if  (GDataBase.ConnSetting.Language <> GSysUygulamaAyari.UygulamaLisan.Value)
  and (GSysUygulamaAyari.UygulamaLisan.Value <> '')
  then
  begin
    Result := 'data_' + AFieldName + '.val AS ' + AFieldName;
  end
  else
  begin
    if IsPureData then
      Result := AFieldName
    else
    begin
      if ADataFieldNameDiff <> '' then
        Result := 'data_' + AFieldName + '.' + ADataFieldNameDiff + ' AS ' + AFieldName
      else
        Result := 'data_' + AFieldName + '.' + AFieldName + ' AS ' + AFieldName
    end;
  end;
end;

function GetVarArrayByteSize(AField: TFieldDB): Int64;
begin
  Result := 0;
  if AField.DataType = ftBytes then
  begin
    if Length(AField.Value) = 0 then
      Exit;
    Result := ( VarArrayHighBound(AField.Value, 1) -
                VarArrayLowBound(AField.Value, 1) + 1
              ) * TVarData(AField.Value).VArray^.ElementSize;
  end;
end;

procedure setValueFromImage(AField: TFieldDB; AImage: TImage);
var
  ms: TMemoryStream;
  LLen: Int64;
  LByt: TBytes;
begin
  ms := TMemoryStream.Create;
  try
    if AImage.Picture.Graphic <> nil then
    begin
      AImage.Picture.Graphic.SaveToStream(ms);
      ms.Position := 0;
      LLen := ms.Size;
      SetLength(LByt, LLen);
      ms.Read(Pointer(LByt)^, LLen);
      AField.Value := LByt;
    end
    else
      AField.Value := 0;
  finally
    ms.Free;
  end;
end;

procedure LoadImageFromDB(AField: TFieldDB; AImage: TImage);
var
  ms: TMemoryStream;
  LPic: TPicture;
  LSize: Int64;
begin
  AImage.Picture.Assign(nil);
  if AField.DataType <> ftBytes then
    Exit;

  if not VarIsNull(AField.Value) then
  begin
    LPic := TPicture.Create;
    ms := TMemoryStream.Create;
    try
      LSize := GetVarArrayByteSize(AField);
      if LSize = 0 then
        Exit;

      ms.Write(AField.Value, 0, LSize);
      ms.Position := 0;
      LPic.LoadFromStream(ms);
      AImage.Picture.Assign(LPic);
    finally
      LPic.Free;
      ms.Free;
    end;
  end;
end;

constructor TFieldDB.Create(
  const AFieldName: string;
  const AFieldType: TFieldType;
  const AValue: Variant;
  AOwnerTable: TTable;
  const ATitle: string;
  const AOtherFieldName: string = '';
  const AMaxLength: Integer=0;
  const AIsNullable: Boolean=True);
begin
  FFieldName := AFieldName;
  FDataType := AFieldType;
  FValue := AValue;
  FSize := AMaxLength;
  FIsNullable := AIsNullable;
  if AOtherFieldName = ''
  then  FOtherFieldName := FFieldName
  else  FOtherFieldName := AOtherFieldName;

  FOwnerTable := AOwnerTable;

  if ATitle = ''
  then  FTitle := AFieldName
  else  FTitle := ATitle;

  if FOwnerTable <> nil then
  begin
    SetLength(FOwnerTable.FFields, Length(FOwnerTable.FFields)+1);
    FOwnerTable.FFields[Length(FOwnerTable.FFields)-1] := Self
  end;
end;

destructor TFieldDB.Destroy;
begin
  inherited;
end;

function TFieldDB.QryName: string;
begin
  Result := Self.FOwnerTable.TableName + '.' + Self.FieldName;
end;

function TFieldDB.GetValue: Variant;
begin
//  if FValue = Null then
//  begin
//    if (Self.FFieldType = ftString)
//    or (Self.FFieldType = ftMemo)
//    or (Self.FFieldType = ftFmtMemo)
//    or (Self.FFieldType = ftWideString)
//    or (Self.FFieldType = ftWideMemo)
//    then
//      Result := ''
//    else
//    if (Self.FFieldType = ftSmallint)
//    or (Self.FFieldType = ftInteger)
//    or (Self.FFieldType = ftShortint)
//    or (Self.FFieldType = ftWord)
//    or (Self.FFieldType = ftLongWord)
//    or (Self.FFieldType = ftFloat)
//    or (Self.FFieldType = ftCurrency)
//    or (Self.FFieldType = ftBCD)
//    or (Self.FFieldType = ftDate)
//    or (Self.FFieldType = ftTime)
//    or (Self.FFieldType = ftDateTime)
//    or (Self.FFieldType = ftTimeStamp)
//    or (Self.FFieldType = ftFMTBcd)
//    then
//      Result := 0;
//  end
//  else
    Result := FValue;
end;

procedure TFieldDB.SetValue(const Value: Variant);
begin
  FValue := Value;

  if VarIsStr(FValue) and (FValue = '') then
    case FDataType of
      ftUnknown: ;
      ftString: ;
      ftSmallint: FValue := 0;
      ftInteger: FValue := 0;
      ftWord: FValue := 0;
      ftBoolean: ;
      ftFloat: FValue := 0;
      ftCurrency: FValue := 0;
      ftBCD: ;
      ftDate: FValue := 0;
      ftTime: FValue := 0;
      ftDateTime: FValue := 0;
      ftBytes: ;
      ftVarBytes: ;
      ftAutoInc: ;
      ftBlob: ;
      ftMemo: ;
      ftGraphic: ;
      ftFmtMemo: ;
      ftParadoxOle: ;
      ftDBaseOle: ;
      ftTypedBinary: ;
      ftCursor: ;
      ftFixedChar: ;
      ftWideString: ;
      ftLargeint: ;
      ftADT: ;
      ftArray: ;
      ftReference: ;
      ftDataSet: ;
      ftOraBlob: ;
      ftOraClob: ;
      ftVariant: ;
      ftInterface: ;
      ftIDispatch: ;
      ftGuid: ;
      ftTimeStamp: FValue := 0;
      ftFMTBcd: FValue := 0;
      ftFixedWideChar: ;
      ftWideMemo: ;
      ftOraTimeStamp: ;
      ftOraInterval: ;
      ftLongWord: FValue := 0;
      ftShortint: FValue := 0;
      ftByte: ;
      ftExtended: ;
      ftConnection: ;
      ftParams: ;
      ftStream: ;
      ftTimeStampOffset: ;
      ftObject: ;
      ftSingle: ;
    end;
end;

function TFieldDB.AsString: string;
begin
  Result := VarToStr(FValue);
end;

procedure TFieldDB.Clone(var pField: TFieldDB);
begin
  pField.FOwnerTable := Self.FOwnerTable;
  pField.FFieldName := Self.FFieldName;
  pField.FDataType := Self.FDataType;
  pField.FValue := Self.FValue;
  pField.FSize := Self.FSize;
  pField.FIsNullable := Self.FIsNullable;
  pField.FOtherFieldName := Self.FOtherFieldName;
end;

//procedure TFieldDB.SetControlProperty(const pTableName: string; pControl: TWinControl);
//var
//  vAktifDonem: Integer;
//  vFieldType: TFieldType;
//begin
//  vAktifDonem := FormatedVariantVal(TSingletonDB.GetInstance.ApplicationSettings.Period.FieldType, TSingletonDB.GetInstance.ApplicationSettings.Period.Value);
//  if pControl.ClassType = TEdit then
//  begin
//    with pControl as TEdit do
//    begin
//      Clear;
//      thsActiveYear4Digit := vAktifDonem;
//      CharCase := ecUpperCase;
//      thsRequiredData := TSingletonDB.GetInstance.GetIsRequired(pTableName, Self.FFieldName);
//      thsDBFieldName := Self.FFieldName;
//      vFieldType := Self.FFieldType;
//
////      if Self.IsFK then
////      begin
////        if Assigned(Self.FK.FFKTable) and Assigned(Self.FK.FFKCol) then
////          MaxLength := TSingletonDB.GetInstance.GetMaxLength(Self.FK.FFKTable.TableName, Self.FK.FFKCol.FFieldName)
////        else
////          raise Exception.Create('Foreing Key özelliği aktif edilmiş. Fakat FKTable/FKCol tanımlanmamış.');
////      end
////      else
//        MaxLength := TSingletonDB.GetInstance.GetMaxLength(pTableName, Self.FFieldName);
//
//      if vFieldType = ftString then
//        thsInputDataType := itString
//      else
//      if (vFieldType = ftInteger)
//      or (vFieldType = ftSmallint)
//      or (vFieldType = ftShortint)
//      or (vFieldType = ftLargeint)
//      or (vFieldType = ftWord)
//      then
//        thsInputDataType := itInteger
//      else
//      if (vFieldType = ftFloat) then
//        thsInputDataType := itFloat
//      else
//      if (vFieldType = ftCurrency) then
//        thsInputDataType := itMoney
//      else
//      if (vFieldType = ftDate)
//      or (vFieldType = ftDateTime)
//      then
//        thsInputDataType := itDate;
//    end;
//  end
//  else
//  if pControl.ClassType = TCombobox then
//  begin
//    with pControl as TCombobox do
//    begin
//      Clear;
//      thsActiveYear := vAktifDonem;
//      thsCaseUpLowSupportTr := True;
//      CharCase := ecUpperCase;
//
////      if Self.IsFK then
////      begin
////        if Assigned(Self.FK.FFKTable) and Assigned(Self.FK.FFKCol) then
////        begin
////          thsDBFieldName := Self.FK.FFKCol.FFieldName;
////          thsRequiredData := TSingletonDB.GetInstance.GetIsRequired(Self.FK.FFKTable.TableName, Self.FK.FFKCol.FFieldName);
////          MaxLength := TSingletonDB.GetInstance.GetMaxLength(Self.FK.FFKTable.TableName, Self.FK.FFKCol.FFieldName);
////          vFieldType := Self.FK.FFKCol.FFieldType;
////        end
////        else
////          raise Exception.Create('Foreing Key özelliği aktif edilmiş. Fakat FKTable/FKCol tanımlanmamış.');
////      end
////      else
//      begin
//        thsDBFieldName := Self.FFieldName;
//        thsRequiredData := TSingletonDB.GetInstance.GetIsRequired(pTableName, Self.FFieldName);
//        MaxLength := TSingletonDB.GetInstance.GetMaxLength(pTableName, Self.FFieldName);
//        vFieldType := Self.FFieldType;
//      end;
//
//      if vFieldType = ftString then
//        thsInputDataType := itString
//      else
//      if (vFieldType = ftInteger)
//      or (vFieldType = ftSmallint)
//      or (vFieldType = ftShortint)
//      or (vFieldType = ftLargeint)
//      or (vFieldType = ftWord)
//      then
//        thsInputDataType := itInteger
//      else
//      if (vFieldType = ftFloat) then
//        thsInputDataType := itFloat
//      else
//      if (vFieldType = ftCurrency) then
//        thsInputDataType := itMoney
//      else
//      if (vFieldType = ftDate)
//      or (vFieldType = ftDateTime)
//      then
//        thsInputDataType := itDate;
//    end;
//  end
//  else
//  if pControl.ClassType = TMemo then
//  begin
//    with pControl as TMemo do
//    begin
//      Clear;
//      thsActiveYear := vAktifDonem;
//      thsCaseUpLowSupportTr := True;
//      CharCase := ecUpperCase;
//
////      if Self.IsFK then
////      begin
////        if Assigned(Self.FK.FFKTable) and Assigned(Self.FK.FFKCol) then
////        begin
////          thsDBFieldName := Self.FK.FFKCol.FFieldName;
////          thsRequiredData := TSingletonDB.GetInstance.GetIsRequired(Self.FK.FFKTable.TableName, Self.FK.FFKCol.FFieldName);
////          MaxLength := TSingletonDB.GetInstance.GetMaxLength(Self.FK.FFKTable.TableName, Self.FK.FFKCol.FFieldName);
////          vFieldType := Self.FK.FFKCol.FFieldType;
////        end
////        else
////          raise Exception.Create('Foreing Key özelliği aktif edilmiş. Fakat FKTable/FKCol tanımlanmamış.');
////      end
////      else
//      begin
//        thsDBFieldName := Self.FFieldName;
//        thsRequiredData := TSingletonDB.GetInstance.GetIsRequired(pTableName, Self.FFieldName);
//        MaxLength := TSingletonDB.GetInstance.GetMaxLength(pTableName, Self.FFieldName);
//        vFieldType := Self.FFieldType;
//      end;
//
//      if vFieldType = ftString then
//        thsInputDataType := itString
//      else
//      if (vFieldType = ftInteger)
//      or (vFieldType = ftSmallint)
//      or (vFieldType = ftShortint)
//      or (vFieldType = ftLargeint)
//      or (vFieldType = ftWord)
//      then
//        thsInputDataType := itInteger
//      else
//      if (vFieldType = ftFloat) then
//        thsInputDataType := itFloat
//      else
//      if (vFieldType = ftCurrency) then
//        thsInputDataType := itMoney
//      else
//      if (vFieldType = ftDate)
//      or (vFieldType = ftDateTime)
//      then
//        thsInputDataType := itDate;
//    end;
//  end;
//end;

procedure TTable.BusinessDelete(APermissionControl: Boolean);
begin
  Self.Delete(APermissionControl);
end;

procedure TTable.BusinessInsert(out AID: Integer; var APermissionControl: Boolean);
begin
  Self.Insert(AID, APermissionControl)
//  if (TSingletonDB.GetInstance.ApplicationSettings.AppMainLang.Value = TSingletonDB.GetInstance.DataBase.ConnSetting.Language)
//  or (Self.TableName = TSingletonDB.GetInstance.ApplicationSettings.TableName)
//  then
//  else
//    raise Exception.Create(
//      'Programın Ana dili haricinde insert işlemi yapamazsınız!!!' + sLineBreak +
//      'Sadece inceleme görsel olarak bakma işlemi yapabilirsiniz. Aksi halde gerçek datalar bozulacaktır.' + sLineBreak +
//      'Burası daha sonra düzenlemenecek. Sadece ayar tablolarında güncelleme veya insert yapamaz şeklinde düzenleme yapılacak.' + AddLBs(2) +
//      'Program Dili === ' + TSingletonDB.GetInstance.ApplicationSettings.AppMainLang.Value);
end;

procedure TTable.BusinessSelect(AFilter: string; ALock, APermissionControl: Boolean);
begin
  Self.SelectToList(AFilter, ALock, APermissionControl);
end;

procedure TTable.BusinessUpdate(APermissionControl: Boolean);
begin
//  if (Self.TableName = TSingletonDB.GetInstance.ApplicationSettings.TableName)
//  or (TSingletonDB.GetInstance.ApplicationSettings.AppMainLang.Value = TSingletonDB.GetInstance.DataBase.ConnSetting.Language)
//  or (LeftStr(Self.TableName, 3) <> 'set') //ayar tablolarına yabancı dilde kayıt yapılamaz.
//  then
    Self.Update(APermissionControl)
//  else
//    raise Exception.Create(
//      'Programın Ana dili haricinde update işlemi yapamazsınız!!!' + sLineBreak +
//      'Sadece inceleme görsel olarak bakma işlemi yapabilirsiniz. Aksi halde gerçek datalar bozulacaktır.' + sLineBreak +
//      'Burası daha sonra düzenlemenecek. Sadece ayar tablolarında güncelleme veya insert yapamaz şeklinde düzenleme yapılacak.' + AddLBs(2) +
//      'Program Dili === ' + TSingletonDB.GetInstance.ApplicationSettings.AppMainLang.Value);
end;

procedure TTable.Clear;
var
  n1: Integer;
begin
  for n1 := 0 to Length(FFields)-1 do
  begin
    if Assigned(FFields[n1]) then  //TFieldDB olup olmadığını burada da kontrol edebiliriz.
    begin
      with FFields[n1] do
      begin
        if (DataType = ftString)
        or (DataType = ftWideString)
        or (DataType = ftMemo)
        or (DataType = ftWideMemo)
        or (DataType = ftBytes)
        or (DataType = ftFmtMemo)
        or (DataType = ftFixedChar)
        or (DataType = ftFixedWideChar)
        then
          Value := ''
        else
        if (DataType = ftSmallint)
        or (DataType = ftInteger)
        or (DataType = ftWord)
        or (DataType = ftFloat)
        or (DataType = ftCurrency)
        or (DataType = ftBCD)
        or (DataType = ftDate)
        or (DataType = ftTime)
        or (DataType = ftDateTime)
        or (DataType = ftBytes)
        or (DataType = ftVarBytes)
        or (DataType = ftAutoInc)
        or (DataType = ftLargeint)
        or (DataType = ftTimeStamp)
        or (DataType = ftShortint)
        or (DataType = ftByte)
        then
          Value := 0
        else
        if (DataType = ftBoolean) then
          Value := False
        else
        if (DataType = ftBlob) then
          Value := Null;
      end;
    end;
  end;
end;

constructor TTable.Create(ADatabase: TDatabase);
begin
  if Trim(TableName) = '' then
    raise Exception.Create('Table sınıfları Inherited Create işleminden önce Tablo adı tanımlanmak zorunda!!!');

  FDatabase := ADatabase;

  FList := TList.Create();
  FList.Clear();

  SetLength(FFields, 0);

{$IFDEF CRUD_MODE_SP}
  FQueryOfDS := FDatabase.NewStoredProcedure;
  FQueryOfDS.Name := 'QueryOfDS';
  FQueryOfDS.ResourceOptions.DirectExecute := False;
  FQueryOfDS.StoredProcName := PREFIX_SP_SELECT + TableName;
  //FQueryOfDS.FormatOptions.SortOptions := [soNoCase];
  FQueryOfDS.FormatOptions.SortOptions := [];
  FQueryOfDS.FormatOptions.StrsTrim := False;
  FQueryOfDS.FetchOptions.Items := [fiDetails, fiBlobs];
  FQueryOfDS.FetchOptions.RowsetSize := 1000;
  FQueryOfDS.FetchOptions.Mode := fmOnDemand;
  FQueryOfDS.FetchOptions.CursorKind := ckDynamic;

  FQueryOfList := FDatabase.NewStoredProcedure;
  FQueryOfList.Name := 'QueryOfList';
  FQueryOfList.StoredProcName := PREFIX_SP_SELECT + TableName;

  FQueryOfInsert := FDatabase.NewStoredProcedure;
  FQueryOfInsert.Name := 'QueryOfInsert';
  FQueryOfInsert.BeforeExecute := StoredProc1BeforeExecute;
  FQueryOfInsert.StoredProcName := PREFIX_SP_INSERT + TableName;

  FQueryOfUpdate := FDatabase.NewStoredProcedure;
  FQueryOfUpdate.Name := 'QueryOfUpdate';
  FQueryOfUpdate.BeforeExecute := StoredProc1BeforeExecute;
  FQueryOfUpdate.StoredProcName := PREFIX_SP_UPDATE + TableName;

  FQueryOfDelete := FDatabase.NewStoredProcedure;
  FQueryOfDelete.Name := 'QueryOfDelete';
  FQueryOfDelete.BeforeExecute := StoredProc1BeforeExecute;
  FQueryOfDelete.StoredProcName := PREFIX_SP_DELETE + TableName;

{$ELSE IFDEF CRUD_MODE_PURE_SQL}
  FQueryOfDS := FDatabase.NewQuery;
  FQueryOfDS.Name := 'QueryOfDS';
  FQueryOfDS.ResourceOptions.DirectExecute := False;
//  FQueryOfDS.FormatOptions.SortOptions := [soNoCase];
//  FQueryOfDS.FormatOptions.SortOptions := [];
//  FQueryOfDS.FetchOptions.Cache := [fiDetails];
  FQueryOfDS.FetchOptions.RowsetSize := 100;

//  FQueryOfDS.FormatOptions.StrsTrim := False;
  FQueryOfDS.FetchOptions.Items := [fiDetails];
  FQueryOfDS.FetchOptions.Mode := fmOnDemand;
  FQueryOfDS.FetchOptions.CursorKind := ckAutomatic;


  FQueryOfList := FDatabase.NewQuery;
  FQueryOfList.Name := 'QueryOfList';
  FQueryOfInsert := FDatabase.NewQuery;
  FQueryOfInsert.Name := 'QueryOfInsert';
  FQueryOfUpdate := FDatabase.NewQuery;
  FQueryOfUpdate.Name := 'QueryOfUpdate';
  FQueryOfDelete := FDatabase.NewQuery;
  FQueryOfDelete.Name := 'QueryOfDelete';
{$ENDIF}
  FQueryOfDS.FetchOptions.RecordCountMode := cmFetched;
  FQueryOfList.FetchOptions.RecordCountMode := cmFetched;

  FQueryOfOther := FDatabase.NewQuery;
  FQueryOfInfo := FDatabase.NewQuery;


  FDataSource := TDataSource.Create(nil);
  FDataSource.DataSet := FQueryOfDS;

  Id := TFieldDB.Create('id', ftInteger, 0, Self, 'ID');
  Id.Value := FDatabase.GetNewRecordId();

  Deleted := False;
end;

procedure TTable.Delete(APermissionControl: Boolean);
begin
  if Self.IsAuthorized(ptDelete, APermissionControl) then
  begin
    {$IFDEF CRUD_MODE_SP}
      SpDelete.ExecProc;
      Self.Notify;
    {$ELSE IFDEF CRUD_MODE_PURE_SQL}
      with QueryOfDelete do
      begin
        Close;
        SQL.Clear;
        SQL.Text := 'DELETE FROM ' + TableName + ' WHERE id=:id;';
        ParamByName(Self.Id.FieldName).Value := FormatedVariantVal(Self.Id.DataType, Self.Id.Value);
        ExecSQL;
        Close;
      end;
      Self.Notify;
    {$ENDIF}
  end;
end;

procedure TTable.DeleteWith(AIDs: TArray<Integer>; APermissionControl: Boolean=True);
var
  LSb: TStringBuilder;
  n1: Integer;
  LIDs: string;
begin
  if Self.IsAuthorized(ptDelete, APermissionControl) then
  begin
    if Length(AIDs) > 0 then
    begin
      LSb := TStringBuilder.Create;
      try
        LSb.Clear;
        for n1 := 0 to High(AIDs) do
        begin
          LSb.Append(IntToStr(AIDs[n1]));
          if n1 < High(AIDs) then
            LSb.Append(',');
        end;
        LIDs := LSb.ToString;
      finally
        LSb.Free;
      end;

      if LIDs <> '' then
      begin
        {$IFDEF CRUD_MODE_SP}
          SpDelete.ExecProc;
          Self.Notify;
        {$ELSE IFDEF CRUD_MODE_PURE_SQL}
          with QueryOfDelete do
          begin
            Close;
            SQL.Clear;
            SQL.Text := 'DELETE FROM ' + TableName + ' WHERE id in (:id);';
            ParamByName(Self.Id.FieldName).Value := LIDs;
            ExecSQL;
            Close;
          end;
          Self.Notify;
        {$ENDIF}
      end;
    end;
  end;
end;

procedure TTable.DeleteWithCustom(AIDs: TArray<Integer>; ATableName: string; APermissionControl: Boolean=True);
var
  LSb: TStringBuilder;
  n1: Integer;
  LIDs: string;
begin
  if Self.IsAuthorized(ptDelete, APermissionControl) then
  begin
    if Length(AIDs) > 0 then
    begin
      LSb := TStringBuilder.Create;
      try
        LSb.Clear;
        for n1 := 0 to High(AIDs) do
        begin
          LSb.Append(IntToStr(AIDs[n1]));
          if n1 < High(AIDs) then
            LSb.Append(',');
        end;
        LIDs := LSb.ToString;
      finally
        LSb.Free;
      end;

      if LIDs <> '' then
      begin
        {$IFDEF CRUD_MODE_SP}
          SpDelete.ExecProc;
          Self.Notify;
        {$ELSE IFDEF CRUD_MODE_PURE_SQL}
          with QueryOfDelete do
          begin
            Close;
            SQL.Clear;
            SQL.Text := 'DELETE FROM ' + ATableName + ' WHERE id in (:id);';
            ParamByName(Self.Id.FieldName).Value := LIDs;
            ExecSQL;
            Close;
          end;
          Self.Notify;
        {$ENDIF}
      end;
    end;
  end;
end;

destructor TTable.Destroy;
var
  n1: Integer;
begin
  for n1 := 0 to Length(Self.Fields)-1 do
    FreeAndNil(Self.Fields[n1]);
  SetLength(FFields, 0);

  FreeListContent();

  if Assigned(FList) then
    FList.Free;

  if Assigned(FDataSource) then
    FDataSource.Free;
{$IFDEF CRUD_MODE_SP}
  if Assigned(FQueryOfDS) then
    FQueryOfDS.Free;
  if Assigned(FQueryOfList) then
    FQueryOfList.Free;
  if Assigned(FQueryOfInsert) then
    FQueryOfInsert.Free;
  if Assigned(FQueryOfUpdate) then
    FQueryOfUpdate.Free;
  if Assigned(FQueryOfDelete) then
    FQueryOfDelete.Free;
{$ELSE IFDEF CRUD_MODE_PURE_SQL}
  if Assigned(FQueryOfDS) then
    FQueryOfDS.Free;
  if Assigned(FQueryOfList) then
    FQueryOfList.Free;
  if Assigned(FQueryOfInsert) then
    FQueryOfInsert.Free;
  if Assigned(FQueryOfUpdate) then
    FQueryOfUpdate.Free;
  if Assigned(FQueryOfDelete) then
    FQueryOfDelete.Free;
{$ENDIF}
  if Assigned(FQueryOfOther) then
    FQueryOfOther.Free;
  if Assigned(FQueryOfInfo) then
    FQueryOfInfo.Free;

  FDatabase := nil;

  inherited;
end;

function TTable.FindField(AFieldName: string): TFieldDB;
var
  n1: Integer;
begin
  Result := nil;
  for n1 := 0 to Length(Fields)-1 do
    if Fields[n1].FieldName = AFieldName then
      Result := Fields[n1];
end;

procedure TTable.FreeListContent;
var
  n1: Integer;
  ATable: TTable;
begin
  for n1 := FList.Count-1 downto 0 do
  begin
    ATable := List.Items[n1];
    FreeAndNil(ATable);
    FList.Delete(n1);
  end;
  List.Clear;
end;

function TTable.GetFieldByFieldName(AFieldName: string): TFieldDB;
var
  n1, Len: Integer;
begin
  Result := nil;
  Len := Length(FFields);
  for n1 := 0 to  Len-1 do
    if FFields[n1].FieldName = AFieldName then
    begin
      Result := FFields[n1];
      Break;
    end;
end;

function TTable.GetTableName: string;
begin
  Result := FTableName;
end;

procedure TTable.SetFieldDBPropsFromDbInfo;
var
  LCols: TSysViewColumns;
  AField: TFieldDB;
  n1, n2: Integer;
begin
  LCols := TSysViewColumns.Create(FDatabase);
  try
    LCols.SelectToList(' AND ' + LCols.TableName + '.' + LCols.OrjTableName.FieldName + '=' + QuotedStr(FTableName) +
        ' ORDER BY ' + LCols.OrjTableName.FieldName + ', ' +
                       LCols.OrdinalPosition.FieldName + ' ASC ', False, False);

    for n1 := 0 to LCols.List.Count-1 do
    begin
      for n2 := 0 to Length(Self.Fields)-1 do
      begin
        AField := Self.Fields[n2];
        if  (TSysViewColumns(LCols.List[n1]).OrjTableName.Value = Self.TableName)
        and (TSysViewColumns(LCols.List[n1]).OrjColumnName.Value = AField.FieldName)
        then
        begin
          AField.Size := 0;
          if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'bigint')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'integer')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'smallint')
          then
            AField.DataType := ftInteger
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'boolean') then
            AField.DataType := ftBoolean
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'bytea') then
            //AField.DataType := ftBlob
          else
          if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'character')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'character varying')
          or (TSysViewColumns(LCols.List[n1]).DataType.Value = 'text')
          then
          begin
            AField.DataType := ftString;
            AField.Size := TSysViewColumns(LCols.List[n1]).CharacterMaximumLength.Value;
          end
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'double precision') then
            AField.DataType := ftFloat
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'numeric') then
            AField.DataType := ftBCD
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'date') then
            AField.DataType := ftDate
          else if (TSysViewColumns(LCols.List[n1]).DataType.Value = 'timestamp without time zone') then
            AField.DataType := ftDateTime;

          AField.IsNullable := TSysViewColumns(LCols.List[n1]).IsNullable.Value;
          break;
        end;
      end;
    end;
  finally
    FreeAndNil(LCols);
  end;
end;

procedure TTable.SetTableName(ATableName: string);
begin
  FTableName := ATableName;
end;

function TTable.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
var
  vField, vFilter, vMessage: string;//vSourceCode, vSourceName
  LErisimHakki: TSysErisimHakki;
  LKaynak: TSysKaynak;
begin
  Result := False;
  if APermissionControl then
  begin
    LErisimHakki := TSysErisimHakki.Create(Database);
    LKaynak := TSysKaynak.Create(Database);
    try
      vField := '';
      vFilter := '';
      vMessage := '';
      if APermissionType = ptRead then
      begin
        vField := LErisimHakki.IsOkuma.FieldName;
        vFilter := ' and ' + LErisimHakki.IsOkuma.FieldName + '=true ';
        vMessage := 'SELECT';
      end
      else if APermissionType = ptAddRecord then
      begin
        vField := LErisimHakki.IsYeniKayit.FieldName;
        vFilter := ' and ' + LErisimHakki.IsYeniKayit.FieldName + '=true ';
        vMessage := 'INSERT';
      end
      else if APermissionType = ptUpdate then
      begin
        vField := LErisimHakki.IsGuncelleme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsGuncelleme.FieldName + '=true ';
        vMessage := 'UPDATE';
      end
      else if APermissionType = ptDelete then
      begin
        vField := LErisimHakki.IsSilme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsSilme.FieldName + '=true ';
        vMessage := 'DELETE';
      end
      else if APermissionType = ptSpeacial then
      begin
        vField := LErisimHakki.IsOzel.FieldName;
        vFilter := ' and ' + LErisimHakki.IsOzel.FieldName + '=true ';
        vMessage := 'SPECIAL';
      end;

      with QueryOfOther do
      begin
        Close;
        SQL.Text :=
          ' SELECT ' + vField +
          ' FROM ' + LErisimHakki.TableName +
          ' LEFT JOIN ' + LKaynak.TableName + ' ps ON ps.id=' + LErisimHakki.KaynakID.FieldName +
          ' WHERE ps.' + LKaynak.KaynakKodu.FieldName + '=' + QuotedStr(TableSourceCode) +
            ' AND ' + LErisimHakki.KullaniciID.FieldName + '=' + VarToStr(GSysKullanici.Id.Value) + vFilter;
        Open;
        while NOT EOF do
        begin
          Result := Fields.Fields[0].AsBoolean;

          Next;
        end;
        EmptyDataSet;
        Close;
      end;

      if not Result then
      begin
        if AShowException then
          raise Exception.Create(
            'Process ' + vMessage + AddLBs(2) +
            'There is no access to this resource! : ' + Self.TableName + ' ' + Self.ClassName + sLineBreak +
            'Missing Permission Source Code for Table Name: ' + Self.TableName);
      end;
    finally
      LErisimHakki.Free;
      LKaynak.Free;
    end;
  end
  else
    Result := True;
end;

procedure TTable.Listen;
begin
  with QueryOfInfo do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'listen ' + Self.TableName + ';';
    ExecSQL;
  end;
end;

function TTable.LogicalDelete(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  Self.BusinessDelete(APermissionControl);
  if AWithCommit then
    Self.Database.Connection.Commit;
end;

function TTable.LogicalInsert(out AID: Integer; AWithBegin, AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    if AWithBegin then
      Self.Database.Connection.StartTransaction;
    Self.BusinessInsert(AID, APermissionControl);
    Self.Id.Value := AID;
    if AWithCommit then
      Self.Database.Connection.Commit;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
      Self.Database.Connection.Rollback;
    end;
  end;
end;

function TTable.LogicalSelect(AFilter: string; ALock, AWithBegin, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    if not ALock then
      AWithBegin := False;

    if AWithBegin then
      Self.Database.Connection.StartTransaction;
    self.BusinessSelect(AFilter, ALock, APermissionControl);
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
      Self.Database.Connection.Rollback;
    end;
  end;
end;

function TTable.LogicalUpdate(AWithCommit, APermissionControl: Boolean): Boolean;
begin
  Result := True;
  try
    Self.BusinessUpdate(APermissionControl);
    if AWithCommit then
      Self.Database.Connection.Commit;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
      Result := False;
      Self.Database.Connection.Rollback;
    end;
  end;
end;

procedure TTable.Notify;
begin
  with QueryOfOther do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'notify ' + self.TableName + ';';
    ExecSQL;
    Close;
  end;
end;

procedure TTable.PrepareTableClassFromQuery(AQuery: TFDQuery);
var
  n1: Integer;
begin
  for n1 := 0 to Length(Self.Fields)-1 do
    setFieldValue(Self.Fields[n1], AQuery);
end;

procedure TTable.PrepareInsertQueryParams;
var
  n1: Integer;
begin
  for n1 := 0 to Length(Self.Fields)-1 do
    if Self.Fields[n1].FieldName <> 'id' then
      if QueryOfInsert.Params.FindParam(Self.Fields[n1].FieldName) <> nil then
        NewParamForQuery(QueryOfInsert, Self.Fields[n1]);
end;

procedure TTable.PrepareUpdateQueryParams;
var
  n1: Integer;
begin
  for n1 := 0 to Length(Self.Fields)-1 do
    if QueryOfUpdate.Params.FindParam(Self.Fields[n1].FieldName) <> nil then
      NewParamForQuery(QueryOfUpdate, Self.Fields[n1]);
end;

procedure TTable.CloneClassContent(ASrc, ADes: TTable);
var
  n1, n2: Integer;
begin
  for n1 := 0 to Length(ASrc.Fields)-1 do
    for n2 := 0 to Length(ADes.Fields)-1 do
      if ASrc.Fields[n1].FFieldName = ADes.Fields[n2].FFieldName then
      begin
        ADes.Fields[n2].FFieldName := ASrc.Fields[n1].FFieldName;
        ADes.Fields[n2].FDataType := ASrc.Fields[n1].FDataType;
        ADes.Fields[n2].FValue := ASrc.Fields[n1].FValue;
        ADes.Fields[n2].FSize := ASrc.Fields[n1].FSize;
        ADes.Fields[n2].FIsNullable := ASrc.Fields[n1].FIsNullable;
        ADes.Fields[n2].FOtherFieldName := ASrc.Fields[n1].FOtherFieldName;
        Break;
      end;
end;

procedure TTable.Unlisten;
begin
  with QueryOfInfo do
  begin
    Close;
    SQL.Clear;
    SQL.Text := 'unlisten ' + self.TableName + ';';
    ExecSQL;
  end;
end;

end.
