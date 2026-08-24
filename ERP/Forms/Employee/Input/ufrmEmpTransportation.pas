unit ufrmEmpTransportation;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, ufrmInputSimpleDB, SharedFormTypes, Ths.Helper.BaseTypes,
  Ths.Helper.Edit, EmpTransportation.Service, EmpTransportation, LocalizationManager;

type
  TfrmEmpTransportation = class(TfrmInputSimpleDB<TEmpTransportation, TEmpTransportationService>)
    pnlContent: TPanel;
    lblCarNo: TLabel;
    seCarNo: TSpinEdit;
    lblCarName: TLabel;
    edtCarName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpTransportation.BtnAcceptClick(Sender: TObject);
begin
  Table.CarNo := seCarNo.Value;
  Table.CarName := edtCarName.Text;
  inherited;
end;

procedure TfrmEmpTransportation.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmEmpTransportation.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtCarName.SetFocus;
end;

procedure TfrmEmpTransportation.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('emp_transportation.title_singular', 'Servis / Ulaşım');
  lblCarNo.Caption := TLocalizationManager.Translate('emp_transportation.lbl_car_no', 'Araç No');
  lblCarName.Caption := TLocalizationManager.Translate('emp_transportation.lbl_car_name', 'Araç / Güzergah Adı');
end;

procedure TfrmEmpTransportation.InitializeInputCase;
begin
  inherited;
  edtCarName.thsInputDataType := itString;
  edtCarName.MaxLength := 32;
end;

procedure TfrmEmpTransportation.RefreshData;
begin
  inherited;
  seCarNo.Value := Table.CarNo;
  edtCarName.Text := Table.CarName;
end;

end.
