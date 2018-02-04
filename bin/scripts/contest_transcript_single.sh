# Copyright (c) 2017 Universitat Politècnica de València (UPV)
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 3. Neither the name of the UPV nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# author: Urko Rueda (2016)

SINGLE_TRANSCRIPT="single_transcript.csv"
RESULTS_TMP="results.tmp"

if [ $# -ne 1 ]
then
	echo "Results folder expected as argument"
	echo "example: transcript_single.sh ./results-folder"
	echo "output: $SINGLE_TRANSCRIPT and $RESULTS_TMP"
	exit 0;
fi

# header might change with new columns!
header="tool,benchmark,class,run,preparationTime,generationTime,executionTime,testcaseNumber,uncompilableNumber,brokenTests,failTests,linesTotal,linesCovered,linesCoverageRatio,conditionsTotal,conditionsCovered,conditionsCoverageRatio,mutantsTotal,mutantsCovered,mutantsCoverageRatio,mutantsKilled,mutantsKillRatio,mutantsAlive,timeBudget,totalTestClasses"

echo $header >$RESULTS_TMP
echo "Writing all transcripts into: $RESULTS_TMP"
idx=0
find $1 -name "transcript.csv" | grep "metrics/" | while read TRANSCRIPT
do
	idx=$(( $idx + 1 ))
	echo "  doing: [$idx] $TRANSCRIPT"
	cat $TRANSCRIPT | while read TR_LINE
	do
		if [[ $TR_LINE != $header ]] && [[ -n $TR_LINE ]]
		then
			echo $TR_LINE >>$RESULTS_TMP
		fi
	done
done

echo $header >$SINGLE_TRANSCRIPT
# contest tools
for TOOL in evosuite t3 jtexpert randoop
do
	echo "Processing tool: $TOOL"
	# contest time budgets
	for BUDGET in 10 30 60 120 240 #300 480 # 380
	do
		echo "  Processing budget: $BUDGET"
		# contest runs
		for RUN in 1 #2 3
		do
			echo "    Processing run: $RUN"
			bdx=0
			# contest benchmarks
			for BENCHMARK in FASTJSON-1 FASTJSON-2 FASTJSON-3 FASTJSON-4 FASTJSON-5 FASTJSON-6 FASTJSON-7 FASTJSON-8 FASTJSON-9 FASTJSON-10 ANTLR4-1 ANTLR4-2 ANTLR4-3 ANTLR4-4 ANTLR4-5 ANTLR4-6 ANTLR4-7 ANTLR4-8 ANTLR4-9 ANTLR4-10 ZXING-1 ZXING-2 ZXING-3 ZXING-4 ZXING-5 ZXING-6 ZXING-7 ZXING-8 ZXING-9 ZXING-10 DUBBO-1 DUBBO-2 DUBBO-3 DUBBO-4 DUBBO-5 DUBBO-6 DUBBO-7 DUBBO-8 DUBBO-9 DUBBO-10 JSOUP-1 JSOUP-2 JSOUP-3 JSOUP-4 JSOUP-5 WEBMAGIC-1 WEBMAGIC-2 WEBMAGIC-3 WEBMAGIC-4 WEBMAGIC-5 OKIO-1 OKIO-2 OKIO-3 OKIO-4 OKIO-5 OKIO-6 OKIO-7 OKIO-8 OKIO-9 OKIO-10 REDISSON-1 REDISSON-2 REDISSON-3 REDISSON-4 REDISSON-5 REDISSON-6 REDISSON-7 REDISSON-8 REDISSON-9 REDISSON-10 
			#for BENCHMARK in OKHTTP-1
			do
				bdx=$(( $bdx + 1 ))
                                echo "      Processing benchmark: $TOOL x $BUDGET x $RUN x [$bdx]$BENCHMARK"
				found=0
				cat $RESULTS_TMP | (while read RESULT
				do
					if [[ $RESULT =~ ^$TOOL,$BENCHMARK,[^,]*,$RUN,.*,$BUDGET,[^,]*$ ]]
					then
						echo $RESULT >>$SINGLE_TRANSCRIPT
						found=1
						fi
				done
				if [[ $found == 0 ]]
				then
					echo "$TOOL,$BENCHMARK,?,$RUN,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,$BUDGET,?" >>$SINGLE_TRANSCRIPT
				fi)
			done
		done
	done
done
