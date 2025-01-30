object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Drive Info'
  ClientHeight = 197
  ClientWidth = 776
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object RunButton: TButton
    Left = 694
    Top = 159
    Width = 75
    Height = 25
    Caption = 'Run'
    TabOrder = 0
    OnClick = RunButtonClick
  end
  object DriveListView: TListView
    Left = 8
    Top = 8
    Width = 761
    Height = 145
    Columns = <
      item
        Caption = 'Name'
      end
      item
        Caption = 'Device'
        Width = 200
      end
      item
        Caption = 'Drive'
        Width = 150
      end
      item
        Caption = 'Partition'
        Width = 150
      end
      item
        Caption = 'Serial Number'
        Width = 200
      end>
    GridLines = True
    TabOrder = 1
    ViewStyle = vsReport
  end
end
