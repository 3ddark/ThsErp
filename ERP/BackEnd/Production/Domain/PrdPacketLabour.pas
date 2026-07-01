unit PrdPacketLabour;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_packet_labour')]
  TPrdPacketLabour = class(TEntity)
  private
    FPaketName: string;
  public
    [Column('package_name')]
    [Required]
    [MaxLength(128)]
    property PaketName: string read FPaketName write FPaketName;

    constructor Create(); override;
    destructor Destroy; override;
  end;

implementation

constructor TPrdPacketLabour.Create();
begin
  inherited;
end;

destructor TPrdPacketLabour.Destroy;
begin
  inherited;
end;

end.
