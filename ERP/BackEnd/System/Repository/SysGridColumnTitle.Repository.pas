unit SysGridColumnTitle.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SysGridColumnTitle, FilterCriterion;

type
  TSysGridColumnTitleRepository = class(TRepository<TSysGridColumnTitle>)
  public
    constructor Create(AConnection: TFDConnection);
    function FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery; override;
    procedure Delete(AModel: TSysGridColumnTitle; ACascade: TCascadeOperations = []); override;
  end;

implementation

constructor TSysGridColumnTitleRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

function TSysGridColumnTitleRepository.FindAllGridQuery(AFilter: TFilterCriteria): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Self.Connection;
  Result.SQL.Text := 'SELECT * FROM vw_sys_grid_column_title WHERE 1=1 ';
end;

procedure TSysGridColumnTitleRepository.Delete(AModel: TSysGridColumnTitle; ACascade: TCascadeOperations);
begin
  Delete(AModel.Id, ACascade);
end;

end.
