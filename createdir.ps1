# Define the directories and their permissions
$folders = @(
    @{Path="C:\Catalogue"; Permissions=@(
        @{Identity="Administrator"; Rights="FullControl"},
        @{Identity="MBstaff"; Rights="Modify"},
        @{Identity="SKstaff"; Rights="Modify"}
    )},
    @{Path="C:\Catalogue\MB"; Permissions=@(
        @{Identity="Administrator"; Rights="FullControl"},
        @{Identity="MBstaff"; Rights="Modify"},
        @{Identity="Staff2"; Rights="Read"}
    )},
    @{Path="C:\Catalogue\SK"; Permissions=@(
        @{Identity="Administrator"; Rights="FullControl"},
        @{Identity="SKstaff"; Rights="Modify"},
        @{Identity="Staff1"; Rights="Read"}
    )}
)

# Create folders and set permissions
foreach ($folder in $folders) {
    # Create folder if it doesn't exist
    try {
        Get-Item -Path $folder.Path -ErrorAction Stop
        Write-Host "Folder $($folder.Path) already exists."
    } catch {
        New-Item -Path $folder.Path -ItemType Directory
        Write-Host "Folder $($folder.Path) created."
    }

    # Get ACL of the folder
    $acl = Get-Acl $folder.Path

    # Disable inheritance and remove inherited permissions
    $acl.SetAccessRuleProtection($true, $false)

    # Add new permissions
    foreach ($perm in $folder.Permissions) {
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $perm.Identity, 
            $perm.Rights, 
            "ContainerInherit,ObjectInherit", 
            "None", 
            "Allow"
        )
        $acl.AddAccessRule($rule)
    }

    # Apply the new ACL to the folder
    Set-Acl $folder.Path $acl
}

# Create public Stuff folder
New-Item -Path "C:\Stuff" -ItemType Directory
icacls "C:\Stuff" /grant "Everyone:(OI)(CI)(R)"