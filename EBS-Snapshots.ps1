# +---------------------------------------------------------------------------
# | File : BackuptoS3_Snapshots.ps1
# | Version : 1.0
# | Purpose : Backs up to S3 & creates EBS snapshots
# | Synopsis:
# | Usage : .\BackuptoS3_Snapshots.ps1
# +----------------------------------------------------------------------------
# |
# | File Requirements:
# | Must have AWS S3 CLI installed & Powershell tools
# | CLI - https://s3.amazonaws.com/aws-cli/AWSCLI64.msi
# | PS Tools - http://aws.amazon.com/powershell/
# +----------------------------------------------------------------------------
# | Maintenance History
# | View GitHub notes: https://github.com/allenk1/ISO-Scripts/commits/master/BackuptoS3_Snapshots.ps1
# ********************************************************************************


# Default input params
$access = "123123123123"
$private = "12312312312312312312312"
$vol_id = @("vol-12312312", "vol-12312312", "vol-12312312", "vol-12312312", "vol-12312312", "vol-12312312", "vol-12312312")
$servername = "Server_NAME"
$region = "us-west-2"   # Regions: us-east-1, us-west-2, us-west-1, eu-west-1, ap-southeast-1
                        # ap-southeast-2, ap-northeast-1, sa-east-1
$backusptokeep = 5
$ownerid = 123123123123

# $a = Get-Date
# $date = $a.Year + "_" + $a.Month + "_" + $a.Day   #YYYYMMDD
$date = Get-Date -format s

import-module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

# Clear any saved credentials
# Clear-AWSCredentials -StoredCredentials

# Set credentials
Set-AWSCredentials -AccessKey $access -SecretKey $private
Set-DefaultAWSRegion $region

# Loop through all volumes and create snapshots
# Naming Scheme ServerName_VOLID

$snapshots = Get-EC2Snapshot -OwnerId $ownerid

foreach($snapshot in $snapshots){
    $end = $snapshot.Starttime
    $datediff = [Datetime]$date - [Datetime]$end
    $diff = $datediff.TotalDays

    if ( $diff -gt $backusptokeep ){
        Remove-EC2Snapshot -SnapshotId $snapshot.SnapshotId
    }
}


foreach ($vol in $vol_id) {
    $volinfo = Get-EC2Volume -VolumeId $vol
        
    $name = ($volinfo.tag).value
    
    # snapshot the EBS store
    $snapshot_name = $name + " " + $date

    New-EC2Snapshot -VolumeId $vol -Description $snapshot_name

}
