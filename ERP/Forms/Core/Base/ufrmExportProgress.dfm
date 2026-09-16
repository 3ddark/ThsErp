object frmExportProgress: TfrmExportProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Excel''e Aktarılıyor...'
  ClientHeight = 130
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object PnlBackground: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 130
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object LblStatus: TLabel
      Left = 16
      Top = 16
      Width = 388
      Height = 15
      AutoSize = False
      Caption = 'İşlem hazırlanıyor...'
    end
    object ProgressBar: TProgressBar
      Left = 16
      Top = 42
      Width = 388
      Height = 22
      TabOrder = 0
    end
    object BtnCancel: TButton
      Left = 329
      Top = 82
      Width = 75
      Height = 28
      Caption = 'İptal'
      TabOrder = 1
      OnClick = BtnCancelClick
    end
  end
end
