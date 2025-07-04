# Requires Invoke-CommandAs PowerShell Module to Run as Local System Account
# https://github.com/mkellerman/Invoke-CommandAs

# Intall Invoke-CommandAs Module if Not Installed
If (-NOT(Get-Module -Name Invoke-CommandAs -ListAvailable) {
   Install-Module -Name Invoke-CommandAs -Scope AllUsers -Force
}
# Check Number of Days Left in Grace Period
$DaysLeft = (invoke-cimmethod -inputobject (get-ciminstance -namespace root/CIMV2/TerminalServices -classname Win32_TerminalServiceSetting) -methodname GetGracePeriodDays).DaysLeft

# If Grace Period has Less Than 10 Days Remaining, Reset Grace Period
If ($DaysLeft -lt 10) {

    # Reset Grace Period Registry Key
    Invoke-CommandAs -ScriptBlock { `
        $GracePeriodProperty = (Get-Item "REGISTRY::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod").Property; `
        Remove-ItemProperty -Path "REGISTRY::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod" -Name $GracePeriodProperty -Force -Confirm:$False; `
    } -AsSystem
   
    # Restart Computer for New 120 Day Grace Period to Take Effect
    Restart-Computer -Force

}
