unit ufrmStkStokAmbar1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  ufrmInput, Ths.Orm.Table.StkAmbarlar, Ths.Orm.Table;

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
    constructor Create(AOwner: TComponent; ATable: TStkAmbar1; AFormMode: TInputFormMode; ACreateNewBase: Boolean = True); reintroduce; overload;
  end;

implementation

{$R *.dfm}

constructor TfrmStkStokAmbar1.Create(AOwner: TComponent; ATable: TStkAmbar1; AFormMode: TInputFormMode; ACreateNewBase: Boolean);
begin
  inherited Create(AOwner);
  inherited Create(AOwner, ATable, ifmNewRecord, False);
  pnlContent.Parent := TabSheetGeneral;
end;

end.
