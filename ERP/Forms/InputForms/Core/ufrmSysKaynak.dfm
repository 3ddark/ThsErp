inherited frmSysResource: TfrmSysResource
  Left = 501
  Top = 443
  Caption = 'System Resource'
  ClientHeight = 147
  ClientWidth = 349
  ParentFont = True
  ExplicitWidth = 365
  ExplicitHeight = 186
  TextHeight = 15
  inherited pnlMain: TPanel
    Width = 349
    Height = 97
    Color = clWindow
    ParentColor = False
    ExplicitWidth = 359
    ExplicitHeight = 117
    inherited pgcMain: TPageControl
      Width = 351
      Height = 101
      ExplicitWidth = 351
      ExplicitHeight = 101
      inherited tsMain: TTabSheet
        ExplicitTop = 26
        ExplicitWidth = 343
        ExplicitHeight = 71
        object lblresource_group_id: TLabel
          Left = 18
          Top = 5
          Width = 90
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Resource Group'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblresource_code: TLabel
          Left = 24
          Top = 27
          Width = 84
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Resource Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object lblresource_name: TLabel
          Left = 20
          Top = 49
          Width = 88
          Height = 13
          Alignment = taRightJustify
          BiDiMode = bdLeftToRight
          Caption = 'Resource Name'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentBiDiMode = False
          ParentFont = False
        end
        object edtresource_group_id: TEdit
          Left = 114
          Top = 2
          Width = 223
          Height = 23
          TabOrder = 0
        end
        object edtresource_code: TEdit
          Left = 114
          Top = 24
          Width = 223
          Height = 23
          TabOrder = 1
        end
        object edtresource_name: TEdit
          Left = 114
          Top = 46
          Width = 223
          Height = 23
          TabOrder = 2
        end
      end
    end
  end
  inherited pnlBottom: TPanel
    Top = 99
    Width = 345
    ExplicitTop = 119
    ExplicitWidth = 355
    inherited btnAccept: TButton
      Left = 149
      ExplicitLeft = 149
    end
    inherited btnClose: TButton
      Left = 253
      ExplicitLeft = 253
    end
  end
  inherited stbBase: TStatusBar
    Top = 129
    Width = 349
    ExplicitTop = 149
    ExplicitWidth = 359
  end
end
