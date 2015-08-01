#Getting Passwords From LAPS
This is a basic PowerShell script to facilitate getting the automatically generated passwords stored in Active Directory by the [Local Administrator Password Solution (LAPS)](https://support.microsoft.com/en-us/kb/3062591).

##Notes
The solution is based on my current environment, which is a large forest with many child domains. Being that the built-in LAPS cmdlets like `Get-AdmPwdPassword` will not accept any type of server or domain information, this has the potential to cause conflicts in large environments that are pre-Windows Server 2012 or which have been upgraded to Windows Server 2012+ from something older. That is because prior forests did not care about actively blocking duplicate SPNs and thus allowed for objects in different domains to have the same shortname. The same shortname was previously only blocked *within* a single domain. So searching `Get-AdmPwdPassword` with a very generic name like "Workstation" has the potential for conflicts.

Due to my delegation setup, I can be fairly safe is assuming that administrators looking up LAPS passwords will only care to do so for their current domain - they will definitely only have the rights to do it in a single domain. So I check the current domain of the machine from which the script is running and use that as the search base.

##Requirements

Having PowerShell and the AD PowerShell module are the only requirements. I am not using anything from the AdmPwd.PS module provided by LAPS. 