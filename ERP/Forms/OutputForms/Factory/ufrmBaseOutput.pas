unit ufrmBaseOutput;

interface

{$I Ths.inc}

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Samples.Spin,
  Vcl.Menus,
  Vcl.AppEvnts,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.Dialogs,
  ufrmBase,
  Ths.Database.Table;

type
  TfrmBaseOutput = class(TfrmBase)
    pnlLeft: TPanel;
    splLeft: TSplitter;
    splHeader: TSplitter;
    pnlHeader: TPanel;
    pnlContent: TPanel;
    pmDB: TPopupMenu;
    procedure FormCreate(Sender: TObject); override;
  private
    { Private declarations }
  public
  end;

implementation

{$R *.dfm}

procedure TfrmBaseOutput.FormCreate(Sender: TObject);
begin
  inherited;

  btnClose.Visible := True;

  //Hide Left Panel and Top Panel when opening the base form. Set the form to use itself
  pnlLeft.Visible := False;
  splLeft.Visible := False;
  pnlHeader.Visible := False;
  splHeader.Visible := False;

  btnSpin.Visible := False;
end;

end.
