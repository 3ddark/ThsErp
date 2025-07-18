unit StkCinsAile;

interface

uses
  SysUtils, Classes, Types, BaseEntity;

type
  TStkCinsAile = class(TEntity)
  private
    FAile: string;
  public
    property Aile: string read FAile write FAile;
  end;

implementation

end.
