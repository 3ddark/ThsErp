unit udm;

interface

uses
  System.SysUtils,
  System.Classes,
  System.ImageList,
  System.Generics.Collections,
  Vcl.ImgList,
  Vcl.Controls,
  Ths.Orm.Table,
  Ths.Orm.Table.SysOndalikHaneler,
  Ths.Orm.Table.SysParaBirimleri;

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

  GOndalikHane: TSysOndalikHane;
  GParaBirimleri: TObjectList<TSysParaBirimi>;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdm }

initialization

finalization

end.
