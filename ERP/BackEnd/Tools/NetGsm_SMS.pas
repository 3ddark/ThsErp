// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl
//  >Import : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl>0
//  >Import : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?xsd=1
//  >Import : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?xsd=2
//  >Import : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl>1
// Encoding : UTF-8
// Version  : 1.0
// (02.06.2020 17:51:42 - - $Rev: 93209 $)
// ************************************************************************ //

unit NetGsm_SMS;

interface

uses Soap.InvokeRegistry, Soap.SOAPHTTPClient, System.Types, Soap.XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_UNQL = $0008;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]


  Array_Of_string = array of string;            { "http://www.w3.org/2001/XMLSchema"[GblUbnd] }
  return          =  type string;      { "SMS"[GblElm] }

  // ************************************************************************ //
  // Namespace : http://sms/
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // use       : literal
  // binding   : smsnnPortBinding
  // service   : SMS
  // port      : smsnnPort
  // URL       : http://soap.netgsm.com.tr:8080/Sms_webservis/SMS
  // ************************************************************************ //
  smsnn = interface(IInvokable)
  ['{E2A8F7E0-0C49-35CA-3B4F-E9F6FDF7AF75}']
    function  gelensms(const username: string; const password: string): string; stdcall;
    function  gelensmsV2(const username: string; const password: string; const startdate: string; const stopdate: string; const type_: Integer): string; stdcall;
    function  sms_gonder_nn(const username: string; const password: string; const company: string; const header: string; const msg: Array_Of_string; const gsm: Array_Of_string; 
                            const encoding: string; const startdate: string; const stopdate: string; const bayikodu: string): return; stdcall;
    function  smsGonderNNV2(const username: string; const password: string; const header: string; const msg: Array_Of_string; const gsm: Array_Of_string; const encoding: string; 
                            const startdate: string; const stopdate: string; const bayikodu: string; const filter: Integer): string; stdcall;
    function  sms_gonder_1n(const username: string; const password: string; const company: string; const header: string; const msg: string; const gsm: Array_Of_string; 
                            const encoding: string; const startdate: string; const stopdate: string; const bayikodu: string): string; stdcall;
    function  smsGonder1NV2(const username: string; const password: string; const header: string; const msg: string; const gsm: Array_Of_string; const encoding: string; 
                            const startdate: string; const stopdate: string; const bayikodu: string; const filter: Integer): string; stdcall;
    function  kredi(const username: string; const password: string): string; stdcall;
    function  paketkampanya(const username: string; const password: string): string; stdcall;
    function  rapor(const username: string; const password: string; const bulkid: string; const status: Integer; const version: Integer): string; stdcall;
    function  rapor_v2(const username: string; const password: string; const bulkid: string; const status: Integer; const version: Integer; const telno: Array_Of_string; 
                       const detail: Integer): string; stdcall;
    function  raporV3(const username: string; const password: string; const bulkid: string; const telno: Array_Of_string; const header: string; const startdate: string; 
                      const stopdate: string; const type_: Integer; const status: Integer; const detail: Integer): string; stdcall;
    function  gondericiadlari(const username: string; const password: string): string; stdcall;
  end;

function Getsmsnn(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): smsnn;


implementation
  uses System.SysUtils;

function Getsmsnn(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): smsnn;
const
  defWSDL = 'http://soap.netgsm.com.tr:8080/Sms_webservis/SMS?wsdl';
  defURL  = 'http://soap.netgsm.com.tr:8080/Sms_webservis/SMS';
  defSvc  = 'SMS';
  defPrt  = 'smsnnPort';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as smsnn);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;


initialization
  { smsnn }
  InvRegistry.RegisterInterface(TypeInfo(smsnn), 'http://sms/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(smsnn), '');
  InvRegistry.RegisterInvokeOptions(TypeInfo(smsnn), ioDocument);
  { smsnn.gelensms }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'gelensms', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensms', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensms', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensms', 'return', '',
                                '', IS_UNQL);
  { smsnn.gelensmsV2 }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'gelensmsV2', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'type_', 'type',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gelensmsV2', 'return', '',
                                '', IS_UNQL);
  { smsnn.sms_gonder_nn }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'sms_gonder_nn', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_REF);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'company', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'header', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'msg', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'gsm', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'encoding', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'bayikodu', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_nn', 'return', '',
                                '[Namespace="SMS"]', IS_REF);
  { smsnn.smsGonderNNV2 }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'smsGonderNNV2', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'header', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'msg', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'gsm', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'encoding', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'bayikodu', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'filter', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonderNNV2', 'return', '',
                                '', IS_UNQL);
  { smsnn.sms_gonder_1n }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'sms_gonder_1n', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'company', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'header', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'msg', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'gsm', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'encoding', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'bayikodu', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'sms_gonder_1n', 'return', '',
                                '', IS_UNQL);
  { smsnn.smsGonder1NV2 }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'smsGonder1NV2', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'header', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'msg', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'gsm', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'encoding', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'bayikodu', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'filter', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'smsGonder1NV2', 'return', '',
                                '', IS_UNQL);
  { smsnn.kredi }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'kredi', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'kredi', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'kredi', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'kredi', 'return', '',
                                '', IS_UNQL);
  { smsnn.paketkampanya }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'paketkampanya', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'paketkampanya', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'paketkampanya', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'paketkampanya', 'return', '',
                                '', IS_UNQL);
  { smsnn.rapor }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'rapor', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'bulkid', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'status', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'version', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor', 'return', '',
                                '', IS_UNQL);
  { smsnn.rapor_v2 }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'rapor_v2', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'bulkid', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'status', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'version', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'telno', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'detail', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'rapor_v2', 'return', '',
                                '', IS_UNQL);
  { smsnn.raporV3 }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'raporV3', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'bulkid', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'telno', '',
                                '', IS_UNBD or IS_NLBL or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'header', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'startdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'stopdate', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'type_', 'type',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'status', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'detail', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'raporV3', 'return', '',
                                '', IS_UNQL);
  { smsnn.gondericiadlari }
  InvRegistry.RegisterMethodInfo(TypeInfo(smsnn), 'gondericiadlari', '',
                                 '[ReturnName="return"]', IS_OPTN or IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gondericiadlari', 'username', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gondericiadlari', 'password', '',
                                '', IS_UNQL);
  InvRegistry.RegisterParamInfo(TypeInfo(smsnn), 'gondericiadlari', 'return', '',
                                '', IS_UNQL);
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_string), 'http://www.w3.org/2001/XMLSchema', 'Array_Of_string');
  RemClassRegistry.RegisterXSInfo(TypeInfo(return), 'SMS', 'return');

end.