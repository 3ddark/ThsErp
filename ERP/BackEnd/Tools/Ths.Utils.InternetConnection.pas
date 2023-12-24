unit Ths.Utils.InternetConnection;

interface

uses System.SysUtils, System.Net.HttpClientComponent;

type
  TInternetConnection = class
    class function Check: Boolean;
  end;

implementation

class function TInternetConnection.Check: Boolean;
var
  LClient: TNetHTTPClient;
begin
  Result := False;
  LClient := TNetHTTPClient.Create(nil);
  try
    try
      if LClient.Get( 'https://www.google.com' ).StatusCode = 200 then
      begin
        Result := True;
        Exit;
      end;
    except
      on E: Exception do
      begin
        Result := False;
        Exit;
      end;
    end;
  finally
    LClient.Free;
  end;
end;

end.

