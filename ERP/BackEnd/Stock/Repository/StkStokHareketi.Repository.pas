unit StkStokHareketi.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkStokHareketi;

type
  TStkStokHareketiRepository = class(TRepository<TStkStokHareketi>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkStokHareketi; ACascade: TCascadeOperations = []); override;
  end;

implementation

constructor TStkStokHareketiRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkStokHareketiRepository.Delete(AModel: TStkStokHareketi; ACascade: TCascadeOperations);
begin
  Delete(AModel.Id, ACascade);
end;

end.
