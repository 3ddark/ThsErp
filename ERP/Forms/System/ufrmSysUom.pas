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
    edtmultiplier: TEdit;
    chkdecimal: TCheckBox;
    edtmeasure_type_id: TEdit;
    edtdescription: TEdit;
    edtunit_einv: TEdit;
    edtunit: TEdit;
    lblmultiplier: TLabel;
    lbldecimal: TLabel;
    lblmeasure_type_id: TLabel;
    lbldescription: TLabel;
    lblunit_einv: TLabel;
    lblunit: TLabel;
  public
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
    procedure HelperProcess(Sender: TObject);
    procedure InitializeInputCase; override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysUom.BtnAcceptClick(Sender: TObject);
begin
  Table._Unit := edtunit.Text;
  Table.UnitEInv := edtunit_einv.Text;
  Table.Description := edtdescription.Text;
  Table.Decimal := chkdecimal.Checked;
  Table.MeasureType.MeasureType := edtmeasure_type_id.Text;
  Table.Multiplier := StrToIntDef(edtmultiplier.Text, 0);
  inherited;
end;

procedure TfrmSysUom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtmeasure_type_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysUom.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'System Unit of Measurement';

  edtunit.SetFocus;
end;

procedure TfrmSysUom.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysUomTypes;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtmeasure_type_id.Name then
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
  edtunit.thsInputDataType := itString;
  edtunit_einv.thsInputDataType := itString;
  edtdescription.thsInputDataType := itString;
  edtmeasure_type_id.thsInputDataType := itInteger;
end;

procedure TfrmSysUom.RefreshData;
begin
  inherited;
  edtunit.Text := Table._Unit;
  edtunit_einv.Text := Table.UnitEInv;
  edtdescription.Text := Table.Description;
  chkdecimal.Checked := Table.Decimal;
  edtmeasure_type_id.Text := Table.MeasureType.MeasureType;
  edtmultiplier.Text := Table.Multiplier.ToString;
end;

end.
