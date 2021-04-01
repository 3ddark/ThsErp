unit ufrmSetEInvIletisimKanallari;

interface

{$I ThsERP.inc}

uses
    Winapi.Windows
  , Winapi.Messages
  , System.SysUtils
  , System.Variants
  , System.Types
  , System.Classes
  , System.Math
  , System.UITypes
  , System.Rtti
  , Vcl.Menus
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.AppEvnts
  , Vcl.StdCtrls
  , Vcl.Samples.Spin

  , Data.DB


  //FastReport
  , frxClass
  , frxExportPDF
  , frxExportBaseDialog
  , frxDBSet

  //devex cx grid dependencies
  , dxCore
  , cxClasses
  , cxGridStrs
  , cxFilterConsts
  , cxFilterControlStrs
  , cxExport
  , cxGraphics
  , cxControls
  , cxDataStorage
  , cxEdit
  , cxNavigator
  , cxDBData
  , cxGridLevel
  , cxGridCustomView
  , cxGridCustomTableView
  , cxGridTableView
  , cxGridDBTableView
  , cxGrid
  , cxData
  , cxCustomData
  , cxLookAndFeels
  , cxLookAndFeelPainters
  , cxStyles
  , dxSkinsCore
  , dxSkinscxPCPainter
  , dxSkinBlack
  , dxSkinBlue
  , dxSkinBlueprint
  , dxSkinCaramel
  , dxSkinCoffee
  , dxSkinDarkRoom
  , dxSkinDarkSide
  , dxSkinDevExpressDarkStyle
  , dxSkinDevExpressStyle
  , dxSkinFoggy
  , dxSkinGlassOceans
  , dxSkinHighContrast
  , dxSkiniMaginary
  , dxSkinLilian
  , dxSkinLiquidSky
  , dxSkinLondonLiquidSky
  , dxSkinMcSkin
  , dxSkinMetropolis
  , dxSkinMetropolisDark
  , dxSkinMoneyTwins
  , dxSkinOffice2007Black
  , dxSkinOffice2007Blue
  , dxSkinOffice2007Green
  , dxSkinOffice2007Pink
  , dxSkinOffice2007Silver
  , dxSkinOffice2010Black
  , dxSkinOffice2010Blue
  , dxSkinOffice2010Silver
  , dxSkinOffice2013DarkGray
  , dxSkinOffice2013LightGray
  , dxSkinOffice2013White
  , dxSkinOffice2016Colorful
  , dxSkinOffice2016Dark
  , dxSkinPumpkin
  , dxSkinSeven
  , dxSkinSevenClassic
  , dxSkinSharp
  , dxSkinSharpPlus
  , dxSkinSilver
  , dxSkinSpringTime
  , dxSkinStardust
  , dxSkinSummer2008
  , dxSkinTheAsphaltWorld
  , dxSkinsDefaultPainters
  , dxSkinValentine
  , dxSkinVisualStudio2013Blue
  , dxSkinVisualStudio2013Dark
  , dxSkinVisualStudio2013Light
  , dxSkinVS2010
  , dxSkinWhiteprint
  , dxSkinXmas2008Blue
  , cxFilter
  , dxDateRanges
  , cxExtEditRepositoryItems
  , cxEditRepositoryItems

  //Base forms
  , ufrmBase
  , ufrmBaseDBGrid
  ;

type
  TfrmAyarEFaturaIletisimKanallari = class(TfrmBaseDBGrid)
  private
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  public
  published
  end;

implementation

uses
  Ths.Erp.Database.Singleton,
  ufrmSetEInvIletisimKanali,
  Ths.Erp.Database.Table.SetEInvIletisimKanali;

{$R *.dfm}

{ TfrmAyarEFaturaIletisimKanallari }

function TfrmAyarEFaturaIletisimKanallari.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmAyarEFaturaIletisimKanali.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmAyarEFaturaIletisimKanali.Create(Self, Self, TAyarEFaturaIletisimKanali.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmAyarEFaturaIletisimKanali.Create(Self, Self, Table.Clone(), pFormMode);
end;

end.
