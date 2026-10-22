unit PurReceiptExtension;

// Mal kabul listesinin isteğe bağlı eklenti noktası. Başka bir modül (giriş kalite kontrol) initialization'da kendini
// kaydeder; satın alma modülü o modülün birimlerini kullanmaz. Atanmamışsa ya da modül kapalıysa menü gösterilmez,
// mal kabul / stok / fatura akışı eklentiden bağımsızdır.

interface

uses
  System.Classes;

type
  TPurReceiptActionAvailable = function: Boolean;
  TPurReceiptActionShow = procedure(AOwner: TComponent; AReceiptId: Int64; const AReceiptNo: string);

var
  // Giriş kalite kontrol: menü gösterilsin mi (modül açık + okuma yetkisi) / mal kabulün kontrol listesini aç
  GReceiptQualityAvailable: TPurReceiptActionAvailable = nil;
  GReceiptQualityShow: TPurReceiptActionShow = nil;

implementation

end.
