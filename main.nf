#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    number-25/LongTranscriptomics
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/number-25/LongTranscriptomics
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { LONGTX                } from './workflows/longtx'
include { validateParameters    } from 'plugin/nf-schema'
include { paramsSummaryLog      } from 'plugin/nf-schema'
include { checkConfigProvided; checkProfileProvided } from 'plugin/nf-core-utils'
//include { samplesheetToList     } from 'plugin/nf-scheme'
include { paramsHelp            } from 'plugin/nf-schema'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    //
    // nf-plugins validations
    // https://nf-co.re/docs/nf-core-tools/nf-core-utils/utilities/nfcoreconfigvalidator

    def hasCustomConfig = checkConfigProvided()

    if (!hasCustomConfig) {
    log.warn """
    ==========================================
    NO CUSTOM CONFIGURATION DETECTED
    ==========================================

    For optimal performance, consider:

    1. Institutional configs:
       nextflow run pipeline.nf -profile myInstitution

    2. Container profiles:
       nextflow run pipeline.nf -profile docker
       nextflow run pipeline.nf -profile singularity

    3. Custom config files:
       nextflow run pipeline.nf -c my_config.config

    4. HPC profiles:
       nextflow run pipeline.nf -profile test,slurm,docker

    See: https://nf-co.re/docs/usage/configuration
    ==========================================
    """
    }

    checkProfileProvided(args, params.monochrome_logs)

    // Parameter Validation
    validateParameters()

    log.info paramsSummaryLog(workflow)

    if (params.help) {
        log.info paramsHelp(
            beforeText: "Welcome to LongTranscriptomics, I see you are seeking help.",
            afterText: "Farewell, hopefully this was helpful.",
            command: "nextflow run . -profile <profile> --outdir <outdir>",
        )
        exit 0
    }

    // Config validation
    log.info """
    Pipeline Configuration Summary:
    - Custom config: ${hasCustomConfig ? 'Yes' : 'No (using defaults)'}
    - Profile: ${workflow.profile ?: 'none'}
    - Container engine: ${workflow.containerEngine ?: 'none'}
    """

    LONGTX()
}

/*    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url,
        //MEDGEN_DIRECTRNA.out.multiqc_report
    )
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
