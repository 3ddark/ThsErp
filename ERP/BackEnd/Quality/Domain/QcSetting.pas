unit QcSetting;

interface

{$I Ths.inc}

uses
  System.SysUtils, System.Generics.Collections, Entity, EntityAttributes, LocalizationManager;

type
  // Giriş kalite kontrol ayarı (firma başına tek satır): modül açık / kapalı, uygunsuz ürün (red) ambarı
  [Table('qc_setting')]
  TQcSetting = class(TEntity)
  private
    FSysApplicationSettingId: Int64;
    FIsEnabled: Boolean;
    FRejectStkWarehouseId: Int64;
    FDescription: string;

    // View (vw_qc_setting) okunabilir alanları
    FCompanyTitle: string;
    FRejectWarehouseName: string;
  public
    [Column('sys_application_setting_id')]
    property SysApplicationSettingId: Int64 read FSysApplicationSettingId write FSysApplicationSettingId;

    [Column('is_enabled')]
    property IsEnabled: Boolean read FIsEnabled write FIsEnabled;

    [Column('reject_stk_warehouse_id')]
    property RejectStkWarehouseId: Int64 read FRejectStkWarehouseId write FRejectStkWarehouseId;

    [Column('description')]
    [MaxLength(256)]
    property Description: string read FDescription write FDescription;

    [NotMapped]
    property CompanyTitle: string read FCompanyTitle write FCompanyTitle;

    [NotMapped]
    property RejectWarehouseName: string read FRejectWarehouseName write FRejectWarehouseName;

    constructor Create(); override;
    destructor Destroy; override;

    function Clone: TQcSetting;
  end;

implementation

constructor TQcSetting.Create;
begin
  inherited;
end;

destructor TQcSetting.Destroy;
begin
  inherited;
end;

function TQcSetting.Clone: TQcSetting;
begin
  Result := TQcSetting.Create;
  Result.Id := Self.Id;
  Result.SysApplicationSettingId := Self.SysApplicationSettingId;
  Result.IsEnabled := Self.IsEnabled;
  Result.RejectStkWarehouseId := Self.RejectStkWarehouseId;
  Result.Description := Self.Description;
  Result.CompanyTitle := Self.CompanyTitle;
  Result.RejectWarehouseName := Self.RejectWarehouseName;
end;

end.
