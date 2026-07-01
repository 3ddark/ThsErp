unit PrdPacketRaw;

interface

uses
  SysUtils, Classes, Types, Entity, EntityAttributes;

type
  [Table('prd_packet_raw')]
  TPrdPacketRaw = class(TEntity)
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

constructor TPrdPacketRaw.Create();
begin
  inherited;
end;

destructor TPrdPacketRaw.Destroy;
begin
  inherited;
end;

end.
