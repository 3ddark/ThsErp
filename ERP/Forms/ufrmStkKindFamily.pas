unit ufrmStkKindFamily;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  StkKindFamilyService, StkKindFamily, Ths.Helper.BaseTypes, Ths.Helper.Edit,
  Ths.Helper.ComboBox;

type
  TfrmStkKindFamily = class(TfrmInputSimpleDbX<TStkKindFamily, TStkKindFamilyService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblaile: TLabel;
    edtfamily: TEdit;
    lbldescription: TLabel;
    lblactive: TLabel;
    mmodescription: TMemo;
    chkactive: TCheckBox;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  private
  published
    procedure BtnAcceptClick(Sender: TObject); override;
  public
  end;

implementation

{$R *.dfm}

procedure TfrmStkKindFamily.BtnAcceptClick(Sender: TObject);
begin
  Table.Family.Value := edtfamily.Text;
  Table.Description.Value := mmodescription.Lines.Text;
  Table.Active.Value := chkactive.Checked;
  inherited;
end;

procedure TfrmStkKindFamily.FormCreate(Sender: TObject);
begin
  inherited;
  edtfamily.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmStkKindFamily.FormShow(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;

  Self.Caption := 'Stk Cins Aile Input';

  edtfamily.SetFocus;
end;

end.

