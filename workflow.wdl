version 1.0

task get_chrom_sizes {
  input {
    String chrom_url
  }

  command <<<
    wget '~{chrom_url}' --output-document='chrom.sizes'
  >>>

  runtime {
    docker: "quay.io/biocontainers/wget:1.20.1"
  }
  
  output {
    File chrom_sizes = "chrom.sizes"
  }
}

task convert_file {
  input {
    File bedfile
    File chrom_sizes
  }

  command <<<
    wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/bedToBigBed
    chmod a+x bedToBigBed
    sort -k1,1 -k2,2n '~{bedfile}' > 'sorted_bed'
    ./bedToBigBed 'sorted_bed' '~{chrom_sizes}' 'converted_bigbed_file.bb'
  >>>

  runtime {
    docker: "quay.io/biocontainers/wget:1.20.1"
  }

  output {
    File bigbed = "converted_bigbed_file.bb"
  }
}


workflow convert {
  input {
    String chrom_url
    File bedfile
  }

  call get_chrom_sizes {
    input:
    chrom_url = chrom_url
  }

  call convert_file {
    input:
    bedfile = bedfile,
    chrom_sizes = get_chrom_sizes.chrom_sizes
  }

  output {
    File chrom_sizes = get_chrom_sizes.chrom_sizes
    File bigbed = convert_file.bigbed
  }
}
