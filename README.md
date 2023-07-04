# Convert-Csv
Converts csv files to html, txt, or json. Html conversions include searching functions in the format property=value. The table will automatically adjust to only display matching results. 
Installation

    Install-Module -Name Convert-Csv 

Usage

    Convert-Csv -InputFile [file] -OutputFile [file] -mode [string] -Read (optional[int])  -Count (optional[int]) -HeaderStart (optional[int]) -Size (optional[int])

    -Mode 
        - html, txt, or json
    -read
        - # of lines to read in at a time from the csv. Smaller values will usually result in faster processing. 
    -count
        - Number of rows to include per html page. E.g., -count 20 will break the csv into 20 line pages. 
    -HeaderStart
        - The row in the csv that includes headers. If you have exported the csv from PowerShell, this should be 2. 
    -Size
        - the maximum size in bytes for the output files. Used only with text conversions. E.g., -size 1024 will break the csv into a collection of text files that are no greater than 1mb. 
Examples

    Example Usage for converting a csv to html
    - Convert-Csv -InputFile foo.csv -OutputFile foo.html -mode html -HeaderStart 2 -count 200

    Converts the csv into a collection of dynamically linked 200 object HTML pages.

    Example Usage converting csv to a collection of text files. 
    - Convert-Csv -InputFile foo.csv -OutputFile foo.txt -mode txt -HeaderStart 2 -read 100 -size 104857600

    Converts the csv into a collection of text files no greater than 100mb in size. Additionally, reads the csv into the script 100 lines at a time. 








# Old\CsvToTxt
Convert big csv files to multiple text files. 

    USAGE: CsvToTxt -infile[csv.file] -outfile[txt.file] -read[rows] -header[string array] -outsize[bytes]

    EXAMPLE USAGE: CsvToTxt -infile file.csv -outfile results.txt -read 100 -header 'name','location','id' -outsize 104857600
    
Needed to convert a very large csv to a smaller format, so I made this.
Params match ConvertFrom-Csv params. Outsize is the size in bytes of each output file. E.g., an outsize of 104857600 will make each file roughly 100MB. 

To search through the files afterwards, try 

    Select-String -Path .\*results.txt -Pattern "Bob Smith" -context 0, 3
    
This will print 3 lines starting with the matched line.
If you have multiple output files and want to search all files for something

    Select-String -Path .\*results.txt -Pattern "Bob Smith" | select Path

This will return the file that the match was found in. 
