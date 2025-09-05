unit ufrmStkCinsAileX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ufrmInputSimpleDbX, SharedFormTypes, StkCinsAileService, StkCinsAile,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
  TfrmStkCinsAileX = class(TfrmInputSimpleDbX<TStkCinsAile, TStkCinsAileService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblaile: TLabel;
    edtaile: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
  published
    procedure BtnAcceptClick(Sender: TObject); override;
  public
  end;

implementation

{$R *.dfm}

procedure TfrmStkCinsAileX.BtnAcceptClick(Sender: TObject);
begin
  Table.Family.Value := edtaile.Text;
  inherited;
end;

procedure TfrmStkCinsAileX.FormCreate(Sender: TObject);
begin
  inherited;
  edtaile.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmStkCinsAileX.FormShow(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;

  Self.Caption := 'Stk Cins Aile Input';
  ActiveControl := edtaile;
  edtaile.SetFocus;
end;

end.
