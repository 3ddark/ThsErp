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
    lblcity_name: TLabel;
    lblcar_plate_code: TLabel;
    lblcountry_id: TLabel;
    lblregion_id: TLabel;
    edtcity_name: TEdit;
    edtcar_plate_code: TEdit;
    edtcountry_id: TEdit;
    edtregion_id: TEdit;
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
  Table._Unit := edtcity_name.Text;
  Table.UnitEInv := edtcar_plate_code.Text;
  inherited;
end;

procedure TfrmSysUom.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
  edtcountry_id.OnHelperProcess := HelperProcess;
  edtregion_id.OnHelperProcess := HelperProcess;
end;

procedure TfrmSysUom.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'Sistem Ölçü Birimleri';

  edtcity_name.SetFocus;
end;

procedure TfrmSysUom.HelperProcess(Sender: TObject);
var
  LFrm: TfrmSysUomTypes;
begin
  if Sender is TEdit then
  begin
    if (Sender as TEdit).Name = edtcountry_id.Name then
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
  edtcity_name.thsInputDataType := itString;
  edtcar_plate_code.thsInputDataType := itInteger;
  edtcountry_id.thsInputDataType := itInteger;
  edtregion_id.thsInputDataType := itInteger;

  edtcity_name.MaxLength := 32;
end;

procedure TfrmSysUom.RefreshData;
begin
  inherited;
  edtcity_name.Text := Table._Unit;
  edtcar_plate_code.Text := Table.UnitEInv;
end;

end.
