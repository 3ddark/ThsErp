unit StkCinsAile;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  TStkCinsAile = class(TEntity)
  private
    FAile: TField<string>;
  public
    property Aile: TField<string> read FAile write FAile;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkCinsAile.Create();
begin
  inherited;
  FAile := TField<string>.Create;
end;

destructor TStkCinsAile.Destroy;
begin
  FAile.Free;
  inherited;
end;

end.
