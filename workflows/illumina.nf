#!/usr/bin/env nextflow

// enable dsl2
nextflow.enable.dsl=2

// import subworkflows
include {downstreamAnalysis} from './analysis.nf'

// import modules
include {getObjFiles} from '../modules/utils.nf'
include {getRefFiles} from '../modules/utils.nf'
include {checkSizeSubsample} from '../modules/utils.nf'
include {viridianPrimers} from '../modules/viridian.nf'
include {viridianAuto} from '../modules/viridian.nf'
include {download_primers} from '../modules/analysis.nf'
include {uploadToBucket} from '../modules/utils.nf'

workflow Illumina_viridian {
    take:
      ch_objFiles
    main:
      // get fastq files from objstore
      getObjFiles(ch_objFiles)

      if (params.limitMaxSampleSize) {
        // Subsample if needed
        checkSizeSubsample(getObjFiles.out.fqs)

        // Run standard pipeline
        sequenceAnalysisViridian(checkSizeSubsample.out.checked_fqs)
      }
      else {
        // Run standard pipeline
        sequenceAnalysisViridian(getObjFiles.out.fqs)
      }
}

workflow sequenceAnalysisViridian {
    take:
      ch_filePairs

    main:
      getRefFiles()

      if (params.primers != 'auto') {

        download_primers(params.primers)

        viridianPrimers(ch_filePairs.combine(download_primers.out).combine(getRefFiles.out.fasta))

        viridian=viridianPrimers

      }
      else if (params.primers == 'auto') {

        viridianAuto(ch_filePairs.combine(getRefFiles.out.fasta))

        viridian=viridianAuto

      }
      
      downstreamAnalysis(viridian.out.consensus, viridian.out.vcfs, getRefFiles.out.fasta, getRefFiles.out.bed)

      if (params.uploadBucket != false) {
        uploadToBucket(viridian.out.consensus.combine(viridian.out.bam, by:0)
                                .combine(viridian.out.vcfs, by:0)
                                .combine(downstreamAnalysis.out.json, by:0))
      }

}
