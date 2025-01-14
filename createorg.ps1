# Create Organizational Units
New-ADOrganizationalUnit -Name "Supervisors" -Path "DC=CDFC,DC=local"
New-ADOrganizationalUnit -Name "Troubleshooters" -Path "DC=CDFC,DC=local"