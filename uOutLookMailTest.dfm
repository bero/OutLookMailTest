object OutLookAzureTest: TOutLookAzureTest
  Left = 0
  Top = 0
  Caption = 'Test email with OutLook Azure'
  ClientHeight = 272
  ClientWidth = 852
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lblFrom: TLabel
    Left = 8
    Top = 16
    Width = 28
    Height = 15
    Caption = 'From'
  end
  object lblTo: TLabel
    Left = 8
    Top = 48
    Width = 12
    Height = 15
    Caption = 'To'
  end
  object Authenticate: TButton
    Left = 8
    Top = 84
    Width = 121
    Height = 25
    Caption = 'Authenticate'
    TabOrder = 0
    OnClick = AuthenticateClick
  end
  object btnSendEmail: TButton
    Left = 136
    Top = 84
    Width = 121
    Height = 25
    Caption = 'Send'
    TabOrder = 1
    OnClick = btnSendEmailClick
  end
  object MemoLog: TMemo
    Left = 288
    Top = 0
    Width = 564
    Height = 272
    Align = alRight
    Lines.Strings = (
      '')
    TabOrder = 2
  end
  object OutlookMail1: TTMSFNCCloudMicrosoftOutlookMail
    Left = 167
    Top = 224
    Width = 26
    Height = 26
    Visible = True
    Logging = True
    Authentication.CallBackURL = 'http://localhost:8000'
    OnAuthenticated = OutlookMail1Authenticated
    OnRequestComplete = OutlookMail1RequestComplete
    Mails = <>
    Folders = <>
  end
  object ATSend: TButton
    Left = 8
    Top = 239
    Width = 108
    Height = 25
    Caption = 'Attracs Send'
    TabOrder = 5
    OnClick = ATSendClick
  end
  object txtFrom: TEdit
    Left = 42
    Top = 13
    Width = 231
    Height = 23
    TabOrder = 6
  end
  object txtTo: TEdit
    Left = 42
    Top = 42
    Width = 231
    Height = 23
    TabOrder = 7
  end
end
