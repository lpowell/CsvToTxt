param($infile, [switch]$help, $outfile, $read=100, [string[]]$header, $outsize=104857600)
# Parse big csvs

<#

read = lines read at a time. Lower = less memory for object.

headers = columns to read in each line, and names for them. 

#>


function GetCSV(){
    # Get the infile location (csv)
    $loc = (Get-Location).Path
    [int]$LinesInFile = 0

    # count the total number of lines
    # https://stackoverflow.com/questions/6855814/powershell-how-to-count-number-of-rows-in-csv-file
    $reader = New-Object IO.StreamReader "$loc\$infile"
     while($reader.ReadLine() -ne $null){ $LinesInFile++ }
    $reader.Dispose()

    # initialize counting 
    $LinesProcessed = 0
    # Write total lines in file
    write-host $LinesInFile "in file" $infile
    $x = 0
    # Get the file, reading only specified lines at a time -> convert csv, using speicifed headers as properties -> write object to text file -> if text file is greater than specified size, create a new one
    $content = Get-Content $infile -ReadCount $read | ForEach-Object{Write-Progress -Activity "Converting to text" -PercentComplete ($LinesProcessed / $LinesInFile); `
    ConvertFrom-Csv $_ -delimiter ',' -header $header | Out-File $outfile -Append; if((Get-Item $outfile).Length -gt $outsize){Move-Item $outfile $x$outfile; $x++} `
    ;$LinesProcessed++;}
    Write-Progress -completed True
}

function Help{
    Write-Host @"
    USAGE: CsvToTxt -infile[csv.file] -outfile[txt.file] -read[rows] -header[string array] -outsize[bytes]

    EXAMPLE USAGE: CsvToTxt -infile file.csv -outfile results.txt -read 100 -header 'name','location','id' -outsize 104857600

    Search output files with Select-String -Path .\*results.txt -Pattern "Bob Smith" -context 0, 3
    This will print 3 lines starting with the matched line
"@
}

# lets see if this works
if($help){
    help
    exit
}
GetCSV