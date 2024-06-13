process TRIMPRIMERSLEFT {
    tag { "${sample }" }
    label 'process_medium'
    container 'staphb/bbtools:39.01'

    publishDir "${params.outdir}/IRMA", pattern: '*.fastq', mode: 'copy'
    publishDir "${params.outdir}/logs", pattern: '*.log', mode: 'copy'

    input:
    tuple val(sample), path(subsampled_fastq_1), path(subsampled_fastq_2)
    path(primers)

    output:
    tuple val(sample), path('*ptrim_l_R1.fastq'), path('*ptrim_l_R2.fastq'), emit: trim_l_fastqs
    path '*.primertrim_left.stdout.log', emit: primertrim_l_log_out
    path '*.primertrim_left.stderr.log', emit: primertrim_l_log_err
    path 'versions.yml'           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    bbduk.sh \\
        in1=${subsampled_fastq_1} in2= ${subsampled_fastq_2} \\
        out1=${sample}_ptrim_l_R1.fastq out2=${sample}_ptrim_l_R2.fastq \\
        rcomp=t \\
        qtrim=r \\
        mm=f \\
        hdist=1 \\
        ref=${primers} \\
        ordered=t \\
        minlength=0 \\
        k=17 \\
        restrictright=30 \\
        1> ${sample}.primertrim_left.stdout.log \\
        2> ${sample}.primertrim_left.stderr.log

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimprimersleft: \$(bbtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimprimersleft: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
