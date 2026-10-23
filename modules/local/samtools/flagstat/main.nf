process SAMTOOLS_FLAGSTAT {
    tag "${meta.id}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/samtools:1.20--h50ea8bc_0'
        : 'biocontainers/samtools:1.20--h50ea8bc_0'}"

    input:
    tuple val(meta), path(bam)

    output:
    //tuple val(meta2), path(fasta)
    tuple val(meta), path("*.txt"), emit: flagstat
    //tuple val(meta), path("*.cram"),    emit: cram, optional: true
    //tuple val(meta), path("*.crai"),    emit: crai, optional: true
    //tuple val(meta), path("*.csi"),     emit: csi,  optional: true
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}.flagstat"
    def extension = task.ext.extension ?: "txt"
    /*def extension = args.contains("--output-fmt sam") ? "sam" :
    args.contains("--output-fmt cram") ? "cram" :
    "bam"
    def reference = fasta ? "--reference ${fasta}" : ""
    if ("$bam" == "${prefix}.bam") error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
     */
    // Option to have genome ${reference} in sort \\
    """
    samtools flagstats \\
        -@ ${task.cpus} \\
        -O ${extension} \\
        ${bam} \\
        > ${prefix}.txt \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}.flagstat"
    """
    touch ${prefix}.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
    END_VERSIONS
    """
}
