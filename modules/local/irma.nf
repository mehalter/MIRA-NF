process IRMA {
    tag { "assembling genome with IRMA for ${sample}" }
    label 'process_high'
    container 'cdcgov/irma-latest'

    publishDir "${params.outdir}/IRMA",  mode: 'copy'
    publishDir "${params.outdir}/logs", pattern: '*.log', mode: 'copy'

    input:
    tuple val(sample), path(subsampled_fastq_files), val(irma_custom_0), val(irma_custom_1), val(module)

    output:
    tuple val(sample), path('*')

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """

    ${irma_custom_0} IRMA \\
        ${module} \\
        ${subsampled_fastq_files} \\
        ${sample} \\
        ${irma_custom_1} \\
        2> ${sample}.irma.stderr.log | tee -a ${sample}.irma.stdout.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        irma: \$(echo \$(IRMA | grep -o "v[0-9][^ ]*" | cut -c 2-))
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''

    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        irma: \$(echo \$(IRMA | grep -o "v[0-9][^ ]*" | cut -c 2-))
    END_VERSIONS
    """
}