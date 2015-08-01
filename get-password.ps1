#Requires -Modules ActiveDirectory

#Optional parameter to specify the computer name as a parameter.
Param
(
	[Parameter(Mandatory=$False)]
		[string]$compName
)

#Get the machine name from the user if necessary.
#Didn't want to set Mandatory to $true because I wanted the flavor text.
if($compName -eq "") {
	Write-Host "Enter the shortname of the computer; don't specify domain information!"
	$compName = Read-Host "Name"
}

#Make sure the name is in the correct format.
$check = $compName.Split(".")

if($check.Count -ne 1) {
	Write-Host "That isn't a valid name format! Try again..."
	$needName = $true
	
	while($needName) {
		$compName = Read-Host "Name"
		$check = $compName.Split(".")
		
		#Re-do this if the name has dots.
		if($check.Count -eq 1) {
			$needName = $false
		} else {
			Write-Host "Try entering a valid name!"
		}
	}
}

#Make sure the object exists in AD.
#Running the script only works within a domain. Helps to prevent duplicate
#	name issues since my domains were migrated from 2008 where it didn't complain
#	when duplicate names existed between domains in a single forest.
#	Also means I don't need to import AdmPwd.PS.
$currentDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
$currentDomain = $currentDomain.Split(".")
$domainValue = ""
$counter = 0

#Parse the "domain.something.tld" into "dc=domain,dc=something,dc=tld"
foreach($part in $currentDomain) {
	if($counter -lt ($currentDomain.Count - 1)) {
		$domainValue += "DC=" + $part + ","
	} else {
		$domainValue += "DC=" + $part
	}
	
	$counter++
}

#Pull back the AD object itself while getting the password property.
$compObject = Get-ADComputer -Filter {name -eq $compName} -SearchBase $domainValue -SearchScope Subtree -Properties ms-Mcs-AdmPwd

#Notify if the object doesn't exist in AD, the password is blank, or the user can't read it.
if($compObject -eq $null) {
	Write-Host "That computer doesn't exist in AD! Please verify the name and try again!"
} elseif($compObject."ms-Mcs-AdmPwd" -eq $null) {
	Write-Host "Either the object has no password value or you don't have rights to access it!"
} else {
	#No double-quotes will make PowerShell think you're trying to specify a parameter...
	Write-Host $compObject."ms-Mcs-AdmPwd"
}