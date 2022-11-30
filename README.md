# CsvToTxt
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
