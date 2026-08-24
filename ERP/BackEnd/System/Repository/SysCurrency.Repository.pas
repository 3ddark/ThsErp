unit SysCurrency.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysCurrency, FilterCriterion;

type
  TSysCurrencyRepository = class(TRepository<TSysCurrency>)
  public
    constructor Create(AConnection: TFDConnection);
    destructor Destroy; override;
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TSysCurrency); override;
  end;

implementation

constructor TSysCurrencyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

destructor TSysCurrencyRepository.Destroy;
begin
  //
  inherited;
end;

function TSysCurrencyRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_currencies WHERE 1=1 ';
end;

procedure TSysCurrencyRepository.Delete(AModel: TSysCurrency);
begin
  Delete(AModel.Id);
end;

end.

