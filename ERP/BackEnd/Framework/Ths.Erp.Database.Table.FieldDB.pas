unit Ths.Erp.Database.Table.FieldDB;

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
  TFieldDB = class
  private
    FFieldName: string;
    FDataType: TFieldType;
    FValue: Variant;
    FSize: Integer;
    FIsNullable: Boolean;
    FOtherFieldName: string;
    FOwnerTable: Ths.Erp.Database.Table.TTable;
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
    property OwnerTable: Ths.Erp.Database.Table.TTable read FOwnerTable write FOwnerTable;
    property Title: string read FTitle write FTitle;

    constructor Create(const AFieldName: string;
                       const AFieldType: TFieldType;
                       const AValue: Variant;
                       AOwnerTable: Ths.Erp.Database.Table.TTable;
                       const ATitle: string;
                       const AOtherFieldName: string = '';
                       const AMaxLength: Integer=0;
                       const AIsNullable: Boolean=True);

    procedure Clone(var pField: TFieldDB);
    //procedure SetControlProperty(const pTableName: string; pControl: TWinControl);
  end;

implementation

uses
  Ths.Erp.Globals,
  Ths.Erp.Constants,
  Ths.Erp.Database.Singleton;

constructor TFieldDB.Create(
  const AFieldName: string;
  const AFieldType: TFieldType;
  const AValue: Variant;
  AOwnerTable: Ths.Erp.Database.Table.TTable;
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
    SetLength(FOwnerTable.Fields, Length(FOwnerTable.Fields)+1);
    FOwnerTable.Fields[Length(FOwnerTable.Fields)-1] := Self
  end;
end;

destructor TFieldDB.Destroy;
begin
  inherited;
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

end.
