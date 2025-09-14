unit ufrmSysRegion;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  SysRegion.Service, SysRegion, Vcl.ExtCtrls;

type
  TfrmSysRegion = class(TfrmInputSimpleDbX<TSysRegion, TSysRegionService>)
    pnlMain: TPanel;
    lblregion_name: TLabel;
    edtregion_name: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  published
    procedure BtnAcceptClick(Sender: TObject); override;
  public
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmSysRegion.BtnAcceptClick(Sender: TObject);
begin
  Table.RegionName.Value := edtregion_name.Text;
  inherited;
end;

procedure TfrmSysRegion.FormCreate(Sender: TObject);
begin
  inherited;

  pnlMain.Parent := PanelMain;
  PanelMain := pnlMain;

  edtregion_name.CharCase := TEditCharCase.ecUpperCase;
end;

procedure TfrmSysRegion.FormShow(Sender: TObject);
begin
  inherited;

  Self.Caption := 'Stk Cins Aile Input';

  edtregion_name.SetFocus;
end;

procedure TfrmSysRegion.RefreshData;
begin
  inherited;
  edtregion_name.Text := Table.RegionName.Value;
end;

end.

