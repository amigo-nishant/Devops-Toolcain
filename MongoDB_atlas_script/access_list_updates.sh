#!/bin/bash

# MongoDB Atlas API variables

# This script takes 3 paramaters GROUP_ID,IP_ADDRESS and NAME

#Public_KEY="YOUR_API_KEY"    Added as environment variable
#Private_KEY="YOUR_API_KEY"  Added as environment variable
IP_ADDRESS=$2
NAME=$3
ERROR="Not Found"
GROUP_ID=$1
# Set the temporary access list expiration to 7 days from now
NEW_DATE=`date +"%Y-%m-%dT%H:%M:%S%:z" -d "$end_date+7 days"`

# Search the current network access list for provided ip
SEARCH_ACCESS_LIST=$(curl --user "$Public_KEY:$Private_KEY" --digest  --header "Accept: application/json" --request GET "https://cloud.mongodb.com/api/atlas/v1.0/groups/${GROUP_ID}/accessList/$IP_ADDRESS")

# To check whether above IP is already added to access list. reason parameter value will be captured.
REASON=$(jq -r '.reason' <<< "$SEARCH_ACCESS_LIST")


# Search all the listed ip's in access list
SEARCH_ACCESS=$(curl --user "$Public_KEY:$Private_KEY" --digest  --header "Accept: application/json"  --request GET "https://cloud.mongodb.com/api/atlas/v1.0/groups/${GROUP_ID}/accessList")

IP=$(jq -r '.results[] | select(.comment=="'$NAME'") | .ipAddress' <<< "$SEARCH_ACCESS")
COMMENT=$(jq -r '.results[] | select(.comment=="'$NAME'") | .comment' <<< "$SEARCH_ACCESS")

# Condition check on if new ip address is not in the access list and user name is exist in the list, delete the old user entry and add the new to the access list.
if [[ $REASON == $ERROR ]] && [[ $NAME == $COMMENT ]]
then
        # delete the $NAME which already exists
        echo "Removing the name $NAME with $IP from the list"
        DELETE_ACCESS_LIST=$(curl --user "$Public_KEY:$Private_KEY" --digest  --header "Accept: application/json"  --request DELETE "https://cloud.mongodb.com/api/atlas/v1.0/groups/${GROUP_ID}/accessList/$IP")
       # Add new ip to the network access list
         echo "Adding the new ip $IP_ADDRESS with name $NAME to the access list"
         NEW_ACCESS_LIST=$(curl --user "$Public_KEY:$Private_KEY" --digest \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --include \
        --request POST "https://cloud.mongodb.com/api/atlas/v1.0/groups/${GROUP_ID}/accessList" --data '
          [
              {
                  "ipAddress" : "'$IP_ADDRESS'",
                  "deleteAfterDate": "'$NEW_DATE'",
                  "comment" : "'$NAME'"
              }
         ]')
        echo "$NEW_ACCESS_LIST"

# confition check on if new ip address is not in the access list and also the user name , then add the new entry to the access list.
elif [[ $REASON == $ERROR ]]  && [[ $NAME != $COMMENT ]]
then
        echo "Adding the new ip $IP_ADDRESS  and name $NAME to the access list"
        NEW_ACCESS_LIST=$(curl --user "$Public_KEY:$Private_KEY" --digest \
        --header 'Accept: application/json' \
        --header 'Content-Type: application/json' \
        --include \
        --request POST "https://cloud.mongodb.com/api/atlas/v1.0/groups/${GROUP_ID}/accessList" --data '
          [
              {
                  "ipAddress" : "'$IP_ADDRESS'",
                  "deleteAfterDate": "'$NEW_DATE'",
                  "comment" : "'$NAME'"

              }
         ]')
        echo "$NEW_ACCESS_LIST"

else
# Ip address is already added to the list

        echo "The ip $IP_ADDRESS is already present in the access list"
        echo "$SEARCH_ACCESS_LIST"
fi