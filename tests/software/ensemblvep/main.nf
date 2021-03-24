#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { ENSEMBLVEP } from '../../../software/ensemblvep/main.nf' addParams( options: [:] )

workflow test_ensemblvep {
    
    def input = []
    input = [ [ id:'test', single_end:false ], // meta map
              file("${launchDir}/tests/data/genomics/sarscov2/illumina/vcf/test.vcf", checkIfExists: true) ]

    ENSEMBLVEP ( input )
}
