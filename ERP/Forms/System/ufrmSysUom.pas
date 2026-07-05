unit ufrmSysUom;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysUom.Service, SysUom,
  SysUomType.Service, SysUomType, ufrmSysUomTypes;

type
  TfrmSysUom = class(TfrmInputSimpleDB<TSysUom, TSysUomService>)
    pnlContent: TPanel;
    edtMultiplier: TEdit;
    chkDecimal: TCheckBox;
    edtMeasureTypeId: TEdit;
    edtDescription: TEdit;
    edtUnitEInv: TEdit;
    edtUnit: TEdit;
    lblMultiplier: TLabel;
    lblDecimal: TLabel;
    lblMeasureTypeId: TLabel;
    lblDescription: TLabel;
    lblUnitEInv: TLabel;
    lblUnit: TLabel;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUom.BtnAcceptClick(Sender: TObject);
begin
  Table._Unit := edtUnit.Text;
  Table.UnitEInv := edtUnitEInv.Text;
  Table.Description := edtDescription.Text;
  Table.Decimal := chkDecimal.Checked;
  Table.MeasureType.MeasureType := edtMeasureTypeId.Text;
  Table.Multiplier := StrToIntDef(edtMultiplier.Text, 0);
  inherited;
end;

procedure TfrmSysUom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtMeasureTypeId.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysUom.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Unit of Measurement';

  edtUnit.SetFocus;
end;

procedure TfrmSysUom.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysUomTypes;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtMeasureTypeId.Name then
    begin
      LFrm := TfrmSysUomTypes.Create((Sender as TEdit), TSysUomTypeService.Create, TSysUomType.Create);
      try
        LFrm.IsHelper := True;
        LFrm.ShowModal;
        if LFrm.DataAktar then
        begin
          if LFrm.CleanAndClose then
          begin
            Table.MeasureTypeId := 0;
            (Sender as TEdit).Clear;
          end
          else
          begin
            Table.MeasureTypeId := LFrm.Table.Id;
            (Sender as TEdit).Text := LFrm.Table.MeasureType;
          end;
        end;
      finally
        LFrm.Free;
      end;
    end;
  end;
end;

procedure TfrmSysUom.InitializeInputCase;
begin
  inherited;
  edtUnit.thsInputDataType := itString;
  edtUnitEInv.thsInputDataType := itString;
  edtDescription.thsInputDataType := itString;
  edtMeasureTypeId.thsInputDataType := itInteger;
end;

procedure TfrmSysUom.RefreshData;
begin
  inherited;
  edtUnit.Text := Table._Unit;
  edtUnitEInv.Text := Table.UnitEInv;
  edtDescription.Text := Table.Description;
  chkDecimal.Checked := Table.Decimal;
  edtMeasureTypeId.Text := Table.MeasureType.MeasureType;
  edtMultiplier.Text := Table.Multiplier.ToString;
end;

end.
