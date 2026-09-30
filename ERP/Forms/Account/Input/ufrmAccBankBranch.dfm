object frmAccBankBranch: TfrmAccBankBranch
  Left = 0
  Top = 0
  Caption = 'Bank Branch'
  ClientHeight = 162
  ClientWidth = 480
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
    Width = 480
    Height = 162
    Align = alClient
    TabOrder = 0
    object lblAccBankId: TLabel
      Left = 4
      Top = 6
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Bank'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtAccBankId: TEdit
      Left = 132
      Top = 2
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 0
    end
    object lblBranchCode: TLabel
      Left = 4
      Top = 29
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Branch Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBranchCode: TEdit
      Left = 132
      Top = 25
      Width = 333
      Height = 22
      TabOrder = 1
    end
    object lblBranchName: TLabel
      Left = 4
      Top = 52
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Branch Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtBranchName: TEdit
      Left = 132
      Top = 48
      Width = 333
      Height = 22
      MaxLength = 128
      TabOrder = 2
    end
    object lblSysCityId: TLabel
      Left = 4
      Top = 75
      Width = 124
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'City'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object edtSysCityId: TEdit
      Left = 132
      Top = 71
      Width = 333
      Height = 22
      ReadOnly = True
      TabOrder = 3
    end
  end
end
