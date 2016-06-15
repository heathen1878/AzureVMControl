#############################################################################################
# This script is used to start and stop Azure IaaS virtual machines at specified times.		#
#																							#
# The virtual machines and their associated cloud service details are stored in a csv file.	#
#																							#
# The Azure module will import itself when you first run a cmdlet.                          #   
#                                                                                           #
#############################################################################################

# Constants
$StartIn = $PSScriptRoot
$DateStamp = $(Get-Date).Day,$(Get-Date).Month,$(Get-Date).Year -join "_"
$LogFileName = "AzureStartStop_$dateStamp.log"

# Dot reference the functions file
. c:\scripts\Functions.ps1

# Start by logging what we are doing for tracability
WriteToLog -sLogFile $LogFileName -sLogContent "Script started...$(Get-Date)"

# Declare some variables
[bool]$Validator = $False
$sCSVFile = "AzureIaaSVMs.csv"

# Import the virtual machines from a csv file
# First of all, look for the csv file.
WriteToLog -sLogFile $LogFileName -sLogContent "Looking for AzureIaasVMs.csv in $StartIn"
If (Test-Path (Join-Path $StartIn -ChildPath $sCSVFile)) {
    
    WriteToLog -sLogFile $LogFileName -sLogContent  "Found csv file. Importing data"
    $AzureIaasVMs = Import-Csv -Path (Join-Path $StartIn -ChildPath $sCSVFile)

}
Else {

    WriteToLog -sLogFile $LogFileName -sLogContent "csv file not found, exiting the script."
    Exit

}

# Loop through the data and check whether the VM should be be turned on, turned off or left alone.
$AzureIaasVMs | % {

    #Assign pipeline values to variables 
    $CloudServiceName = $_.CloudServiceName
    $VirtualMachineName = $_.VirtualMachineName
    $StartTime = $_.StartTime
    $StopTime = $_.StopTime

    WriteToLog -sLogFile $LogFileName -sLogContent "Working on: $VirtualMachineName"

    # What time window and days should this instance run?
    switch ($(Get-Date).DayOfWeek)
    {
        Default
        {
            # It must be a weekday
            # Check the time and the VM status
            

            CheckAzureVMState -sAzureCloudService $CloudServiceName `
            -sAzureVM $VirtualMachineName -sStartHour $StartTime -sStopHour $StopTime
        }
        "Saturday"
        {
    
            # Ok, its Saturday...
            # Should my VM run today?
            If ($_.Weekends -eq "Yes"){
                # yep we're running today.
                # Check the time and the VM status
                CheckAzureVMState -sAzureCloudService $CloudServiceName `
                -sAzureVM $VirtualMachineName -sStartHour $StartTime -sStopHour $StopTime
            }
        }
        "Sunday"
        {
    
            # Ok, its Sunday...
            # Should my VM run today?
            If ($_.Weekends -eq "Yes"){
                # yep we're running today.
                # Check the time and the VM status
                CheckAzureVMState -sAzureCloudService $CloudServiceName `
                -sAzureVM $VirtualMachineName -sStartHour $StartTime -sStopHour $StopTime
            }
        }
    }

# End logging
WriteToLog -sLogFile $LogFileName -sLogContent "Script stopped...$(Get-Date)"
}