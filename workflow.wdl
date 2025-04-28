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

# Taken from https://github.com/ENCODE-DCC/segway-pipeline/blob/dev/segway.wdl#L290
task convert_file {
  input {
    File bedfile
    File chrom_sizes
  }

	File output_stem = "converted_bigbed_file"

  command <<<
		set -euxo pipefail
		gzip -dc '~{bedfile}' > '~{output_stem}.bed'
		bedToBigBed '~{output_stem}.bed' '~{chrom_sizes}' '~{output_stem}.bb'
		gzip -n '~{output_stem}.bed'
  >>>

  runtime {
    docker: "encodedcc/segway-pipeline:1.2.0"
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
