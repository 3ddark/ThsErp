unit StkImage;

interface

{$I Ths.inc}

uses
  System.SysUtils, Entity, EntityAttributes;

type
  [Table('stk_images')]
  TStkImage = class(TEntity)
  private
    FStkCardID: Int64;
    FImage: TBytes;
    FFileName: string;
  public
    [Column('stk_card_id')]
    Property StkCardID: Int64 read FStkCardID write FStkCardID;

    [Column('image', ftBlob)]
    Property Image: TBytes read FImage write FImage;

    [Column('file_name')]
    Property FileName: string read FFileName write FFileName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TStkImage.Create;
begin
  inherited;
end;

destructor TStkImage.Destroy;
begin
  inherited;
end;

end.
