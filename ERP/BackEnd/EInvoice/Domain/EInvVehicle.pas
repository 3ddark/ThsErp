unit EInvVehicle;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  [Table('einv_vehicle')]
  TEInvVehicle = class(TEntity)
  private
    FPlateNo: string;
    FIsTrailer: Boolean;
    FDescription: string;
    FIsActive: Boolean;
  public
    [Column('plate_no')]
    [MaxLength(16), Required(TLangKeys.TValidation.Required, True)]
    property PlateNo: string read FPlateNo write FPlateNo;

    [Column('is_trailer')]
    property IsTrailer: Boolean read FIsTrailer write FIsTrailer;

    [Column('description')]
    [MaxLength(128)]
    property Description: string read FDescription write FDescription;

    [Column('is_active')]
    property IsActive: Boolean read FIsActive write FIsActive;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TEInvVehicle;
  end;

implementation

constructor TEInvVehicle.Create;
begin
  inherited;
  FIsActive := True;
end;

destructor TEInvVehicle.Destroy;
begin
  inherited;
end;

function TEInvVehicle.Clone: TEInvVehicle;
begin
  Result := TEInvVehicle.Create;
  Result.Id := Self.Id;
  Result.PlateNo := Self.PlateNo;
  Result.IsTrailer := Self.IsTrailer;
  Result.Description := Self.Description;
  Result.IsActive := Self.IsActive;
end;

end.
