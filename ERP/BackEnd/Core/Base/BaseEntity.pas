unit BaseEntity;

interface

uses
  SysUtils, Classes, Types;

type
  IEntity = interface
    ['{E7D242C9-BD12-48FB-8D12-883B52EA0347}']

    function GetId: Integer;
    procedure SetId(AValue: Integer);

    property Id: Integer read GetId write SetId;
  end;

  TEntity = class(TInterfacedObject, IEntity)
  private
    FId: Integer;
  protected
    function GetId: Integer;
    procedure SetId(AValue: Integer);
  public
    property Id: Integer read FId write FId;
  end;

implementation

function TEntity.GetId: Integer;
begin
  Result := FId;
end;

procedure TEntity.SetId(AValue: Integer);
begin
  FId := AValue;
end;

end.

