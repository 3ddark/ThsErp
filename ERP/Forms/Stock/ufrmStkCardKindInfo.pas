unit ufrmStkCardKindInfo;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, ufrmInputSimpleDbX, SharedFormTypes,
  Ths.Helper.BaseTypes, Ths.Helper.Edit, Ths.Helper.Memo, Ths.Helper.ComboBox,
  StkCardKindInfoService, StkCardKindInfo;

type
  TfrmStkCardKindInfo = class(TfrmInputSimpleDbX<TStkCardKindInfo, TStkCardKindInfoService>)
    pgcMain: TPageControl;
    tsMain: TTabSheet;
    lblcard_id: TLabel;
    edtcard_id: TEdit;
    lblkind_id: TLabel;
    edtkind_id: TEdit;
    lbls1: TLabel;
    edts1: TEdit;
    lbls2: TLabel;
    edts2: TEdit;
    lbls3: TLabel;
    edts3: TEdit;
    lbls4: TLabel;
    edts4: TEdit;
    lbls5: TLabel;
    edts5: TEdit;
    lbls6: TLabel;
    edts6: TEdit;
    lbls7: TLabel;
    edts7: TEdit;
    lbls8: TLabel;
    edts8: TEdit;
    lbls9: TLabel;
    edts9: TEdit;
    lbls10: TLabel;
    edts10: TEdit;
    procedure FormCreate(Sender: TObject); override;
    procedure FormShow(Sender: TObject); override;
  published
    procedure BtnAcceptClick(Sender: TObject); override;

  public
    procedure RefreshData; override;
    procedure InitializeInputCase; override;
  end;

implementation

{$R *.dfm}

procedure TfrmStkCardKindInfo.BtnAcceptClick(Sender: TObject);
begin
  Table.StkKartID.Value := StrToInt64Def(edtcard_id.Text, 0);
  Table.CinsID.Value := StrToInt64Def(edtkind_id.Text, 0);
  Table.Deger.S1.Value := edts1.Text;
  Table.Deger.S2.Value := edts2.Text;
  Table.Deger.S3.Value := edts3.Text;
  Table.Deger.S4.Value := edts4.Text;
  Table.Deger.S5.Value := edts5.Text;
  Table.Deger.S6.Value := edts6.Text;
  Table.Deger.S7.Value := edts7.Text;
  Table.Deger.S8.Value := edts8.Text;
  Table.Deger.S9.Value := edts9.Text;
  Table.Deger.S10.Value := edts10.Text;
  inherited;
end;

procedure TfrmStkCardKindInfo.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.Parent := PanelMain;
  PgcBase := pgcMain;
end;

procedure TfrmStkCardKindInfo.FormShow(Sender: TObject);
begin
  inherited;
  Self.Caption := 'Input Stk Card Kind Info';
  edtcard_id.SetFocus;
end;

procedure TfrmStkCardKindInfo.InitializeInputCase;
begin
  inherited;
end;

procedure TfrmStkCardKindInfo.RefreshData;
begin
  inherited;
  edtcard_id.Text := IntToStr(Table.StkKartID.Value);
  edtkind_id.Text := IntToStr(Table.CinsID.Value);
  edts1.Text := Table.Deger.S1.Value;
  edts2.Text := Table.Deger.S2.Value;
  edts3.Text := Table.Deger.S3.Value;
  edts4.Text := Table.Deger.S4.Value;
  edts5.Text := Table.Deger.S5.Value;
  edts6.Text := Table.Deger.S6.Value;
  edts7.Text := Table.Deger.S7.Value;
  edts8.Text := Table.Deger.S8.Value;
  edts9.Text := Table.Deger.S9.Value;
  edts10.Text := Table.Deger.S10.Value;
end;

end.
