param($infile, [switch]$help, $outfile, $read=100, [string[]]$header, $outsize=104857600)
# Parse big csvs


function GetCSV(){
    $loc = (Get-Location).Path
    [int]$LinesInFile = 0

    # https://stackoverflow.com/questions/6855814/powershell-how-to-count-number-of-rows-in-csv-file
    $reader = New-Object IO.StreamReader "$loc\$infile"
     while($reader.ReadLine() -ne $null){ $LinesInFile++ }
    $reader.Dispose()

    LinesProcessed = 0
    write-host $LinesInFile "in file" $infile
    $x = 0
    $content = Get-Content $infile -ReadCount $read | ForEach-Object{Write-Progress -Activity "Converting to text" -PercentComplete ($LinesProcessed / $LinesInFile); `
    ConvertFrom-Csv $_ -delimiter ',' -header $header | Out-File $outfile -Append; if((Get-Item $outfile).Length -gt $outsize){Move-Item $outfile $x$outfile; $x++} `
    ;$LinesProcessed++;}
    Write-Progress -completed True
}

function Help{
    Write-Host @"
    USAGE: CsvToTxt -infile[csv.file] -outfile[txt.file] -read[rows] -header[string array] -outsize[bytes]

    EXAMPLE USAGE: CvsToTxt -infile file.csv -outfile results.txt -read 100 -header 'name','location','id' -outsize 104857600

    Search output files with Get-Content results.txt | Select-String -Pattern "Bob Smith" -context 0, 3
    This will print 3 lines starting with the matched line
"@
}

# lets see if this works
if($help){
    help
    exit
}
GetCSV