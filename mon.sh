source mon.cfg


while : 
do 
	curl "${url}/api/v2/query?org=home" \
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
		--silent | column -t -s, | tail -n1 | awk '{print $6}'; 
done
