unit ufrmSysRegion;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.ComCtrls,
  ufrmInputSimpleDB, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysRegion.Service, SysRegion, LocalizationManager;

type
  TfrmSysRegion = class(TfrmInputSimpleDB<TSysRegion, TSysRegionService>)
    pnlContent: TPanel;
    lblRegionName: TLabel;
    edtRegionName: TEdit;
    procedure BtnAcceptClick(Sender: TObject); override;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  public
    procedure RefreshData; override;
    procedure ApplyLocalization; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysRegion.BtnAcceptClick(Sender: TObject);
begin
  Table.RegionName := edtRegionName.Text;
  inherited;
end;

procedure TfrmSysRegion.FormCreate(Sender: TObject);
begin
  inherited;
  pnlContent.Parent := PanelMain;
end;

procedure TfrmSysRegion.FormShow(Sender: TObject);
begin
  inherited;
  ApplyLocalization;
  edtRegionName.SetFocus;
end;

procedure TfrmSysRegion.ApplyLocalization;
begin
  inherited;
  Self.Caption := TLocalizationManager.Translate('sys_region.title.singular', 'Bölge');
  lblRegionName.Caption := TLocalizationManager.Translate('sys_region.name', 'Bölge Adı');
end;

procedure TfrmSysRegion.RefreshData;
begin
  inherited;
  edtRegionName.Text := Table.RegionName;
end;

end.

