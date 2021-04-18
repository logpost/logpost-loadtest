#!/bin/bash

#### Prerequisites 🚀
# - linux
# - vegeta cli

#### OPTIONS REPORT 📝
TYPE="hist[0,100ms,200ms,300ms]"

#### OPTIONS ATTACK 🔪
DURATION="5s"
declare -a RATEs=("100" "500" "1000")
declare -a TARGETs=(
	"GET https://account-management-service-logpost-stag-qjrfn6j7kq-as.a.run.app/account/healthcheck"
	"GET https://shipper-management-service-logpost-stag-qjrfn6j7kq-as.a.run.app/shipper/healthcheck"
	"GET https://carrier-management-service-logpost-stag-qjrfn6j7kq-as.a.run.app/carrier/healthcheck"
	"GET https://jobs-management-service-logpost-stag-qjrfn6j7kq-as.a.run.app/jobs/healthcheck"
	"GET https://jobs-optimization-service-logpost-stag-qjrfn6j7kq-as.a.run.app/job-opts/healthcheck"
)

rm -rf metrics plots results 
mkdir metrics plots results

#### Attaking ⚔️
for RATE in "${RATEs[@]}"
do

	echo "#### 🔥🔥 RATE: $RATE, DURATION: $DURATION "
	
	mkdir metrics/$RATE-$DURATION plots/$RATE-$DURATION results/$RATE-$DURATION

	for TARGET in "${TARGETs[@]}"
	do	
		SPLITER=(${TARGET//// })
		SVC=${SPLITER[3]}

		echo "#### ✨ SVC: $SVC service"
		echo "#### 📝 TARGET: $TARGET"

		echo $TARGET | vegeta attack -rate=$RATE -duration=$DURATION -targets=vegeta.conf | tee results.bin | vegeta report
		mv results.bin results-$SVC-$RATE-$DURATION.bin
		vegeta report -type=json results-$SVC-$RATE-$DURATION.bin > metrics-$SVC-$RATE-$DURATION.json
		cat results-$SVC-$RATE-$DURATION.bin | vegeta plot > plot-$SVC-$RATE-$DURATION.html
		cat results-$SVC-$RATE-$DURATION.bin | vegeta report -type=$TYPE

		echo "#### 🎉 Complete" && echo ""

	done

	#### Organize 🧬
	echo "" && echo "#### 💊 Organizing.. "
	mv -f *$RATE-$DURATION*.json	metrics/*$RATE-$DURATION*
	mv -f *$RATE-$DURATION*.html	plots/*$RATE-$DURATION*
	mv -f *$RATE-$DURATION*.bin		results/*$RATE-$DURATION*
	echo "#### ⭐️ Complete Loadtest" && echo "" && echo ""

	sleep 10

done