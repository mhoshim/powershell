# Create AD groups
New-ADGroup -Name "MBstaff" -GroupScope Global -GroupCategory Security
New-ADGroup -Name "SKstaff" -GroupScope Global -GroupCategory Security

#  Add members to specific groups
Add-ADGroupMember -Identity "MBstaff" -Members "Staff2", "Staff3", "Staff4"
Add-ADGroupMember -Identity "SKstaff" -Members "Staff1"
