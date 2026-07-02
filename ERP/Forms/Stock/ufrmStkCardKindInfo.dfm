object frmStkCardKindInfo: TfrmStkCardKindInfo
  Left = 0
  Top = 0
  Caption = 'frmStkCardKindInfo'
  ClientHeight = 420
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 560
    Height = 420
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    TabStop = False
    ExplicitWidth = 556
    ExplicitHeight = 410
    object tsMain
      Caption = 'Genel'
      object lblcard_id
        Left = 32
        Top = 8
        Width = 59
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Card Id'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtcard_id
        Left = 97
        Top = 4
        Width = 200
        Height = 23
        TabOrder = 0
      end
      object lblkind_id
        Left = 31
        Top = 38
        Width = 60
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'Kind Id'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edtkind_id
        Left = 97
        Top = 34
        Width = 200
        Height = 23
        TabOrder = 1
      end
      object lbls1
        Left = 60
        Top = 73
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts1
        Left = 97
        Top = 69
        Width = 200
        Height = 23
        TabOrder = 2
      end
      object lbls2
        Left = 60
        Top = 103
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts2
        Left = 97
        Top = 99
        Width = 200
        Height = 23
        TabOrder = 3
      end
      object lbls3
        Left = 60
        Top = 133
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S3'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts3
        Left = 97
        Top = 129
        Width = 200
        Height = 23
        TabOrder = 4
      end
      object lbls4
        Left = 60
        Top = 163
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S4'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts4
        Left = 97
        Top = 159
        Width = 200
        Height = 23
        TabOrder = 5
      end
      object lbls5
        Left = 60
        Top = 193
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S5'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts5
        Left = 97
        Top = 189
        Width = 200
        Height = 23
        TabOrder = 6
      end
      object lbls6
        Left = 320
        Top = 73
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S6'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts6
        Left = 357
        Top = 69
        Width = 200
        Height = 23
        TabOrder = 7
      end
      object lbls7
        Left = 320
        Top = 103
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S7'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts7
        Left = 357
        Top = 99
        Width = 200
        Height = 23
        TabOrder = 8
      end
      object lbls8
        Left = 320
        Top = 133
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S8'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts8
        Left = 357
        Top = 129
        Width = 200
        Height = 23
        TabOrder = 9
      end
      object lbls9
        Left = 320
        Top = 163
        Width = 5
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S9'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts9
        Left = 357
        Top = 159
        Width = 200
        Height = 23
        TabOrder = 10
      end
      object lbls10
        Left = 318
        Top = 193
        Width = 7
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = 'S10'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentBiDiMode = False
        ParentFont = False
      end
      object edts10
        Left = 357
        Top = 189
        Width = 200
        Height = 23
        TabOrder = 11
      end
    end
  end
end
