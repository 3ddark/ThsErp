unit ufrmSysUomType;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUomType.Service, SysUomType;

type
  TfrmSysUomType = class(TfrmInputSimpleDB<TSysUomType, TSysUomTypeService>)
    pnlContent: TPanel;
    lblMeasureType: TLabel;
    edtMeasureType: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUomType.BtnAcceptClick(Sender: TObject);
begin
  Table.MeasureType := edtMeasureType.Text;
  inherited;
end;

procedure TfrmSysUomType.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysUomType.InitializeInputCase;
begin
  inherited;
  edtMeasureType.thsInputDataType := itString;
end;

procedure TfrmSysUomType.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Unit of Measurement Type';

  edtMeasureType.SetFocus;
end;

procedure TfrmSysUomType.RefreshData;
begin
  inherited;
  edtMeasureType.Text := Table.MeasureType;
end;

end.
