unit BaseEntity;

interface

uses
  SysUtils, Classes, Types;

type
  IField = interface
    ['{E7D242C9-BD12-48FB-8D12-883B52EA0347}']
  end;

  TField<T> = class(TInterfacedObject, IField)
  private
    FValue: T;
    FOldValue: T;
    procedure SetOldValue(const AValue: T);
    procedure SetValue(const AValue: T);
  public
    property Value: T read FValue write SetValue;
    property OldValue: T read FOldValue write SetOldValue;

    procedure ValueFirstSet(const AValue: T);

    function ValueIsChanged: Boolean;
  end;

  IEntity = interface
    ['{E7D242C9-BD12-48FB-8D12-883B52EA0347}']
  end;

  TEntity = class(TInterfacedObject, IEntity)
  private
    FId: TField<Integer>;
  public
    property Id: TField<Integer> read FId write FId;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

implementation

constructor TEntity.Create;
begin
  FId := TField<Integer>.Create;
end;

destructor TEntity.Destroy;
begin
  FId.Free;
  inherited;
end;

procedure TField<T>.SetOldValue(const AValue: T);
begin
  FOldValue := AValue;
end;

procedure TField<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
end;

procedure TField<T>.ValueFirstSet(const AValue: T);
begin
  Self.FValue := AValue;
  Self.FOldValue := AValue;
end;

function TField<T>.ValueIsChanged: Boolean;
begin
  Result := OldValue <> Value;
end;

end.

