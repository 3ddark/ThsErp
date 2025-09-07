unit ufrmStkCinsAileX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  StkCinsAileService, StkCinsAile, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.ComboBox;

type
  TfrmStkCinsAileX = class(TfrmInputSimpleDbX<TStkCinsAile, TStkCinsAileService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblaile: TLabel;
    edtfamily: TEdit;
    mmodescription: TMemo;
    chkactive: TCheckBox;
    lbldescription: TLabel;
    lblactive: TLabel;
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
  Table.Family.Value := edtfamily.Text;
  Table.Description.Value := mmodescription.Lines.Text;
  Table.Active.Value := chkactive.Checked;
  inherited;
end;

procedure TfrmStkCinsAileX.FormCreate(Sender: TObject);
begin
  inherited;
  edtfamily.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmStkCinsAileX.FormShow(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;

  Self.Caption := 'Stk Cins Aile Input';

  edtfamily.SetFocus;
end;

end.

