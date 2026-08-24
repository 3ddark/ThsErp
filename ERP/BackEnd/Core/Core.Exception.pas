unit Core.Exception;

interface

uses
  System.SysUtils;

type
  EAppException = class(Exception)
  protected
    class function GetMessage: string; virtual; abstract;
  public
    constructor Create; reintroduce;
  end;

implementation

constructor EAppException.Create;
begin
  inherited Create(GetMessage);
end;

end.

