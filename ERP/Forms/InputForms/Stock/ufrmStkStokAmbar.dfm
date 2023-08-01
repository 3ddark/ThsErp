inherited frmStkStokAmbar: TfrmStkStokAmbar
  Left = 501
  Top = 443
  ActiveControl = btnClose
  Caption = 'Ambar'
  ClientHeight = 187
  ClientWidth = 410
  Font.Name = 'MS Sans Serif'
  ExplicitWidth = 426
  ExplicitHeight = 226
  TextHeight = 13
  inherited pnlMain: TPanel
    Width = 410
    Height = 137
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 408
    ExplicitHeight = 139
    inherited pgcMain: TPageControl
      Width = 412
      Height = 141
      ExplicitWidth = 406
      ExplicitHeight = 137
      inherited tsMain: TTabSheet
        ExplicitWidth = 404
        ExplicitHeight = 113
        object lblambar_adi: TLabel
          Left = 134
          Top = 6
          Width = 58
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Ambar Ad'#305
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_hammadde_ambari: TLabel
          Left = 18
          Top = 28
          Width = 174
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Varsay'#305'lan Hammadde Ambar'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_uretim_ambari: TLabel
          Left = 44
          Top = 50
          Width = 148
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Varsay'#305'lan '#220'retim Ambar'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblis_satis_ambari: TLabel
          Left = 52
          Top = 72
          Width = 140
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Varsay'#305'lan Sat'#305#351' Ambar'#305'?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtambar_adi: TEdit
          Left = 196
          Top = 3
          Width = 200
          Height = 21
          TabOrder = 0
        end
        object chkis_hammadde_ambari: TCheckBox
          Left = 196
          Top = 26
          Width = 200
          Height = 17
          TabOrder = 1
        end
        object chkis_uretim_ambari: TCheckBox
          Left = 196
          Top = 49
          Width = 200
          Height = 17
          TabOrder = 2
        end
        object chkis_satis_ambari: TCheckBox
          Left = 196
          Top = 72
          Width = 200
          Height = 17
          TabOrder = 3
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 139
    Width = 406
    ExplicitTop = 143
    ExplicitWidth = 408
    inherited btnAccept: TButton
      Left = 199
      ExplicitLeft = 199
    end
    inherited btnClose: TButton
      Left = 303
      ExplicitLeft = 303
    end
  end
  inherited stbBase: TStatusBar
    Top = 169
    Width = 410
    ExplicitTop = 173
    ExplicitWidth = 412
  end
end
