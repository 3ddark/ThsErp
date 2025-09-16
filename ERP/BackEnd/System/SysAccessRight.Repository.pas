unit SysAccessRight.Repository;

interface

uses
  SysUtils, Classes, Types, DB, System.Generics.Collections,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Stan.Param,
  BaseEntity, BaseRepository, SysAccessRight, SharedFormTypes;

type
  TSysAccessRightRepository = class(TBaseRepository<TSysAccessRight>)
  public
    constructor Create(AConnection: TFDConnection);
    function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
  end;

implementation

constructor TSysAccessRightRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysAccessRightRepository.IsAuthorized(APermissionType: TPermissionType; APermissionControl, AShowException: Boolean): Boolean;
begin
{
function IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
function TBaseRepository<T>.IsAuthorized(APermissionType: TPermissionType; APermissionControl: Boolean; AShowException: Boolean=True): Boolean;
var
  vField, vFilter, vMessage: string;//vSourceCode, vSourceName
//  LErisimHakki: TSysErisimHakki;
//  LKaynak: TSysKaynak;
begin
  Result := False;
  if APermissionControl then
  begin
    Result := True;
{
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
        vField := LErisimHakki.IsEkleme.FieldName;
        vFilter := ' and ' + LErisimHakki.IsEkleme.FieldName + '=true ';
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
      else if APermissionType = ptSpecial then
      begin
        vField := LErisimHakki.IsOzel.FieldName;
        vFilter := ' and ' + LErisimHakki.IsOzel.FieldName + '=true ';
        vMessage := 'SPECIAL';
      end;

      with Database.NewQuery() do
      try
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
      finally
        Free;
      end;

      if not Result then
      begin
        if AShowException then
          raise Exception.Create(
            'Process ' + vMessage + AddLBs(2) +
            'There is no access to this resource! : ' + TableName + ' ' + ClassName + sLineBreak +
            'Missing Permission Source Code for Table Name: ' + TableName);
      end;
    finally
      LErisimHakki.Free;
      LKaynak.Free;
    end;

  end
  else
    Result := True;
end;
}
  Result := True;
end;

end.
