unit ufrmSysGridColColors;

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
  TfrmSysGridColColors = class(TfrmBaseDBGrid)
  protected
    function CreateInputForm(Sender: TObject; pFormMode: TInputFormMode):TForm; override;
  published
    procedure FormCreate(Sender: TObject);override;
    procedure FormShow(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Database.Singleton
  , Ths.Erp.Constants
  , ufrmSysGridColColor
  , Ths.Erp.Database.Table.SysGridColColor
  ;

{$R *.dfm}

function TfrmSysGridColColors.CreateInputForm(Sender: TObject; pFormMode: TInputFormMode): TForm;
begin
  Result := nil;
  if (pFormMode = ifmRewiev) then
    Result := TfrmSysGridColColor.Create(Self, Self, Table.Clone(), pFormMode)
  else if (pFormMode = ifmNewRecord) then
    Result := TfrmSysGridColColor.Create(Self, Self, TSysGridColColor.Create(Table.Database), pFormMode)
  else if (pFormMode = ifmCopyNewRecord) then
    Result := TfrmSysGridColColor.Create(Self, Self, Table.Clone(), pFormMode);
end;

procedure TfrmSysGridColColors.FormCreate(Sender: TObject);
begin
  QueryDefaultFilter := '';
  QueryDefaultOrder := TSysGridColColor(Table).TableName1.FieldName + ' ASC, ' +
                       TSysGridColColor(Table).ColumnName.FieldName + ' ASC';
  inherited;
end;

procedure TfrmSysGridColColors.FormShow(Sender: TObject);
begin
  inherited;
  mniCopyRecord.Visible := True;
end;

end.
