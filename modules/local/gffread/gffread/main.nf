process GFFREAD_GETFASTA {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/gffread:0.12.9--hf426362_0'
        : 'biocontainers/gffread:0.12.9--hf426362_0'}"

    input:
    tuple val(meta), path(gtf)
    tuple path(genome_fasta), path(genome_fasta_index)
    val origin

    output:

    //tag "$fasta"
    tuple val(meta), path("*.fa"), emit: transcripts_fa
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    //    def show_warnings = task.ext.show_warnings ?: '-E'
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_${origin}_transcripts"
    """
    gffread \\
    -w ${prefix}.fa \\
    -g ${genome_fasta} \\
    ${gtf}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gffread: \$(gffread --version)
    END_VERSIONS
    """

    stub:
    //    def show_warnings   = task.ext.show_warnings ?: '-E'
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_${origin}_transcripts"
    """
    touch ${prefix}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gffread: \$(gffread --version)
    END_VERSIONS
    """
}
