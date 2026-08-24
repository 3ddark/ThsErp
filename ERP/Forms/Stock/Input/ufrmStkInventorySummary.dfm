object frmStkInventorySummary: TfrmStkInventorySummary
  Left = 0
  Top = 0
  Caption = 'frmStkInventorySummary'
  ClientHeight = 520
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 480
    Height = 520
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 476
    ExplicitHeight = 510
    object tsMain
      Caption = 'Genel'
      object lblinventory_id
        Left = 28
        Top = 8
        Width = 73
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Inventory Id'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtinventory_id
        Left = 107
        Top = 4
        Width = 350
        Height = 23
        TabOrder = 0
      end
      object lblcurrent_quantity
        Left = 19
        Top = 38
        Width = 82
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Current Qty'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtcurrent_quantity
        Left = 107
        Top = 34
        Width = 150
        Height = 23
        TabOrder = 1
      end
      object lblaverage_cost
        Left = 36
        Top = 68
        Width = 65
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Avg Cost'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtaverage_cost
        Left = 107
        Top = 64
        Width = 150
        Height = 23
        TabOrder = 2
      end
      object lblopening_price
        Left = 30
        Top = 98
        Width = 71
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Opening Price'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtopening_price
        Left = 107
        Top = 94
        Width = 150
        Height = 23
        TabOrder = 3
      end
      object lblopening_quantity
        Left = 28
        Top = 128
        Width = 73
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Opening Qty'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtopening_quantity
        Left = 107
        Top = 124
        Width = 150
        Height = 23
        TabOrder = 4
      end
      object lblopening_amount
        Left = 28
        Top = 158
        Width = 73
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Opening Amt'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtopening_amount
        Left = 107
        Top = 154
        Width = 150
        Height = 23
        TabOrder = 5
      end
      object lblincoming_quantity
        Left = 298
        Top = 8
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Incoming Qty'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtincoming_quantity
        Left = 372
        Top = 4
        Width = 90
        Height = 23
        TabOrder = 6
      end
      object lblincoming_amount
        Left = 298
        Top = 38
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Incoming Amt'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtincoming_amount
        Left = 372
        Top = 34
        Width = 90
        Height = 23
        TabOrder = 7
      end
      object lbloutgoing_quantity
        Left = 298
        Top = 68
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Outgoing Qty'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtoutgoing_quantity
        Left = 372
        Top = 64
        Width = 90
        Height = 23
        TabOrder = 8
      end
      object lbloutgoing_amount
        Left = 298
        Top = 98
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Outgoing Amt'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtoutgoing_amount
        Left = 372
        Top = 94
        Width = 90
        Height = 23
        TabOrder = 9
      end
      object lbllast_buy_price
        Left = 298
        Top = 128
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Last Buy Price'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtlast_buy_price
        Left = 372
        Top = 124
        Width = 90
        Height = 23
        TabOrder = 10
      end
      object lbllast_buy_money
        Left = 298
        Top = 158
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Last Buy Money'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtlast_buy_money
        Left = 372
        Top = 154
        Width = 90
        Height = 23
        TabOrder = 11
      end
      object lbllast_buy_date
        Left = 298
        Top = 188
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Last Buy Date'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtlast_buy_date
        Left = 372
        Top = 184
        Width = 90
        Height = 23
        DateMode = dkDateTime
        TabOrder = 12
      end
      object lbllast_buy_quantity
        Left = 298
        Top = 218
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Last Buy Qty'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtlast_buy_quantity
        Left = 372
        Top = 214
        Width = 90
        Height = 23
        TabOrder = 13
      end
      object lbllast_buy_exchange_rate
        Left = 298
        Top = 248
        Width = 69
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Last Buy ExR'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtlast_buy_exchange_rate
        Left = 372
        Top = 244
        Width = 90
        Height = 23
        TabOrder = 14
      end
    end
  end
end
