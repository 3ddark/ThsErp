unit ufrmViewer;

interface

uses
    Winapi.Windows
  , Winapi.Messages
  , Winapi.ShellAPI
  , System.SysUtils
  , System.Variants
  , System.Classes
  , System.StrUtils
  , System.DateUtils
  , System.Math
  , System.IOUtils
  , Vcl.Graphics
  , Vcl.Controls
  , Vcl.Forms
  , Vcl.Dialogs
  , Vcl.StdCtrls
  , Vcl.ExtCtrls
  , Vcl.ComCtrls
  , Vcl.Menus
  , Vcl.Buttons
  , Vcl.AppEvnts
  , Vcl.Samples.Spin

  , Ths.Erp.Helper.BaseTypes
  , Ths.Erp.Helper.Edit
  , Ths.Erp.Helper.ComboBox
  , Ths.Erp.Helper.Memo

  , ufrmBase
  , Ths.Erp.Globals
  , Ths.Erp.Utils.PreviewHandler
  , Ths.Erp.Database.Table.UtdDokuman

  , cxGraphics
  , cxControls
  , cxLookAndFeels
  , cxLookAndFeelPainters
  , dxPDFCore
  , dxPDFBase
  , dxPDFText
  , dxPDFRecognizedObject
  , dxPDFDocument
  , dxBarBuiltInMenu
  , dxSkinsCore
  , dxSkinsDefaultPainters
  , dxCustomPreview
  , dxPDFDocumentViewer
  , dxPDFViewer
  ;

type
  TfrmViewer = class(TfrmBase)
    dxPDFViewer1: TdxPDFViewer;
    imgViewer: TImage;
    procedure FormActivate(Sender: TObject);
  private
    FFileName: string;
    FFileOpened: Boolean;
  public
    property FileName: string read FFileName write FFileName;
  published
    procedure btnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
  end;

implementation

uses
    Ths.Erp.Constants
  , udm
  ;

{$R *.dfm}

{ TfrmWebBrowser }

procedure TfrmViewer.btnAcceptClick(Sender: TObject);
begin
  //
end;

procedure TfrmViewer.FormActivate(Sender: TObject);
var
  LExt: string;
begin
  dxPDFViewer1.Visible := False;
  imgViewer.Visible := False;

  if not FFileOpened then
  begin
    FFileOpened := True;
    LExt := ExtractFileExt(FFileName).Replace('.', '');
    if LExt = FILE_EXT_PDF then
    begin
      dxPDFViewer1.Visible := True;
      dxPDFViewer1.LoadFromFile(FFileName);
    end
    else
    if (LExt = FILE_EXT_PNG)
    or (LExt = FILE_EXT_JPG)
    or (LExt = FILE_EXT_BMP)
    then
    begin
      imgViewer.Visible := True;
      imgViewer.Picture.LoadFromFile(FFileName);
    end
    else
    begin
      ShellExecute(0, 'open', PWideChar(FFileName), nil, nil, SW_NORMAL);
      Self.Close;
    end;
  end;
end;

procedure TfrmViewer.FormCreate(Sender: TObject);
begin
  inherited;
  FFileOpened := False;
end;

end.
