process TRANSPOSE {
    tag "${meta.id}"
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'number25/alpine-plus-plus-plus:3.21.0'
        : 'quay.io/number_25/alpine-plus-plus-plus:3.21.0'}"

    input:
    tuple val(meta), path(alfred_stats)

    output:
    tuple val(meta), path("*.transposed.stats"), emit: alfred_stats_transposed
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_alfred"

    """
    zgrep ^ME ${alfred_stats} \\
    | cut -f 2- \\
    | datamash transpose \\
    | column -t \\
    > ${prefix}.transposed.stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        datamash: \$(datamash --version |& sed '1!d ; s/datamash (GNU datamash) //')
        zgrep: \$(zgrep --version | sed '1!d ; s/zgrep (gzip) //')
        column: \$(column --version | sed 's/column from util-linux //')
        cut: \$(cut --version | sed '1!d ; s/cut (GNU coreutils) //')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_${meta.replicate}_alfred"
    """
    touch ${prefix}.transposed.stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        datamash: \$(datamash --version |& sed '1!d ; s/datamash (GNU datamash) //')
        zgrep: \$(zgrep --version | sed '1!d ; s/zgrep (gzip) //')
        column: \$(column --version | sed 's/column from util-linux //')
        cut: \$(cut --version | sed '1!d ; s/cut (GNU coreutils) //')
    END_VERSIONS
    """
}
