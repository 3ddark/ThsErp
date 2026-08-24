unit StkImage.Repository;

interface

uses
  SysUtils, Classes, Contnrs, Types, DB, System.Generics.Collections,
  FireDAC.Comp.Client, Entity, Repository, StkImage;

type
  TStkImageRepository = class(TRepository<TStkImage>)
  public
    constructor Create(AConnection: TFDConnection);
    procedure Delete(AModel: TStkImage); override;
  end;

implementation

constructor TStkImageRepository.Create(AConnection: TFDConnection);
begin
  inherited Create(AConnection);
end;

procedure TStkImageRepository.Delete(AModel: TStkImage);
begin
  Delete(AModel.Id);
end;

end.
