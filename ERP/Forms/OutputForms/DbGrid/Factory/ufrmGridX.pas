unit ufrmGridX;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmBaseOutput, Vcl.Menus, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TfrmBaseOutput1 = class(TfrmBaseOutput)
    grd: TDBGrid;
    lblFilterHelper: TLabel;
    edtFilterHelper: TEdit;
    pb1: TProgressBar;
    pnlButtons: TPanel;
    pnlButtonRight: TPanel;
    pnlButtonLeft: TPanel;
    btnAddNew: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBaseOutput1: TfrmBaseOutput1;

implementation

{$R *.dfm}

end.
