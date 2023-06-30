<#
.Synopsis
  Csv converter. Converts csv files to html, txt, or json. Supports several formatting options.  

.Description
  Csv converter. Converts csv files to html, txt, or json. Supports several formatting options. 

  Further information can be found on https://blog.bajiri.com. 

.Parameter InputFile                
    The csv file to process                                       
.Parameter OutputFile              
    The filename to output to. In the case of multiple files, these will be named 0-filename, 1-filename, and so on.
.Parameter Read             
    The number of lines to read at a time. Allows faster processing for large files by reading blocks of lines at a time, instead of reading the whole file. Default is 100.
.Parameter Mode                  
    The conversion mode. Html, txt, or json.
.Parameter Size                
    Used with the txt mode. Specifies maximum size for output files. Once the file is larger than the maximum size, it will be split. Default is 104857600 bytes.
.Parameter Count          
    Used with html mode. Specifies the number of lines to print on one page. Default is 20.
.Parameter Help      
    Display a help menu.    

.Example 
   Convert-Csv -InputFile .\process.csv -OutputFile Process.html -read 100 -mode html -Count 50

.Link
    http://blog.bajiri.com
   
#>
function Convert-Csv{
    param($InputFile, [switch]$help, $OutputFile, $read=100, $Size=104857600, $Mode, $Count=20)

    if($Help){
        Help
        exit
    }

    # Count lines in file
    [int]$LineCount = 0
    $CurrentPath = (Get-Location).Path
    $Reader = New-Object IO.StreamReader "$CurrentPath\$InputFile"
    While($Reader.ReadLine() -ne $Null){ $LineCount++ }
    $Reader.Dispose()

    # Get Headers - Needs to be in a string array to work with ConvertFrom-Csv
    $Headers = Get-Content $InputFile -First 2 | Select-Object -Last 1
    $Headers = Out-String -InputObject $Headers
    $Headers = $Headers.split(',')

    # Load File 
    $LoadedCsv = Get-Content $InputFile -ReadCount $Read 

    # Process Csv
    $ProcessedCsv = @()
    Foreach($x in $LoadedCsv){
        $ProcessedCsv += ConvertFrom-Csv -InputObject $x -Delimiter ',' -Header $Headers
    }

    # Begin output processing
    if($Mode -eq "html"){
        ProcessHtml $LineCount $ProcessedCsv $Headers
    }elseif($Mode -eq "json"){
        ProcessJson $LineCount $ProcessedCsv
    }else{
        ProcessTxt $LineCount $ProcessedCsv
    }

}

function ProcessTxt($Lines, $ProcessedCsv){
    begin{
        $Stopwatch = [System.Diagnostics.Stopwatch]::startNew()
    }
    process{
        # Create an iterator for file renaming
        $I = 0

        # Write to txt file
        Foreach($x in $ProcessedCsv){
            Out-File -InputObject $x -FilePath $OutputFile -Append

            # Test file size
            if((Get-Item $OutputFile).length -gt $Size){
                Move-Item $OutputFile "$I-$OutputFile"
                $I++
            }
        }

        # Rename operating file to keep numbering correct
        Move-Item $OutputFile "$I-$OutputFile"
    }
    end{
        $Stopwatch.Stop() 
        Write-Host "File written to"(Get-location).Path -nonewline;Write-host "\$OutputFile"
        Write-Host "Time Elapsed(seconds):"$Stopwatch.Elapsed.TotalSeconds
        Write-Host "Processed $Lines lines"
    }
}

function ProcessHtml($Lines, $ProcessedCsv, $headers){
    begin{
        $Stopwatch = [System.Diagnostics.Stopwatch]::startNew()
    }
    process{
        # Fragment as table

        # Create directory 
        if(-not (Get-Item -Path "www")){
            New-Item -Path "www" -ItemType Directory
        }else{
            # Destroy existing html
            Get-ChildItem "www" | %{rm $_.FullName}
        }

        # Create Site
        $HTMLStart = @'
            <!DOCTYPE html>
            <HTML>
                <head>
                    <style>
                        #Device {position: absolute; top: 2%; left: 2%; padding: 0px 0px;}
                        #Author { float: left; padding: 0px 100px; }
                        #Device, #Author { display: inline;}
                        #Content { float: center; top: %5; clear:both; text-align:center;} 
                        a:link { color: #000000;}
                        a:visited { color: #000000;}
                        h1, h5, th { text-align: center; font-family: Segoe UI;}
                        table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
                        th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; text-wrap:normal; word-wrap:break-word;}
                        td { font-size: 11px; padding: 5px 20px; color: #000; max-width: 600px; text-wrap:normal; word-wrap:break-word; }
                        tr { background: #b8d1f3; text-wrap:normal; word-wrap:break-word}
                        tr:nth-child(even){ background: #dae5f4; text-wrap:normal; word-wrap:break-word;}
                        p { text-align: center;}
                        .Summary { margin: auto; overflow: hidden;}
                        iframe { margin: auto; width: 1200; height: 400; display:block; border: 0px;}
                        ul { display: inline-block; text-align: left;}
                        .sidenav {height: 100%;width: 0;position: fixed;z-index: 1;top: 0;left: 0;background-color: #111;overflow-x: hidden;transition: 0.5s;padding-top: 60px;}
                        .sidenav a {padding: 8px 8px 8px 32px;text-decoration: none;font-size: 25px;color: #818181;display: block;transition: 0.3s;}
                        .sidenav a:hover {color: #f1f1f1;}
                        .sidenav .closebtn {position: absolute;top: 0;right: 25px;font-size: 36px;margin-left: 50px;}
                        @media screen and (max-height: 450px) {.sidenav {padding-top: 15px;}.sidenav a {font-size: 18px;}}
                    </style>                
                </head>
                <body>
                    <div id=Content>
                    <span style="font-size:30px;cursor:pointer;float:left;" onclick="openNav()">&#9776; Contents</span>
                        <h1 id="title">
                        <script>
                            var fileName = location.href.split("/").slice(-1); 
                            var out = String(fileName).split(".");
                            document.getElementById("title").innerHTML = out[0];
                            function openNav() {
                              document.getElementById("mySidenav").style.width = "250px";
                            }
                            function closeNav() {
                              document.getElementById("mySidenav").style.width = "0";
                            }
                        </script>
                        <div id="mySidenav" class="sidenav">
                          <a href="javascript:void(0)" class="closebtn" onclick="closeNav()">&times;</a>

'@

        # Process into html tables
        # Get count
        $a = 0
        $Base = $Count
        for($I=0;$Count -lt $Lines;$I++){
            if($I -ne 0){
                $a = $count + 1
                $Count = $Count + $Base
            }
            $HTMLChunk = $ProcessedCsv | Select -Index ($a..$Count) | ConvertTo-Html -Fragment | Out-File -FilePath "www\$I-$OutputFile"
            # Add link to the nav menu for eah file
            $NavAdd =@'
                <a href="{0}">Page {1}</a>
'@ -f "$I-$OutputFile", $I
            $HTMLStart += $NavAdd
        }
        # End HTML
        $HTMLEnd=@'
                </body>
            </html>
'@
        # Add html header into all html files in www
        Foreach($x in Get-ChildItem www){
            $Current = Get-Content -Path www\$x 
            Out-File -InputObject $HTMLStart -FilePath www\$x
            Add-Content -Value "`t`t`t</div>`n" -Path www\$x
            Add-Content -Value $Current -Path www\$x
            Add-Content -Value $HTMLEnd -Path www\$x
        }
    }
    end{
        $Stopwatch.Stop() 
        Write-Host "Files written to www: " (Get-ChildItem www).count
        Write-Host "Time Elapsed(seconds):"$Stopwatch.Elapsed.TotalSeconds
        Write-Host "Processed $Lines lines"
    }
}

function ProcessJson($Lines, $ProcessedCsv){
    begin{
        $Stopwatch = [System.Diagnostics.Stopwatch]::startNew()
    }
    process{
        Out-File -FilePath $OutputFile -InputObject (ConvertTo-Json -InputObject $ProcessedCsv)
    }
    end{
        $Stopwatch.Stop() 
        Write-Host "File written to"(Get-location).Path -nonewline;Write-host "\$OutputFile"
        Write-Host "Time Elapsed(seconds):"$Stopwatch.Elapsed.TotalSeconds
        Write-Host "Processed $Lines lines"
    }
}

function Help{
    write-host "`nConvert-Csv converts csv files into text, html, or json files."
    write-Host "`nGeneral Parameters"
    Write-Host "`t-Inputfile`n`t`tThe csv to process."
    Write-Host "`t-OutputFile`n`t`tThe name, including extension, of the file to be written.`n`t`tIn the case of multiple output files, they will be name 0-filename, 1-filename, etc..."
    Write-Host "`t-Read`n`t`tThe amount of lines to read at one time from the csv. Useful for large csv files.`n`t`tDefault = 100."
    Write-Host "`t-Mode`n`t`tThe desired output type. Html, Txt, or Json."
    Write-Host "`nText Mode:"
    Write-Host "`t-Size`n`t`tThe maximum size, in bytes, of the output text files."
    Write-Host "`nHtml Mode:"
    Write-Host "`t-Count`n`t`tThe number of lines to print on each page.`n`t`tDefault = 20"
    Write-Host "`nExample: .\Convert-Csv.ps1 -InputFile .\process.csv -OutputFile Process.html -read 100 -mode html -Count 50"

}
Export-ModuleMember -Function Convert-Csv