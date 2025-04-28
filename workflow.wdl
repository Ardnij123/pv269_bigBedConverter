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
    # see https://genome.ucsc.edu/goldenpath/help/bigBed.html
    bedfile='~{bedfile}'
    if [ "${bedfile##*.}" == "gz" ]; then
      gzip -dc '~{bedfile}' > '~{output_stem}.bed'
    else
      cp '~{bedfile}' '~{output_stem}.bed'
    fi
    sort -k1,1 -k2,2n '~{output_stem}.bed' > 'sorted_file.bed'
    bedToBigBed 'sorted_file.bed' '~{chrom_sizes}' 'converted_bigbed_file.bb'
  >>>

  runtime {
    docker: "quay.io/biocontainers/ucsc-bedtobigbed:473--h52f6b31_1"
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
    chrom_sizes = get_chrom_sizes.chrom_sizes,
    bedfile = bedfile
  }

  output {
    File chrom_sizes = get_chrom_sizes.chrom_sizes
    File bigbed = convert_file.bigbed
  }
}
