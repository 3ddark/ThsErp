unit udm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Generics.Collections,
  Vcl.ImgList,
  Vcl.Controls;

type
  Tdm = class(TDataModule)
    il32: TImageList;
    il16: TImageList;
    illogo: TImageList;
  private
    { Private declarations }
  public

  end;

var
  dm: Tdm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdm }

initialization

finalization

end.
