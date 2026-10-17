unit EInvTaxExemption.Repository;

interface

uses
  SysUtils, Classes, Types, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, System.Rtti, Entity, Repository, FilterCriterion,
  AppContext, EInvTaxExemption;

type
  TEInvTaxExemptionRepository = class(TRepository<TEInvTaxExemption>)
  protected
    function PrepareAddSql: string;
    function PrepareUpdateSql: string;
    function PrepareDeleteSql: string;

    procedure SetInsertParams(Q: TFDQuery; AModel: TEInvTaxExemption; AIndex: Integer = -1);
    procedure SetUpdateParams(Q: TFDQuery; AModel: TEInvTaxExemption; AIndex: Integer = -1);
    function MapFromQuery(Q: TFDQuery): TEInvTaxExemption; override;

    function DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;

    function DoFind(AFilter: TFilterCriteria; ALock: Boolean = False): TObjectList<TEInvTaxExemption>; override;
    function DoFindById(AId: TValue; ALock: Boolean = False): TEInvTaxExemption; override;
    function DoFindOne(AFilter: TFilterCriteria; ALock: Boolean = False): TEInvTaxExemption; override;

    procedure DoAdd(AModel: TEInvTaxExemption); override;
    procedure DoAddBatch(AModels: TArray<TEInvTaxExemption>); override;

    procedure DoUpdate(AModel: TEInvTaxExemption); override;
    procedure DoUpdateBatch(AModels: TArray<TEInvTaxExemption>); override;

    procedure DoDelete(AID: TValue); override;
    procedure DoDelete(AModel: TEInvTaxExemption); override;
    procedure DoDeleteBatch(AModels: TArray<TEInvTaxExemption>); override;
    procedure DoDeleteBatch(AIDs: TArray<TValue>); override;
    procedure DoDeleteBatch(AFilter: TFilterCriteria); override;
  public
    constructor Create(AConnection: TFDConnection);
    function CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
    function UsageCount(AId: Int64): Integer;
  end;

implementation

constructor TEInvTaxExemptionRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TEInvTaxExemptionRepository.CodeExists(const ACode: string; AExcludeId: Int64): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT 1 FROM public.einv_tax_exemption WHERE code = :code AND id <> :id';
    Q.ParamByName('code').AsWideString := ACode;
    Q.ParamByName('id').AsLargeInt := AExcludeId;
    LogQuery(Q, 'CodeExists');
    Q.Open;
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

// Kaydı kullanan satır sayısı (silmek yerine pasif yapılmalı)
function TEInvTaxExemptionRepository.UsageCount(AId: Int64): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := 'SELECT (SELECT count(*) FROM public.sls_invoice WHERE einv_tax_exemption_id = :id) AS cnt';
    Q.ParamByName('id').AsLargeInt := AId;
    LogQuery(Q, 'UsageCount');
    Q.Open;
    Result := Q.FieldByName('cnt').AsInteger;
  finally
    Q.Free;
  end;
end;

function TEInvTaxExemptionRepository.PrepareAddSql: string;
begin
  Result := 'INSERT INTO public.' + Self.GetTableName(TEInvTaxExemption) +
            ' (code, name, exemption_group, einv_invoice_type_id, requires_gtip, requires_diib, requires_zero_vat, is_active) ' +
            ' VALUES (:code, :name, :exemption_group, :einv_invoice_type_id, :requires_gtip, :requires_diib, :requires_zero_vat, :is_active)';
end;

function TEInvTaxExemptionRepository.PrepareUpdateSql: string;
begin
  Result := 'UPDATE public.' + Self.GetTableName(TEInvTaxExemption) +
            ' SET code = :code, name = :name, exemption_group = :exemption_group, einv_invoice_type_id = :einv_invoice_type_id, requires_gtip = :requires_gtip, requires_diib = :requires_diib, requires_zero_vat = :requires_zero_vat, is_active = :is_active ' +
            ' WHERE id = :id';
end;

function TEInvTaxExemptionRepository.PrepareDeleteSql: string;
begin
  //WHERE kısmı özellikle böyle yazıldı. Filtre vermeden işlem yapılmaması için. Hatalı kodlamada tüm tabloyu siler.
  Result := 'DELETE FROM public.' + Self.GetTableName(TEInvTaxExemption) + ' WHERE';
end;

procedure TEInvTaxExemptionRepository.SetInsertParams(Q: TFDQuery; AModel: TEInvTaxExemption; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('exemption_group').AsSmallInt := AModel.ExemptionGroup;
    Q.ParamByName('requires_gtip').AsBoolean := AModel.RequiresGtip;
    Q.ParamByName('requires_diib').AsBoolean := AModel.RequiresDiib;
    Q.ParamByName('requires_zero_vat').AsBoolean := AModel.RequiresZeroVat;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('exemption_group').AsSmallInts[AIndex] := AModel.ExemptionGroup;
    Q.ParamByName('requires_gtip').AsBooleans[AIndex] := AModel.RequiresGtip;
    Q.ParamByName('requires_diib').AsBooleans[AIndex] := AModel.RequiresDiib;
    Q.ParamByName('requires_zero_vat').AsBooleans[AIndex] := AModel.RequiresZeroVat;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('einv_invoice_type_id'), ftLargeint, AModel.EinvInvoiceTypeId, AIndex);
end;

procedure TEInvTaxExemptionRepository.SetUpdateParams(Q: TFDQuery; AModel: TEInvTaxExemption; AIndex: Integer);

begin
  if AIndex < 0 then
  begin
    Q.ParamByName('id').AsLargeInt := AModel.Id;
    Q.ParamByName('code').AsWideString := AModel.Code;
    Q.ParamByName('name').AsWideString := AModel.Name;
    Q.ParamByName('exemption_group').AsSmallInt := AModel.ExemptionGroup;
    Q.ParamByName('requires_gtip').AsBoolean := AModel.RequiresGtip;
    Q.ParamByName('requires_diib').AsBoolean := AModel.RequiresDiib;
    Q.ParamByName('requires_zero_vat').AsBoolean := AModel.RequiresZeroVat;
    Q.ParamByName('is_active').AsBoolean := AModel.IsActive;
  end
  else
  begin
    Q.ParamByName('id').AsLargeInts[AIndex] := AModel.Id;
    Q.ParamByName('code').AsWideStrings[AIndex] := AModel.Code;
    Q.ParamByName('name').AsWideStrings[AIndex] := AModel.Name;
    Q.ParamByName('exemption_group').AsSmallInts[AIndex] := AModel.ExemptionGroup;
    Q.ParamByName('requires_gtip').AsBooleans[AIndex] := AModel.RequiresGtip;
    Q.ParamByName('requires_diib').AsBooleans[AIndex] := AModel.RequiresDiib;
    Q.ParamByName('requires_zero_vat').AsBooleans[AIndex] := AModel.RequiresZeroVat;
    Q.ParamByName('is_active').AsBooleans[AIndex] := AModel.IsActive;
  end;

  SetNullableParam(Q.ParamByName('einv_invoice_type_id'), ftLargeint, AModel.EinvInvoiceTypeId, AIndex);
end;

function TEInvTaxExemptionRepository.MapFromQuery(Q: TFDQuery): TEInvTaxExemption;
begin
  Result := TEInvTaxExemption.Create;
  Result.Id := Q.FieldByName('id').AsLargeInt;
  Result.Code := Q.FieldByName('code').AsString;
  Result.Name := Q.FieldByName('name').AsString;
  Result.ExemptionGroup := Q.FieldByName('exemption_group').AsInteger;
  Result.EinvInvoiceTypeId := Q.FieldByName('einv_invoice_type_id').AsLargeInt;
  Result.RequiresGtip := Q.FieldByName('requires_gtip').AsBoolean;
  Result.RequiresDiib := Q.FieldByName('requires_diib').AsBoolean;
  Result.RequiresZeroVat := Q.FieldByName('requires_zero_vat').AsBoolean;
  Result.IsActive := Q.FieldByName('is_active').AsBoolean;
  Result.InvoiceTypeCode := Q.FieldByName('invoice_type_code').AsString;
end;

function TEInvTaxExemptionRepository.DoFindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
var
  Criteria: TFilterCriterion;
  SelectCols: string;
begin
  SelectCols := Self.BuildSelectColumns(['id']);
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT ' + SelectCols + ' FROM ' + Self.GetFullViewName(TEInvTaxExemption) + ' WHERE 1=1 ';

  if Assigned(AFilter) and (AFilter.Count > 0) then
  begin
    for Criteria in AFilter do
      Result.SQL.Text := Result.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;
    for Criteria in AFilter do
      Result.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
  end;
end;

function TEInvTaxExemptionRepository.DoFind(AFilter: TFilterCriteria; ALock: Boolean): TObjectList<TEInvTaxExemption>;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := TObjectList<TEInvTaxExemption>.Create(True);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, False, False);

    if Assigned(AFilter) and (AFilter.Count > 0) then
      for Criteria in AFilter do
        Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoFind');
    Q.Open;
    while not Q.Eof do
    begin
      Result.Add(MapFromQuery(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TEInvTaxExemptionRepository.DoFindById(AId: TValue; ALock: Boolean): TEInvTaxExemption;
var
  Q: TFDQuery;
  Criteria: TFilterCriteria;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  Criteria := TFilterCriteria.Create;
  try
    Q.Connection := Connection;

    Criteria.Add(TFilterCriterion.New('id', '=', AId));
    Q.SQL.Text := Self.PrepareSelectFromView(Criteria, ALock, True, False);

    Q.ParamByName('id').AsLargeInt := AId.AsInt64;
    LogQuery(Q, 'DoFindById');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
    Criteria.Free;
  end;
end;

function TEInvTaxExemptionRepository.DoFindOne(AFilter: TFilterCriteria; ALock: Boolean): TEInvTaxExemption;
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  Result := nil;
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := Self.PrepareSelectFromView(AFilter, ALock, True, False);

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;
    LogQuery(Q, 'DoFindOne');
    Q.Open;

    if not Q.IsEmpty then
      Result := MapFromQuery(Q);
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoAdd(AModel: TEInvTaxExemption);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql + ' RETURNING id';
    SetInsertParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoAdd');
    Q.Open;
    AModel.Id := Q.FieldByName('id').AsLargeInt;
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoAddBatch(AModels: TArray<TEInvTaxExemption>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareAddSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetInsertParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoAddBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoUpdate(AModel: TEInvTaxExemption);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    SetUpdateParams(Q, AModel);
    ApplyNullPolicy(Q);
    LogQuery(Q, 'DoUpdate');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoUpdateBatch(AModels: TArray<TEInvTaxExemption>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareUpdateSql;
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      SetUpdateParams(Q, AModels[I], I);

    ApplyNullPolicy(Q);

    LogQuery(Q, 'DoUpdateBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoDelete(AID: TValue);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.ParamByName('id').AsLargeInt := AID.AsInt64;
    LogQuery(Q, 'DoDelete');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoDelete(AModel: TEInvTaxExemption);
begin
  Delete(AModel.Id);
end;

procedure TEInvTaxExemptionRepository.DoDeleteBatch(AModels: TArray<TEInvTaxExemption>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AModels);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AModels[I].Id;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoDeleteBatch(AIDs: TArray<TValue>);
var
  Q: TFDQuery;
  I, Count: Integer;
begin
  Count := Length(AIDs);
  if Count = 0 then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' id = :id';
    Q.Params.ArraySize := Count;

    for I := 0 to Count - 1 do
      Q.ParamByName('id').AsLargeInts[I] := AIDs[I].AsInt64;

    LogQuery(Q, 'DoDeleteBatch');
    Q.Execute(Count, 0);
  finally
    Q.Free;
  end;
end;

procedure TEInvTaxExemptionRepository.DoDeleteBatch(AFilter: TFilterCriteria);
var
  Q: TFDQuery;
  Criteria: TFilterCriterion;
begin
  if not Assigned(AFilter) or (AFilter.Count = 0) then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Connection;
    Q.SQL.Text := PrepareDeleteSql + ' 1=1 ';

    for Criteria in AFilter do
      Q.SQL.Text := Q.SQL.Text + ' AND ' + Criteria.FieldName + ' ' + Criteria.Operator + ' :' + Criteria.ParamName;

    for Criteria in AFilter do
      Q.ParamByName(Criteria.ParamName).Value := Criteria.Value.AsVariant;

    LogQuery(Q, 'DoDeleteBatch');
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
