unit ufrmExportProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfrmExportProgress = class(TForm)
    PnlBackground: TPanel;
    LblStatus: TLabel;
    ProgressBar: TProgressBar;
    BtnCancel: TButton;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FOnCancel: TProc;
  public
    procedure UpdateProgress(ACurrent, ATotal: Integer; const AStatus: string);
    property OnCancel: TProc read FOnCancel write FOnCancel;
  end;

implementation

{$R *.dfm}

procedure TfrmExportProgress.BtnCancelClick(Sender: TObject);
begin
  BtnCancel.Enabled := False;
  LblStatus.Caption := 'İptal ediliyor...';
  if Assigned(FOnCancel) then
    FOnCancel();
end;

procedure TfrmExportProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmExportProgress.UpdateProgress(ACurrent, ATotal: Integer; const AStatus: string);
begin
  if AStatus <> '' then
    LblStatus.Caption := AStatus;

  if ATotal > 0 then
  begin
    ProgressBar.Style := pbstNormal;
    ProgressBar.Max := ATotal;
    ProgressBar.Position := ACurrent;
  end
  else
  begin
    ProgressBar.Style := pbstMarquee;
  end;
  Application.ProcessMessages;
end;

end.
