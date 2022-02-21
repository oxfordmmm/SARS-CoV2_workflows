#!/bin/bash
#source ~/env/bin/activate

repo='/data/pipelines/SARS-CoV2_workflows'
comp_venv='/home/ubuntu/env'

# ont_viridian_test
test_name=gpas_ont_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

if ! [ -z ${comp_venv} ]
then
    source $comp_venv/bin/activate
fi

python3 ${repo}/tests/GPAS_tests_summary.py \
	-w /work/runs/${test_name}_test \
	-i /work/output/${test_name}_test/ \
	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
	-e ${repo}/tests/${test_name}_expected.tsv \
	-c /work/output/${test_name}_test/${test_name}_comparison.tsv

# illumina_Viridian_test
test_name=gpas_illumina_short
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

python3 ${repo}/tests/GPAS_tests_summary.py \
	-w /work/runs/${test_name}_test \
	-i /work/output/${test_name}_test/ \
	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
	-e ${repo}/tests/${test_name}_expected.tsv \
	-c /work/output/${test_name}_test/${test_name}_comparison.tsv


