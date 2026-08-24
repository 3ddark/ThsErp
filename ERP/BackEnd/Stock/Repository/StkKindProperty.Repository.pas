unit StkKindProperty.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkKindProperty;

type
  TStkKindPropertyRepository = class(TRepository<TStkKindProperty>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkKindProperty); override;
  end;

implementation

constructor TStkKindPropertyRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkKindPropertyRepository.Delete(AModel: TStkKindProperty);
begin
  Delete(AModel.Id);
end;

end.
