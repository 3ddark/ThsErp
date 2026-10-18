GIB UBL-TR 1.2.1 paketinden (docs/UBL-TR1.2.1_Paketi) alinan dosyalar; uygulama exe yanindaki Resource\EInvoice'tan okur.
Degisiklikler (MSXML 6.0 icin):
- xsdrt/common/UBL-xmldsig-core-schema-2.1.xsd: DOCTYPE (ic DTD) kaldirildi, &dsig; varligi namespace metniyle degistirildi
  (MSXML sema yuklerken DTD'ye izin vermez).
- general.xslt: XPath 2.0 exists() -> boolean() (MSXML yalniz XSLT 1.0).
- irsaliye.xslt (e-Irsaliye onizleme): pakettekiyle ayni, degisiklik yok (MSXML ile calisiyor).
Yeni GIB paketi gelince ayni iki degisiklik tekrar yapilmali.
