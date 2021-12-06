#!/bin/bash

tests="ont_artic
ont_viridian
illumina_artic
illumina_viridian"

repo='/data/pipelines/SARS-CoV2_workflows'
for test_name in ${tests}
do
    cp /work/output/${test_name}_test/${test_name}_summary.tsv \
	    ${repo}/tests/${test_name}_expected.tsv
done

