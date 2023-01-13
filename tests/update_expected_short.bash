#!/bin/bash

tests="gpas_ont_short
gpas_illumina_short"

for test_name in ${tests}
do
    cp /work/output/${test_name}_test/${test_name}_summary.tsv \
	    /data/pipelines/SARS-CoV2_workflows/tests/${test_name}_expected.tsv
done

