#!/bin/bash

# Copyright (c) 2017 Universitat Politècnica de València (UPV)
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the UPV nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# authors: Annibale Panichella and Urko Rueda (2017)

if [ $# -lt 3 ]
then
        echo "RUN_START, NRUNS and list of TIME_BUDGET expected as arguments"
	echo "example: this_script 1 3 30 60 120 240"
	echo "note: results_folder should not exist at target tools' home"
        exit 0;
fi

echo Runing paralel script from = $PWD at $(date +%Y/%m/%d-%H:%M:%S)
CURRENT_DIRECTORY=$PWD

# framework root dir
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FRAMEWORK_ROOT=$($SCRIPTS_DIR/get_framework_root.sh) #/data/PhD/SBSTContest/2018/myfork/junitcontest/ 

# contest tools: users and tool' folders
# (5th edition of the contest celebrated in 2017)
EVOSUITE_USER=evosuite
EVOSUITE_DIR=$FRAMEWORK_ROOT/home/$EVOSUITE_USER
T3_USER=t3
T3_DIR=$FRAMEWORK_ROOT/home/$T3_USER #/2016
DSC_USER=dsc_5th
DSC_DIR=$FRAMEWORK_ROOT/home/$DSC_USER
RANDOOP_USER=randoop
RANDOOP_DIR=$FRAMEWORK_ROOT/home/$RANDOOP_USER
JTEXPERT_USER=jtexpert
JTEXPERT_DIR=$FRAMEWORK_ROOT/home/$JTEXPERT_USER

NRUNS=$2
RUN_START_FROM=$1

# contest run: a user with rights for all tools must be used
run_tool_process() {
    local TOOLNAME=$1
    local TIMEBUDGET=$2

	# contest tools specific code
        if [ $TOOLNAME == evosuite ]; then
                local TOOL_DIR=$EVOSUITE_DIR
        fi
        if [ $TOOLNAME == t3 ]; then
                local TOOL_DIR=$T3_DIR
        fi
	if [ $TOOLNAME == jtexpert ]; then
                local TOOL_DIR=$JTEXPERT_DIR
        fi
	if [ $TOOLNAME == dsc ]; then
                local TOOL_DIR=$DSC_DIR
        fi
	if [ $TOOLNAME == randoop ]; then
                local TOOL_DIR=$RANDOOP_DIR
        fi

        echo $TOOLNAME - Tool Directory $TOOL_DIR
        cd $TOOL_DIR;

        echo $TOOLNAME -  Current dir = $PWD
        echo - - - $TOOLNAME - contest_generate_tests.sh $TOOLNAME $NRUNS $RUN_START_FROM $TIME_BUDGET at $(date +%Y/%m/%d-%H:%M:%S)
	$FRAMEWORK_ROOT/bin/scripts/contest_generate_tests.sh "$TOOLNAME" "$NRUNS" "$RUN_START_FROM" "$TIME_BUDGET" > execution_generate_$NRUNS_$RUN_START_FROM_$TIME_BUDGET.txt 2>execution2_generate_$NRUNS_$RUN_START_FROM_$TIME_BUDGET.txt

        echo === $TOOLNAME -  contest_compute_metrics.sh results_$TOOLNAME\_$TIME_BUDGET at $(date +%Y/%m/%d-%H:%M:%S)
	$FRAMEWORK_ROOT/bin/scripts/contest_compute_metrics.sh results_"$TOOLNAME"\_"$TIME_BUDGET" > execution_compute_$NRUNS_$RUN_START_FROM_$TIME_BUDGET.txt 2>execution2_compute_$NRUNS_$RUN_START_FROM_$TIME_BUDGET.txt

        cd $CURRENT_DIRECTORY
        echo $TOOLNAME - Current dir = $PWD
        echo $TOOLNAME - ... Computation finished for $TOOLNAME with time budget = $TIME_BUDGET
}

for TIME_BUDGET in ${@:3} # $3 onwards
do	for TOOLNAME in evosuite t3 jtexpert randoop # contest tools
	do      
		run_tool_process $TOOLNAME $TIMEBUDGET &
	done
	# wait for all process being completed
	wait
done

echo *** PARALEL SCRIPT FINISHED *** from = $PWD at $(date +%Y/%m/%d-%H:%M:%S)
