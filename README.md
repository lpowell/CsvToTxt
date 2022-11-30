# CsvToTxt
Convert big csv files to multiple text files. 

    USAGE: CsvToTxt -infile[csv.file] -outfile[txt.file] -read[rows] -header[string array] -outsize[bytes]

    EXAMPLE USAGE: CvsToTxt -infile file.csv -outfile results.txt -read 100 -header 'name','location','id' -outsize 104857600
    
Needed to convert a very large csv to a smaller format, so I made this.
Params match ConvertFrom-Csv params. Outsize is the size in bytes of each output file. E.g., an outsize of 104857600 will make each file roughly 100MB. 

To search through the files afterwards, try 

    Get-Content results.txt | Select-String -Pattern "Bob Smith" -context 0, 3
    
This will print 3 lines starting with the matched line.
