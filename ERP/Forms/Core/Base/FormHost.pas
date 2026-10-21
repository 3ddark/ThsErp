unit FormHost;

// Liste ekranlarının ana ekrana sekme olarak gömülmesi.
//  - Dashboard GFormHost'u atar; TfrmGridBase.Show her açılışta sorar, True dönerse form sekmede gösterilmiştir.
//  - Sekmeye gömülü formun Left/Top'u sekmeye göredir: ondan açılan pencereler ana forma ortalanır.

interface

{$I Ths.inc}

uses
  System.Classes, Vcl.Forms;

type
  TFormHostFunc = function(AForm: TForm): Boolean of object;

var
  GFormHost: TFormHostFunc = nil;

// poOwnerFormCenter yerine: sahibi sekmeye gömülü formsa poMainFormCenter
function OwnerCenterPosition(AOwner: TComponent): TPosition;

implementation

function OwnerCenterPosition(AOwner: TComponent): TPosition;
begin
  if (AOwner is TCustomForm) and (TCustomForm(AOwner).Parent <> nil) then
    Result := poMainFormCenter
  else
    Result := poOwnerFormCenter;
end;

end.
