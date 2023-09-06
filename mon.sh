source mon.cfg

alert_state=''
while : 
do 
	state=$(curl "${url}/api/v2/query?org=home" \
		--header "Authorization: Token ${token}" \
		--header 'Accept: application/json' \
		--header 'Content-Type: application/vnd.flux' \
		--request POST \
		--data 'from(bucket: "deye_inverter")
			|> range(start: -1m)
			|> filter(fn: (r) => r["_measurement"] == "inverter")
			|> filter(fn: (r) => r["_field"] == "value")
			|> filter(fn: (r) => r["group"] == "Grid")
			|> filter(fn: (r) => r["name"] == "Connected")
			|> aggregateWindow(every: 2m, fn: last, createEmpty: false)
			|> yield(name: "last")' \
				--silent | column -t -s, | tail -n1 | awk '{print $6}')
	if [[ ${alert_state} != ${state} ]]; then
		text=''
		if [[ ${state} == "1" ]]; then
			text=connected	
		else 
			text=disconnected
		fi
		say "Grid ${text}" &
		echo "state_change: ${text}!"
		alert_state=${state}
	fi	
	sleep 5
done
