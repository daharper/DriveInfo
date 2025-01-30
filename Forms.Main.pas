unit Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ActiveX, ComObj, System.StrUtils, Vcl.ComCtrls;

type
  TDriveInfo = record
    Name: string;
    Device: string;
    Drive: string;
    Partition: string;
    Serial: string;

    constructor Create(aName, aDevice, aDrive, aPartition, aSerial: string);
  end;

  TMainForm = class(TForm)
    RunButton: TButton;
    DriveListView: TListView;
    procedure RunButtonClick(Sender: TObject);
  private
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.Generics.Collections;

{ TDriveInfo }

constructor TDriveInfo.Create(aName, aDevice, aDrive, aPartition, aSerial: string);
begin
  Name      := aName;
  Device    := aDevice;
  Drive     := aDrive;
  Partition := aPartition;
  Serial    := aSerial;
end;

{ GetDriveInfo }

function GetDriveInfo: TList<TDriveInfo>;
var
  WmiServices: OLEVariant;

  Drives: OLEVariant;
  DrivesEnum: IEnumVariant;
  Drive: OLEVariant;

  Partitions: OLEVariant;
  PartitionsEnum: IEnumVariant;
  Partition: OLEVariant;
  PartitionQuery: string;

  Disks: OLEVariant;
  DisksEnum: IEnumVariant;
  Disk: OLEVariant;
  DiskQuery: string;

  DriveValue: LongWord;
  ParitionValue: LongWord;
  DiskValue: LongWord;

  DeviceId: string;
begin
  Result := TList<TDriveInfo>.Create;

  CoInitialize(nil);
  try
    WmiServices := CreateOleObject('WbemScripting.SWbemLocator');

    var WmiServicesConnect := WmiServices.ConnectServer('localhost', 'root\CIMV2');

    Drives := WmiServicesConnect.ExecQuery('SELECT * FROM Win32_DiskDrive');
    DrivesEnum := IUnknown(Drives._NewEnum) as IEnumVariant;

    while DrivesEnum.Next(1, Drive, DriveValue) = 0 do begin
      DeviceId := Format('%s', [Drive.DeviceId]).Replace('\', '\\');
      PartitionQuery := Format('ASSOCIATORS OF {Win32_DiskDrive.DeviceID="%s"} WHERE AssocClass = Win32_DiskDriveToDiskPartition', [DeviceId]);
      Partitions := WmiServicesConnect.ExecQuery(PartitionQuery);
      PartitionsEnum := IUnknown(Partitions._NewEnum) as IEnumVariant;

      while PartitionsEnum.Next(1, Partition, ParitionValue) = 0 do begin
        DiskQuery := Format('ASSOCIATORS OF {Win32_DiskPartition.DeviceID="%s"} WHERE AssocClass = Win32_LogicalDiskToPartition', [Partition.DeviceID]);
        Disks := WmiServicesConnect.ExecQuery(DiskQuery);
        DisksEnum := IUnknown(Disks._NewEnum) as IEnumVariant;

        while DisksEnum.Next(1, Disk, DiskValue) = 0 do begin
          Result.Add(TDriveInfo.Create(disk.DeviceId, drive.Caption, drive.DeviceId, partition.DeviceId, drive.SerialNumber));
          Disk := Unassigned;
        end;
        Partition := Unassigned;
      end;
      Drive := Unassigned;
    end;
  finally
    CoUninitialize;
  end;
end;

{ TMainForm }

procedure TMainForm.RunButtonClick(Sender: TObject);
var
  DriveInfoList: TList<TDriveInfo>;
  DriveInfo: TDriveInfo;

  Item: TListItem;
begin
  DriveInfoList := GetDriveInfo;

  for DriveInfo in DriveInfoList do begin
    item := DriveListView.Items.Add;
    item.Caption := DriveInfo.Name;
    item.SubItems.Add(DriveInfo.Device);
    item.SubItems.Add(DriveInfo.Drive);
    item.SubItems.Add(DriveInfo.Partition);
    item.SubItems.Add(DriveInfo.Serial);
  end;

  DriveInfoList.Free;
end;

end.
