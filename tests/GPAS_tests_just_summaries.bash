#!/bin/bash
#source ~/env/bin/activate

repo='/data/pipelines/SARS-CoV2_workflows'

## ont_artic_test
#test_name=ont_artic
#echo Running ${test_name} test workflow
#mkdir -p /work/runs/${test_name}_test
#cd /work/runs/${test_name}_test
#
#python3 ${repo}/tests/GPAS_tests_summary.py \
#	-w /work/runs/${test_name}_test \
#	-i /work/output/${test_name}_test/ \
#	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
#	-e /data/pipelines/ncov2019-artic-nf/tests/${test_name}_expected.tsv \
#	-c /work/output/${test_name}_test/${test_name}_comparison.tsv
#
# ont_viridian_test
test_name=ont_viridian
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

python3 ${repo}/tests/GPAS_tests_summary.py \
	-w /work/runs/${test_name}_test \
	-i /work/output/${test_name}_test/ \
	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
	-e ${repo}/tests/${test_name}_expected.tsv \
	-c /work/output/${test_name}_test/${test_name}_comparison.tsv

## illumina_artic_test
#test_name=illumina_artic
#echo Running ${test_name} test workflow
#mkdir -p /work/runs/${test_name}_test
#cd /work/runs/${test_name}_test
#
#python3 ${repo}/tests/GPAS_tests_summary.py \
#	-w /work/runs/${test_name}_test \
#	-i /work/output/${test_name}_test/ \
#	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
#	-e /data/pipelines/ncov2019-artic-nf/tests/${test_name}_expected.tsv \
#	-c /work/output/${test_name}_test/${test_name}_comparison.tsv
#
# illumina_Viridian_test
test_name=illumina_viridian
echo Running ${test_name} test workflow
mkdir -p /work/runs/${test_name}_test
cd /work/runs/${test_name}_test

python3 ${repo}/tests/GPAS_tests_summary.py \
	-w /work/runs/${test_name}_test \
	-i /work/output/${test_name}_test/ \
	-t /work/output/${test_name}_test/${test_name}_summary.tsv  \
	-e ${repo}/tests/${test_name}_expected.tsv \
	-c /work/output/${test_name}_test/${test_name}_comparison.tsv


