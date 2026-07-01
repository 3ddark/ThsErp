unit ufrmSysGridColSummaries;

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
  , FireDAC.DatS
  , FireDAC.DApt
  , FireDAC.UI.Intf
  , FireDAC.VCLUI.Wait
  , FireDAC.Comp.Client
  , FireDAC.Stan.Param
  , FireDAC.Stan.Intf
  , FireDAC.Stan.Option
  , FireDAC.Stan.Error
  , FireDAC.Stan.Async
  , FireDAC.Stan.Def
  , FireDAC.Stan.Pool
  , FireDAC.Phys
  , FireDAC.Phys.PG


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

  //Base forms
  , ufrmBase
  , ufrmBaseDBGrid
  ;

type
  TfrmSysGridColSummaries = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Database.Singleton
  , Ths.Erp.Constants
  , ufrmSysGridColSummary
  , Ths.Erp.Database.Table.SysGridColSummary
  ;

{$R *.dfm}

function TfrmSysGridColSummaries.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysGridColSummary.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysGridColSummary.Create(Self, Self, TSysGridColSummary.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColSummary.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysGridColSummaries.FormShow(Sender: TObject);
begin
  inherited;
  mniCopyRecord.Visible := True;
end;

end.
