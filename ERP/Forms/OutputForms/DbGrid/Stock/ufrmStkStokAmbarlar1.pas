unit ufrmStkStokAmbarlar1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufrmGrid,
  Ths.Orm.Table.StkAmbarlar, Ths.Orm.Table, Ths.Orm.Manager, Ths.Orm.ManagerStack;

type
  TfrmStkStokAmbarlar1 = class(TfrmGrid<TStkAmbar1>)
  published
    function CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm; override;
  public

  end;

implementation

{$R *.dfm}

uses ufrmStkStokAmbar1;

function TfrmStkStokAmbarlar1.CreateInputForm(Sender: TObject; AFormMode: TInputFormMode): TForm;
begin
  Result := inherited;
  if AFormMode = ifmRewiev then
    Result := TfrmStkStokAmbar1.Create(Self, AppDbContext.Clone<TStkAmbar1>(Table), AFormMode)
  else if AFormMode = ifmNewRecord then
    Result := TfrmStkStokAmbar1.Create(Self, TStkAmbar1.Create, AFormMode)
  else if AFormMode = ifmCopyNewRecord then
    Result := TfrmStkStokAmbar1.Create(Self, AppDbContext.Clone<TStkAmbar1>(Table), AFormMode);
end;

end.
