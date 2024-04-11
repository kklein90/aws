#!/bin/bash

# change the retention setting for ALL CW log groups in your account - modify the days to a compatible CW parameter value

for group in $(aws logs describe-log-groups | jq .logGroups[].logGroupName); do
    group=$(echo $group | sed 's/"//g')
    aws logs put-retention-policy --log-group-name $group --retention-in-days 1
done
