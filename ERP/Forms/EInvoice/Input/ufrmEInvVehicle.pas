unit ufrmEInvVehicle;

interface

{$I Ths.inc}

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, System.Generics.Collections,
  ufrmInputSimpleDB, SharedFormTypes, LocalizationManager,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  EInvVehicle.Service, EInvVehicle;

type
  TfrmEInvVehicle = class(TfrmInputSimpleDB<TEInvVehicle, TEInvVehicleService>)
    pnlContent: TPanel;
    lblPlateNo: TLabel;
    edtPlateNo: TEdit;
    lblIsTrailer: TLabel;
    chkIsTrailer: TCheckBox;
    lblDescription: TLabel;
    edtDescription: TEdit;
    lblIsActive: TLabel;
    chkIsActive: TCheckBox;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

uses
  EInvLookup;

procedure TfrmEInvVehicle.BtnAcceptClick(Sender: TObject);
begin
  // FK id'leri HelperProcess içinde doğrudan Table'a yazılır
  Table.PlateNo := edtPlateNo.Text;
  Table.IsTrailer := chkIsTrailer.Checked;
  Table.Description := edtDescription.Text;
  Table.IsActive := chkIsActive.Checked;
  inherited;
end;

procedure TfrmEInvVehicle.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtPlateNo.thsInputDataType := itString;
  edtPlateNo.CharCase := TEditCharCase.ecUpperCase;
  edtDescription.thsInputDataType := itString;
end;

procedure TfrmEInvVehicle.FormShow(Sender: TObject);
begin
  inherited;
  if edtPlateNo.CanFocus then
    edtPlateNo.SetFocus;
end;

procedure TfrmEInvVehicle.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.TitleSingular, 'Vehicle / Trailer');
  lblPlateNo.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColPlateNo, 'Plate No');
  lblIsTrailer.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColIsTrailer, 'Trailer');
  lblDescription.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColDescription, 'Description');
  lblIsActive.Caption := TLocalizationManager.Translate(TLangKeys.TEInvVehicle.ColIsActive, 'Active');
end;

procedure TfrmEInvVehicle.RefreshData;
begin
  inherited;
  edtPlateNo.Text := Table.PlateNo;
  chkIsTrailer.Checked := Table.IsTrailer;
  edtDescription.Text := Table.Description;
  chkIsActive.Checked := Table.IsActive;
end;

end.
