unit StkCardKindInfo.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkCardKindInfo;

type
  TStkCardKindInfoRepository = class(TRepository<TStkCardKindInfo>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkCardKindInfo); override;
  end;

implementation

constructor TStkCardKindInfoRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkCardKindInfoRepository.Delete(AModel: TStkCardKindInfo);
begin
  Delete(AModel.Id);
end;

end.
