unit SetStkUrunTipleri.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, SetStkUrunTipleri;

type
  TSetStkUrunTipleriRepository = class(TRepository<TSetStkUrunTipleri>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TSetStkUrunTipleri; ACascade: TCascadeOperations = []); override;
  end;

implementation

constructor TSetStkUrunTipleriRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TSetStkUrunTipleriRepository.Delete(AModel: TSetStkUrunTipleri; ACascade: TCascadeOperations);
begin
  Delete(AModel.Id, ACascade);
end;

end.
