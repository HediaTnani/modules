// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
options        = initOptions(params.options)

process ENSEMBLVEP {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    
    conda (params.enable_conda ? "bioconda::ensembl-vep=103.1-0" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/ensembl-vep:100.0--pl526hecc5488_0 "
    } else {
        container "quay.io/biocontainers/ensembl-vep:103.1--pl526hecda079_0"
    }

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.vcf"), emit: vcf
    path "*.version.txt"          , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix   = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    
    """
    vep\\
        $options.args \\
        -@ $task.cpus \\
        -i ${prefix}.vcf \\
        -o ${prefix}.variant_effect_output.txt -offline \\

    echo \$(vep --version 2>&1) | sed 's/^.*vep //; s/Using.*\$//' > ${software}.version.txt
    """
}
