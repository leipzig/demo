process RANDOM_FAIL {
    tag "${meta.id}"
    label 'process_single'

    conda "conda-forge::bash=5.1.16"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path(reads), emit: reads
    path  "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    #!/bin/bash

    # Generate a random number between 0 and 99
    RANDOM_NUM=\$((RANDOM % 100))

    echo "Random number generated: \$RANDOM_NUM"

    # Fail if random number is less than X (X% chance)
    if [ \$RANDOM_NUM -lt 10 ]; then
        echo "ERROR: Random failure triggered! (${prefix})"
        exit 1
    fi

    echo "SUCCESS: Passed random failure check (${prefix})"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n1 | sed 's/.*version //; s/ .*//')
    END_VERSIONS
    """

    stub:
    """
    echo "STUB: Skipping random failure check"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n1 | sed 's/.*version //; s/ .*//')
    END_VERSIONS
    """
}
