unit ufrmStkStokAmbar1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInput, Ths.Orm.Table.StkAmbarlar, Ths.Orm.Table, Ths.Orm.Manager;

type
  TfrmStkStokAmbar1 = class(TfrmInput<TStkAmbar1>)
    pnlContent: TPanel;
    lblambar_adi: TLabel;
    lblis_hammadde_ambari: TLabel;
    lblis_uretim_ambari: TLabel;
    lblis_satis_ambari: TLabel;
    edtambar_adi: TEdit;
    chkis_hammadde_ambari: TCheckBox;
    chkis_uretim_ambari: TCheckBox;
    chkis_satis_ambari: TCheckBox;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent; AContext: PTEntityManager; ATable: TStkAmbar1; AFormMode: TInputFormMode; ACreateNewBase: Boolean = True); reintroduce; overload;
    procedure btnAcceptClick(Sender: TObject); override;
    procedure RefreshData; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkStokAmbar1.btnAcceptClick(Sender: TObject);
begin
  if (FormMode = ifmNewRecord) or (FormMode = ifmCopyNewRecord) or (FormMode = ifmUpdate) then
  begin
    if ValidateInput() then
    begin
      Table.AmbarAdi.Value := edtambar_adi.Text;
      Table.IsVarsayilanHammadde.Value := chkis_hammadde_ambari.Checked;
      Table.IsVarsayilanUretim.Value := chkis_uretim_ambari.Checked;
      Table.IsVarsayilanSatis.Value := chkis_satis_ambari.Checked;
      inherited;
    end;
  end
  else
    inherited;
end;

constructor TfrmStkStokAmbar1.Create(AOwner: TComponent; AContext: PTEntityManager; ATable: TStkAmbar1; AFormMode: TInputFormMode; ACreateNewBase: Boolean);
begin
  inherited Create(AOwner);
  inherited Create(AOwner, AContext, ATable, AFormMode, False);
  pnlContent.Parent := TabSheetGeneral;
end;

procedure TfrmStkStokAmbar1.RefreshData;
begin
  edtambar_adi.Text := Table.AmbarAdi.Value;
  chkis_hammadde_ambari.Checked := Table.IsVarsayilanHammadde.Value;
  chkis_uretim_ambari.Checked := Table.IsVarsayilanUretim.Value;
  chkis_satis_ambari.Checked := Table.IsVarsayilanSatis.Value;
end;

end.
