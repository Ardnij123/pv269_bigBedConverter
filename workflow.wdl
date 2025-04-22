version 1.0

task convert_file {
    input {
        String chrom_url
        File bedfile
    }

    command <<<
        # see https://genome.ucsc.edu/goldenpath/help/bigBed.html
        # TODO: remove track and browser data
        # TODO: also get extra fields
        curl '~{chrom_url}' > 'chrom.sizes'
        bedToBigBed -sort '~{bedfile}' 'chrom.sizes' 'converted_bigbed_file.bb'
    >>>

    runtime {
        docker: "quay.io/biocontainers/ucsc-bedtobigbed:473--h52f6b31_1"
    }

    output {
        File chrom_sizes = "chrom.sizes"
        File bigbed = "converted_bigbed_file.bb"
    }
}


workflow convert {
    input {
        String chrom_url
        File bedfile
    }

    call convert_file {
        input: chrom_url = chrom_url,
        bedfile = bedfile
    }

    output {
        File chrom_sizes = convert_file.chrom_sizes
        File bigbed = convert_file.bigbed
    }
}
