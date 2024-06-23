unit Ths.Helper.ThsList;

interface

uses
  Classes, Generics.Collections;

type
  TThsList<T> = class(TList<T>)
  private
    FOnKil: TNotifyEvent;
    procedure SetOnKil(const Value: TNotifyEvent);
    procedure DoKill;
  public
    property OnKil: TNotifyEvent read FOnKil write SetOnKil;
    destructor Destroy; override;
  end;

implementation

{ TThsList<T> }

destructor TThsList<T>.Destroy;
begin
  DoKill;
  inherited;
end;

procedure TThsList<T>.DoKill;
begin
  if Assigned(FOnKil) then  FOnKil(Self);
end;

procedure TThsList<T>.SetOnKil(const Value: TNotifyEvent);
begin
  FOnKil := Value;
end;

end.
