unit SysGuiContent;

interface

uses SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('sys_gui_contents')]
  TSysGridContents = class(TEntity)
  private
    FCode: string;
    FIsFactory: Boolean;
    FTableName: string;
    FFormName: string;
    FContentType: string;
    FContent: string;
  public
    [Column('code')]
    property Code: string read FCode write FCode;

    [Column('content')]
    property Content: string read FContent write FContent;

    [Column('is_factory')]
    property IsFactory: Boolean read FIsFactory write FIsFactory;

    [Column('content_type')]
    property ContentType: string read FContentType write FContentType;

    [Column('table_name')]
    property TableName: string read FTableName write FTableName;

    [Column('form_name')]
    property FormName: string read FFormName write FFormName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TSysGridContents.Create();
begin
  inherited;
end;

destructor TSysGridContents.Destroy;
begin
  inherited;
end;

end.
