process SUBSET_BAMBU_GTF {
    //tag "${meta.id}"
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'number25/alpine-plus-plus-plus:3.21.0'
        : 'quay.io/number_25/alpine-plus-plus-plus:3.21.0'}"

    input:
    tuple val(meta), path(extended_gtf)
    path transcript_counts

    output:
    tuple val(meta), path("subset_annotations.gtf"),    emit: subset_gtf
    path "versions.yml",                                emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    awk 'BEGIN {FS="\t";OFS="\t"} \$3 != 0 {print \$1}' ${transcript_counts} | grep -wF -f - ${extended_gtf} >> "subset_annotations.gtf"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        awk: \$(awk --version | head -n1 | cut -d"," -f1)
    END_VERSIONS
    """

    stub:
    """
    touch "subset_annotations.gtf"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        awk: \$(awk --version | head -n1 | cut -d"," -f1)
    END_VERSIONS
    """
}
