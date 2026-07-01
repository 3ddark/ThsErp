unit SysGuiContent;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_gui_content')]
  TSysGridContents = class(TEntity)
  private
    FCode: string;
    FIsFactory: Boolean;
    FTableName: string;
    FFormName: string;
    FContentType: string;
    FContent: string;
  public
    [Column('code'), MaxLength(64), Required()]
    property Code: string read FCode write FCode;

    [Column('content')]
    property Content: string read FContent write FContent;

    [Column('is_factory'), Required()]
    property IsFactory: Boolean read FIsFactory write FIsFactory;

    [Column('content_type'), MaxLength(32), Required()]
    property ContentType: string read FContentType write FContentType;

    [Column('table_name'), MaxLength(64)]
    property TableName: string read FTableName write FTableName;

    [Column('form_name'), MaxLength(64)]
    property FormName: string read FFormName write FFormName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridContents.Create();
begin
  inherited;
  FIsFactory := False;
end;

destructor TSysGridContents.Destroy;
begin
  inherited;
end;

end.
