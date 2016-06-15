############# Windows Azure Storage Functions #############################

Function GetAzureStorageAccount {

Param
    (
    $StorageAccount
    )

    # Test for the storage account
    Try
    {
        # Get the account name supplied, if this failed the catch block will be run.
        Get-AzureStorageAccount -StorageAccountName $StorageAccount -ErrorAction Stop

        # Set the valid variable to true if the command above works ok.
        $Valid = $True 
    }
    Catch
    {
        # A descriptive error!
        Write-Host "Erm...Storage account doesn't exist check for typos" -ForegroundColor Red
    }
    
Return, $Valid
}

Function CheckContainerName {

Param
    (
    $Context,
    $Container
    )

    Try
    {
        Get-AzureStorageContainer -Context $Context -Name $Container -ErrorAction Stop

        $Valid = $true

    }
    Catch
    {
        Write-Host "Erm...container doesn't exist check for typos" -ForegroundColor Red
            
        
    }
Return, $Valid
}

Function CheckVhdName {

Param
    (
    $context,
    $Container,
    $vhd
    )

    Try
    {
        Get-AzureStorageBlob -Context $context -Container $container -Blob $vhd -ErrorAction Stop
        
        $Valid = $true
    }
    Catch
    {
        Write-Host "Erm...blob doesn't exist check for typos" -ForegroundColor Red
        
    }
Return, $Valid
}

############# Windows Azure Storage Functions #############################

############# Exchange Online Functions ###################################

# This function takes the credentials passed to the $credentials variable and attempts to 
# connect to Exchange Online
Function ConnectToExchangeOnline {
    
    Param
    (
    $Credentials
    )
    
    # This array is used to return multiple values back to the script.
    [array]$arrExchConnection = @()

    Try
    {
        # Attempt to connect to Exchange Online.
        $arrExchConnection = New-PSSession -ConfigurationName Microsoft.Exchange `
        -ConnectionUri https://ps.outlook.com/powershell -Credential $Credentials `
        -AllowRedirection -Authentication Basic -ErrorAction Stop

        # If the connection above worked then add value to the array. If the connection above fails then the -ErrorAction Stop will 
        # jump straigh to the catch block.
        $arrExchConnection += $true
    }
    catch
    {
        # If the connection fails then warnings below are outputted.
        Write-Host "Error caught" -foregroundcolor Red
        Write-Host "Enter your credentials again" -ForegroundColor Yellow
        
        $arrExchConnection = "Place holder"
        $arrExchConnection += $false
    }

return, $arrExchConnection

}

############# Exchange Online Functions ###################################


############# General Functions #####################################
Function WriteToLog {

	Param
	(
	$sLogFile,
	$sLogContent
	)
	
	If (Test-Path (Join-Path -Path $StartIn -ChildPath $sLogFile)) {
	
		# Append to the file
		Add-Content -Path (Join-Path -Path $StartIn -ChildPath $sLogFile) -Value $sLogContent
		
	}
	Else {
	
		# Create the file
		New-Item -ItemType File -Path (Join-Path -Path $StartIn -ChildPath $sLogFile)
		Add-Content -Path (Join-Path -Path $StartIn -ChildPath $sLogFile) -Value $sLogContent
		
	}
}

Function CheckAzureVMState {

    Param
    (
    $sAzureCloudService,
    $sAzureVM,
    $sStartHour,
    $sStopHour
    )

    If ($(Get-Date).Hour -lt $sStartHour -or $(Get-Date).Hour -ge $sStopHour) {
        
        # Check the VM status
        # If it is not running then leave it be
        If ((Get-AzureVM -ServiceName $sAzureCloudService -Name $sAzureVM).Status -ne "StoppedDeallocated"){
                    
            Stop-AzureVM -ServiceName $sAzureCloudService -Name $sAzureVM -Force

            WriteToLog -sLogFile $LogFileName -sLogContent "Stopping $sAzureVM...$(Get-Date)"

        }
        Else {

            WriteToLog -sLogFile $LogFileName -sLogContent "Nothing to do...$sAzureVM is already stopped...$(Get-Date)"

        }
    }
    Else {

        # Check the VM status
        # If it is running then leave it be
        If ((Get-AzureVM -ServiceName $sAzureCloudService -Name $sAzureVM).Status -ne "ReadyRole"){
    
            Start-AzureVM -ServiceName $sAzureCloudService -Name $sAzureVM
            
            WriteToLog -sLogFile $LogFileName -sLogContent "Starting $sAzureVM...$(Get-Date)"
        }
        Else {

            WriteToLog -sLogFile $LogFileName -sLogContent "Nothing to do...$sAzureVM is already running...$(Get-Date)"

        }
    }     
}

############# General Functions #####################################