object frmSlsDispatchDetail: TfrmSlsDispatchDetail
  Left = 0
  Top = 0
  Caption = 'Sevk '#304'rsaliyesi'
  ClientHeight = 628
  ClientWidth = 811
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 14
  object pnlContent: TPanel
    Left = 0
    Top = 0
    Width = 811
    Height = 152
    Align = alTop
    TabOrder = 0
    object pgcHeader: TPageControl
      Left = 1
      Top = 1
      Width = 809
      Height = 150
      ActivePage = tsGeneral
      Align = alClient
      TabOrder = 0
      object tsGeneral: TTabSheet
        Caption = 'Genel'
        object lblDispatchNo: TLabel
          Left = 4
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #304'rsaliye No'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDispatchNo: TEdit
          Left = 132
          Top = 2
          Width = 260
          Height = 22
          TabOrder = 0
        end
        object lblDispatchDate: TLabel
          Left = 4
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #304'rsaliye Tarihi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDispatchDate: TEdit
          Left = 132
          Top = 25
          Width = 260
          Height = 22
          TabOrder = 1
        end
        object lblAccAccountId: TLabel
          Left = 4
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'M'#252#351'teri'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtAccAccountId: TEdit
          Left = 132
          Top = 48
          Width = 260
          Height = 22
          TabOrder = 2
        end
        object lblStkWarehouseId: TLabel
          Left = 4
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Ambar'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtStkWarehouseId: TEdit
          Left = 132
          Top = 71
          Width = 260
          Height = 22
          TabOrder = 3
        end
        object lblCurrency: TLabel
          Left = 4
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Para Birimi'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtCurrency: TEdit
          Left = 132
          Top = 94
          Width = 260
          Height = 22
          TabOrder = 4
        end
        object lblSlsOrderId: TLabel
          Left = 408
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Sipari'#351
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtSlsOrderId: TEdit
          Left = 536
          Top = 2
          Width = 260
          Height = 22
          TabOrder = 5
        end
        object lblStatusText: TLabel
          Left = 408
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Durum'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtStatusText: TEdit
          Left = 536
          Top = 25
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 6
        end
        object lblDescription: TLabel
          Left = 408
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'A'#231#305'klama'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDescription: TEdit
          Left = 536
          Top = 48
          Width = 260
          Height = 22
          TabOrder = 7
        end
        object pnlTotals: TPanel
          Left = 408
          Top = 71
          Width = 395
          Height = 32
          BevelOuter = bvLowered
          TabOrder = 8
        end
      end
      object tsEDespatch: TTabSheet
        Caption = 'e-'#304'rsaliye / Ta'#351#305'ma'
        ImageIndex = 1
        object lblEinvProfileId: TLabel
          Left = 4
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Senaryo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvProfileId: TEdit
          Left = 132
          Top = 2
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 0
        end
        object lblEinvUuid: TLabel
          Left = 4
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'ETTN'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvUuid: TEdit
          Left = 132
          Top = 25
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 1
        end
        object lblEinvStatusText: TLabel
          Left = 4
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'e-Belge Durumu'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvStatusText: TEdit
          Left = 132
          Top = 48
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 2
        end
        object lblDespatchTime: TLabel
          Left = 4
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fiili Sevk Saati'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDespatchTime: TEdit
          Left = 132
          Top = 71
          Width = 260
          Height = 22
          TabOrder = 3
        end
        object lblCarrierAccAccountId: TLabel
          Left = 4
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Ta'#351#305'y'#305'c'#305' Firma'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtCarrierAccAccountId: TEdit
          Left = 132
          Top = 94
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 4
        end
        object lblEinvVehicleId: TLabel
          Left = 408
          Top = 6
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Ara'#231' Plakas'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtEinvVehicleId: TEdit
          Left = 536
          Top = 2
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 5
        end
        object lblTrailer1EinvVehicleId: TLabel
          Left = 408
          Top = 29
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Dorse 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtTrailer1EinvVehicleId: TEdit
          Left = 536
          Top = 25
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 6
        end
        object lblTrailer2EinvVehicleId: TLabel
          Left = 408
          Top = 52
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Dorse 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtTrailer2EinvVehicleId: TEdit
          Left = 536
          Top = 48
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 7
        end
        object lblDriver1EinvDriverId: TLabel
          Left = 408
          Top = 75
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #350'of'#246'r 1'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDriver1EinvDriverId: TEdit
          Left = 536
          Top = 71
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 8
        end
        object lblDriver2EinvDriverId: TLabel
          Left = 408
          Top = 98
          Width = 124
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = #350'of'#246'r 2'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object edtDriver2EinvDriverId: TEdit
          Left = 536
          Top = 94
          Width = 260
          Height = 22
          ReadOnly = True
          TabOrder = 9
        end
      end
    end
  end
end
