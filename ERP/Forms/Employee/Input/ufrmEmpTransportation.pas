unit ufrmEmpTransportation;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.ComboBox,
  EmpTransportation.Service, EmpTransportation;

type
  TfrmEmpTransportation = class(TfrmInputSimpleDB<TEmpTransportation, TEmpTransportationService>)
    pnlContent: TPanel;
    lblCarNo: TLabel;
    edtCarNo: TEdit;
    lblCarName: TLabel;
    edtCarName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmEmpTransportation.BtnAcceptClick(Sender: TObject);
begin
  Table.CarNo := StrToIntDef(edtCarNo.Text, 0);
  Table.CarName := edtCarName.Text;
  inherited;
end;

procedure TfrmEmpTransportation.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtCarNo.thsInputDataType := itInteger;
  edtCarName.thsInputDataType := itString;
end;

procedure TfrmEmpTransportation.FormShow(Sender: TObject);
begin
  inherited;
  if edtCarNo.CanFocus then
    edtCarNo.SetFocus;
end;

procedure TfrmEmpTransportation.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTransportation.TitleSingular, 'Shuttle Service');
  lblCarNo.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTransportation.ColCarNo, 'Car No');
  lblCarName.Caption := TLocalizationManager.Translate(TLangKeys.TEmpTransportation.ColCarName, 'Car Name');
end;

procedure TfrmEmpTransportation.RefreshData;
begin
  inherited;
  edtCarNo.Text := IntToStr(Table.CarNo);
  edtCarName.Text := Table.CarName;
end;

end.
