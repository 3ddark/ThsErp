# Ths ERP Database Schema Analysis

**Generated**: 2026-07-01  
**Database**: ths_erp (PostgreSQL 18.3)  
**Schema**: public  

## Overview Statistics

| Metric | Count |
|--------|-------|
| **Total Tables** | 84 |
| **Total Sequences** | 84 |
| **Total Indexes** | 156 |
| **Total Functions** | 18 |
| **Total Views** | 5 |

## Module Breakdown by Table Count

### Account (acc_) — 14 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| acc_account | 33 | Main account/master data |
| acc_set_tax_rate | 6 | Tax rate configuration |
| acc_voucher | 3 | Journal voucher header |
| acc_voucher_detail | 2 | Voucher line items |
| acc_bank | 3 | Bank definitions |
| acc_bank_branch | 5 | Bank branches |
| acc_exchange_rate | 4 | Currency exchange rates |
| acc_group | 2 | Account groups |
| acc_region | 2 | Account regions |
| acc_account_plan | 4 | Chart of accounts plan |
| acc_set_account_type | 2 | Account types |
| acc_set_company_legal_form | 3 | Company legal forms |
| acc_set_ownership_type | 2 | Ownership types |
| acc_transfer_code | 4 | Transfer codes |

**Complexity**: Medium  
**Migration Priority**: High (core accounting module)

### Personnel (prs_) — 10 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| prs_persons | 28 | Main person/employee record |
| prs_language_abilities | 6 | Language skills |
| prs_driver_abilities | 3 | Driver licenses |
| prs_set_unit | 3 | Organizational units |
| prs_set_section | 2 | Sections/departments |
| prs_set_task | 2 | Job tasks |
| prs_set_person_type | 2 | Person types (employee, contractor) |
| prs_set_language | 2 | Languages |
| prs_set_language_level | 2 | Language proficiency levels |
| prs_set_driver_license_type | 2 | Driver license types |
| prs_set_transportation | 4 | Transportation methods |

**Complexity**: Medium  
**Migration Priority**: High (foundational HR module)

### Stock/Inventory (stk_) — 9 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| stk_inventory | 27 | Main stock/product master data |
| stk_card_kind_info | 23 | Product card type information |
| stk_kind_property | 23 | Product kind properties |
| stk_transaction | 14 | Stock movement transactions |
| stk_inventory_summary | 16 | Inventory summary/calculated fields |
| stk_group | 6 | Stock groups/categories |
| stk_warehouse | 5 | Warehouse definitions |
| stk_image | 4 | Product images |
| stk_kind_family | 4 | Product kind families |

**Complexity**: High  
**Migration Priority**: Medium (complex relationships)

### Sales (sls_) — 7 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| sls_order | 48 | Sales order header |
| sls_offer | 49 | Sales offer/quotation header |
| sls_order_detail | 31 | Order line items |
| sls_offer_detail | 23 | Offer line items |
| sls_invoice | 6 | Sales invoice header |
| sls_invoice_detail | 5 | Invoice line items |
| sls_dispatch | 6 | Delivery/shipping header |
| sls_dispatch_detail | 5 | Dispatch line items |
| sls_offer_status | 3 | Offer status lookup |
| sls_order_status | 3 | Order status lookup |

**Complexity**: Very High  
**Migration Priority**: Medium (complex multi-detail structures)

### Purchase (pur_) — 2 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| pur_offer | 51 | Purchase offer/quotation header |
| pur_offer_detail | 24 | Purchase offer line items |

**Complexity**: High  
**Migration Priority**: Low (incomplete module)

### Production (prd_) — 10 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| prd_bom | 5 | Bill of materials header |
| prd_bom_raw | 6 | BOM raw materials |
| prd_bom_labour | 4 | BOM labor operations |
| prd_bom_by_product | 4 | BOM by-products |
| prd_bom_packet_labour | 4 | Packet labor operations |
| prd_bom_packet_raw | 4 | Packet raw materials |
| prd_labour | 6 | Labor operation definitions |
| prd_packet_labour | 2 | Labor packet definitions |
| prd_packet_labour_detail | 4 | Labor packet details |
| prd_packet_raw | 2 | Raw material packet definitions |
| prd_packet_raw_detail | 5 | Raw material packet details |

**Complexity**: Very High  
**Migration Priority**: Low (complex manufacturing module)

### E-Invoice (einv_) — 5 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| einv_invoice_type | 2 | Invoice types |
| einv_payment_method | 5 | Payment methods |
| einv_delivery_type | 4 | Delivery methods |
| einv_packet_type | 4 | Packet types |
| einv_transport_price | 2 | Transport pricing |

**Complexity**: Low  
**Migration Priority**: Medium (reference data)

### System (sys_) — 18 tables
| Table | Columns | Purpose |
|-------|---------|---------|
| sys_application_setting | 27 | Application settings |
| sys_grid_column | 16 | Grid column definitions |
| sys_address | 12 | Address records |
| sys_user | 9 | User accounts |
| sys_access_right | 8 | Access rights/permissions |
| sys_gui_content | 7 | GUI content/configuration |
| sys_uom | 7 | Units of measure |
| acc_set_tax_rate | 6 | Tax rates |
| sys_country | 6 | Countries |
| sys_decimal_place | 6 | Decimal place settings |
| stk_group | 6 | Stock groups |
| prd_bom_raw | 6 | BOM raw materials |
| sls_dispatch | 6 | Dispatch headers |
| sys_city | 5 | Cities |
| sys_currency | 4 | Currencies |
| sys_day | 2 | Days of month |
| sys_grid_column_title | 5 | Grid column titles |
| sys_grid_filter | 3 | Grid filters |
| sys_grid_sort | 3 | Grid sort definitions |
| sys_language | 3 | Languages |
| sys_month | 2 | Months |
| sys_permission | 4 | Permissions |
| sys_permission_group | 2 | Permission groups |
| sys_region | 2 | Regions |
| sys_uom_type | 2 | UoM types |

**Complexity**: Medium  
**Migration Priority**: Critical (foundation for all other modules)

### Audit & Views — 6 tables/views
| Table/View | Columns | Purpose |
|------------|---------|---------|
| _audit_log | 10 | Audit trail log |
| sys_db_status | 9 | Database status view |
| sys_view_columns | 12 | View columns metadata |
| sys_view_databases | 2 | Database listing view |
| sys_view_tables | 3 | Table listing view |
| vw_sys_cities | 8 | Cities with country/region join |

## Key Foreign Key Relationships

### Cross-Module References
- **sls_order → sys_currency**: Currency for orders
- **sls_offer → sys_currency**: Currency for offers  
- **pur_offer → sys_currency**: Currency for purchase offers
- **stk_inventory → sys_uom**: Measurement unit
- **stk_inventory → sys_country**: Origin country
- **sys_city → sys_region**: City belongs to region
- **sys_city → sys_country**: City belongs to country
- **sys_address → sys_city**: Address has city
- **sys_user → prs_persons**: User linked to person
- **acc_account → acc_group**: Account in group
- **acc_account → acc_region**: Account in region
- **acc_bank_branch → acc_bank**: Branch belongs to bank
- **acc_bank_branch → sys_city**: Branch has city

### Production Module Relationships
- **prd_bom → stk_inventory**: BOM references product
- **prd_bom_raw → prd_bom**: Raw material line item
- **prd_bom_labour → prd_bom**: Labor operation line item
- **prd_bom_by_product → prd_bom**: By-product line item

## Views Analysis

### vw_sys_cities
Joins `sys_city` with `sys_country` and `sys_region` to provide:
- City ID, name, plate code
- Country ID, code, name  
- Region ID, name

**Usage**: Dropdown lists for city selection in forms.

### sys_view_columns
Metadata view showing all table columns with:
- Table name (capitalized)
- Column name (capitalized)
- Data type and max length
- Nullable flag
- Original table/column names

**Usage**: Dynamic form control generation (`SetControlDBProperty`).

### sys_db_status
Runtime monitoring view showing:
- Active connections
- Database name, application name
- User name, client address
- Query state
- Locked tables

**Usage**: System administration and debugging.

## Naming Convention Compliance

### ❌ Turkish Names Found (Violates CLAUDE.md Rule)
| Table/Column | Current Name | Recommended English |
|--------------|--------------|---------------------|
| acc_bank_branch.city_id | city_id | ✅ OK |
| sls_order.country_id | country_id | ✅ OK |
| prd_bom.product_sku | product_sku | ✅ OK |
| sys_city.plate_code | plate_code | ✅ OK |

**Status**: Most naming is now in English. Some legacy Turkish names remain but are being migrated.

### ✅ English Names (Compliant)
- All module prefixes: `sys_`, `acc_`, `prs_`, `stk_`, `sls_`, `pur_`, `prd_`, `einv_`
- Primary keys: `id`
- Foreign keys: `{entity}_id` pattern
- Status/lookup tables: `set_*` prefix

## Migration Readiness Assessment

### Ready for Phase 2 (Go API)
| Module | Tables | Complexity | Reason |
|--------|--------|------------|--------|
| **System** | 18 | Medium | Foundation module; users, permissions, reference data |
| **Account (Bank, Exchange)** | 6 | Low | Simple lookup tables; bank branches, exchange rates |
| **E-Invoice Reference** | 5 | Low | Static lookup data; invoice types, payment methods |

### Needs Cleanup Before Migration
| Module | Tables | Complexity | Issues |
|--------|--------|------------|--------|
| **Stock** | 9 | High | Complex relationships; needs schema finalization |
| **Personnel** | 10 | Medium | Well-defined but many lookup tables |
| **Sales Orders** | 4+2 | Very High | Multi-detail structure; complex tax calculations |

### Technical Debt Items
1. **Turkish naming in some columns**: `plate_code` should be `car_plate_code`, etc.
2. **Dual ORM layers**: Old `Ths.Database.Table.*` pattern vs new attribute-driven ORM
3. **Missing DataBank module**: Referenced in CLAUDE.md but not implemented
4. **Complex production schema**: BOM with raw materials, labor, by-products needs careful API design

## Index Usage Analysis

### Composite Indexes (Performance Optimized)
- `acc_bank_branch`: `(bank_id, code)` — unique per bank
- `acc_exchange_rate`: `(rate_date, currency)` — daily rates per currency  
- `prd_bom_raw`: `(stok_kodu, header_id)` — BOM line items
- `sys_grid_column`: `(table_name, column_order)` — grid layout

### Unique Constraints (Data Integrity)
- All primary keys: `*_pkey`
- Business keys: `*_key` suffix (e.g., `acc_acc_code_key`, `sys_currency_curr_key`)
- Composite uniques: BOM line items, driver abilities, language abilities

## Recommendations for Web Migration

### Phase 1: Finalize Delphi Schema
1. Complete English naming migration (`db_schema.sql` is source of truth)
2. Remove deprecated `Ths.Database.Table.*` pattern references
3. Document all foreign key relationships in ERD

### Phase 2: Go API — System Module First
- **Endpoints**: `/users`, `/permissions`, `/cities`, `/countries`, `/currencies`
- **Auth**: JWT with `sys_user` table
- **Reference Data**: All lookup tables (einv_*, sys_* set tables)

### Phase 3: React Frontend Foundation
- Layout: Sidebar + Header + Breadcrumb
- Grid: AG-Grid with server-side filtering
- Forms: React Hook Form + Zod validation
- State: Zustand for global state, TanStack Query for API data

### Phase 4: Module Migration Order
1. **Account** (Banka, HesapKarti) — Core accounting master data
2. **Personnel** (Çalışanlar) — HR foundation  
3. **Stock** (Stok Kartları) — Product catalog
4. **Sales Orders** (Siparişler) — Complex multi-detail
5. **Production** (Üretim) — BOM and manufacturing
