inherited frmSysOlcuBirimiTipi: TfrmSysOlcuBirimiTipi
  PixelsPerInch = 96
  TextHeight = 13
  Caption = 'Sys Ölçü Birimi Tipi'
  ActiveControl = btnClose
  ClientHeight = 95
  ClientWidth = 335
  inherited pnlMain: TPanel
    inherited pgcMain: TPageControl
      inherited tsMain: TTabSheet
        object lblolcu_birimi_tipi: TLabel
          Left = 32
          Top = 6
          Width = 83
          Height = 13
          Alignment = taRightJustify
          Caption = 'Ölçü Birimi Tipi'
          Font.Style = [fsBold]
        end
        object edtolcu_birimi_tipi: TEdit
          Height = 21
          Left = 119
          Width = 200
          TabOrder = 0
          Top = 3
        end
      end
    end
  end
end
