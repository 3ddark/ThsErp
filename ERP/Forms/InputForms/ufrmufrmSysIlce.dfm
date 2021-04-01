inherited frmufrmSysIlce: TfrmufrmSysIlce
  PixelsPerInch = 96
  TextHeight = 13
  Caption = 'SysIlce'
  ActiveControl = btnClose
  ClientHeight = 120
  ClientWidth = 306
  inherited pnlMain: TPanel
    inherited pgcMain: TPageControl
      inherited tsMain: TTabSheet
      object lblilce_adi: TLabel
        Left = 35
        Top = 6
        Width = 51
        Height = 13
        Alignment = taRightJustify
        Caption = 'Ýlçe Adý'
        Font.Style = [fsBold]
      end
      object lblsehir_id: TLabel
        Left = 32
        Top = 28
        Width = 54
        Height = 13
        Alignment = taRightJustify
        Caption = 'Þehir ID'
        Font.Style = [fsBold]
      end
      object edtilce_adi: TEdit
        Height = 21
        Left = 90
        Width = 200
        TabOrder = 0
        Top = 3
      end
      object edtsehir_id: TEdit
        Height = 21
        Left = 90
        Width = 200
        TabOrder = 1
        Top = 25
      end
    end
  end
end
