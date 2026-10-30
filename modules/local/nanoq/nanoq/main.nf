nextflow.enable.types = true

process NANOQ {
    tag "${meta.id}"
    label 'process_low'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/nanoq:0.10.0--h031d066_2'
        : 'biocontainers/nanoq:0.10.0--h031d066_2'}"

    input:
    //tuple val(meta), path(fastq)
    record(
        meta: Map,
        fastq: Path
    )

    output:
    //One of the following: fastq, fastq.gz, fastq.bz2, fastq.lzma, fasta, fasta.gz, fasta.bz2, fasta.lzma.
    record(
        meta: Map,
        stats: file("*_stats.txt"),
        verbose_stats: file("*_stats_verbose.txt"),
        json_stats: file("*.json"),
        versions: file("versions.yml")
    )

    //file("versions.yml", emit: versions

    //tuple val(meta), path("*_stats.txt"), emit: stats
    //tuple val(meta), path("*_stats_verbose.txt"), emit: verbose_stats
    //tuple val(meta), path("*.json"), emit: json_stats

    //when:
    //task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_nanoq"
    """
    nanoq \\
        -s \\
        -v \\
        -i ${fastq} \\
        > ${prefix}_stats.txt

    nanoq \\
        -s \\
        -vvv \\
        -i ${fastq} \\
        > ${prefix}_stats_verbose.txt

    nanoq \\
        -s \\
        -j \\
        -i ${fastq} \\
        > ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoq: \$(nanoq --version | sed -e 's/nanoq //g')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_nanoq"
    """
    touch ${prefix}_stats.txt
    touch ${prefix}_stats_verbose.txt
    touch ${prefix}.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nanoq: \$(nanoq --version | sed -e 's/nanoq //g')
    END_VERSIONS
    """
}
