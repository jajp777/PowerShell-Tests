﻿Describe "String cmdlets" -Tags 'innerloop' {
    Context "Select-String" {
        BeforeAll {
            $fileName = New-Item 'TestDrive:\selectStr[ingLi]teralPath.txt'
            "abc" | Out-File -LiteralPath $fileName.fullname            
	        "bcd" | Out-File -LiteralPath $fileName.fullname -Append
	        "cde" | Out-File -LiteralPath $fileName.fullname -Append

            $fileNameWithDots = $fileName.FullName.Replace("\", "\.\")
            
            $tempFile = New-TemporaryFile            
            "abc" | Out-File -LiteralPath $tempFile.fullname            
	        "bcd" | Out-File -LiteralPath $tempFile.fullname -Append
	        "cde" | Out-File -LiteralPath $tempFile.fullname -Append
            $driveLetter = $tempFile.PSDrive.Name
            $fileNameAsNetworkPath = "\\localhost\$driveLetter`$" + $tempFile.FullName.SubString(2)

	        Push-Location "$fileName\.."
        }

        AfterAll {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            Pop-Location
        }

        It "LiteralPath with relative path" {
            (select-string -LiteralPath (Get-Item -LiteralPath $fileName).Name "b").count | Should Be 2	    
        } 

        It "LiteralPath with absolute path" {	        
            (select-string -LiteralPath $fileName "b").count | Should Be 2	    
        }

        It "LiteralPath with dots in path" {	        
            (select-string -LiteralPath $fileNameWithDots "b").count | Should Be 2	    
        }

        It "Network path" {
            (select-string -LiteralPath $fileNameAsNetworkPath "b").count | Should Be 2
        }

        It "throws error for non filesystem providers" {
            select-string -literalPath cert:\currentuser\my "a" -ErrorAction SilentlyContinue -ErrorVariable selectStringError
            $selectStringError.FullyQualifiedErrorId | Should Be 'ProcessingFile,Microsoft.PowerShell.Commands.SelectStringCommand'
        }
    }
}