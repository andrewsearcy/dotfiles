## EASY ADD ENVIRONMENT
spark-env() {                    # shoutout to raymondd and andrews for the inspiration
  SPARK=$(z -e edge-spark-react) # -e -- echo output without cd'ing to it
  cd $SPARK
  # spiffy selection menu
  if [ -z "$1" ]; then # if length arg != 0 (not empty string)
    PS3=$'\n'"%F{green}Select an environment:%{$reset_color%} "
    files=($(find . -type f -iname "*.env.*"))
    select file in "${files[@]}"; do
      if [ 1 -le "$REPLY" ] && [ "$REPLY" -le ${#files[@]} ]; then
        ENV_FILE=$file
        break
      else
        ERROR="INVALID ENTRY. Please select a number between \033[00;32m1\033[0m-\033[00;32m${#files[@]}\033[0m"
        printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $ERROR" | boxes -d nuke -a hcvc
      fi
    done
  else
    ENV_FILE=$SPARK/.env.$1
  fi
  MESSAGE="Building Spark with $ENV_FILE variables"
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $MESSAGE" | boxes -d unicornsay -a hcvc

  cat $ENV_FILE > $SPARK/.env
  
  npm run generate-graphql-types && npm start ## or `spark` alias
}

es() {
  DEFAULT="amtest"
  AUCTION=${3:-$DEFAULT}
  echo ""
  echo "============="
  echo "\033[00;33mELASTIC-SEARCHING ....\033[0m"
  echo "Stock Number [ \033[00;32m$1\033[0m ] "
  echo "Environment: [ \033[00;32m${2:-dev}\033[0m ]"
  echo "Auction: [ \033[00;32m$AUCTION\033[0m ]"
  SEARCH_URL="https://vpc-dev-edge-spark-abjrfqwjnu4tkra7hugnfgwhe4.us-west-2.es.amazonaws.com"
  STAGE_SEARCH_URL="https://vpc-stage-edge-spark-ayaymeuahm7sf5xwl6s4uvlfpe.us-west-2.es.amazonaws.com"
  PROD_SEARCH_URL="https://vpc-prod-edge-spark-20210322-hor4s3m3tmg52beleuia5ux374.us-west-2.es.amazonaws.com"
  if [ -n "$2" ]; then
    if [ "$2" = "prod" ]; then
      SEARCH_URL=$PROD_SEARCH_URL
    elif [ "$2" = "stage" ]; then
      SEARCH_URL=$STAGE_SEARCH_URL
    fi
    echo $SEARCH_URL
  fi
  PAYLOAD='{"track_total_hits": true,"track_scores": true,"query": {"bool": {"must": [{"match": {"auction_code": "'$AUCTION'"}},{"match": {"is_valid": "1"}},{"match": {"stock_number": "'"${1}"'"}}]}}}'
  echo "============="
  echo "\033[00;33mELASTICSEARCH RESPONSE ....\033[0m"
  curl -XGET "$SEARCH_URL/a_vehicles/_search?pretty=true" -H 'Content-Type: application/json' -d"$PAYLOAD"
  echo "Showing results for Stock Number [ \033[00;32m$1\033[0m ] "
  echo "Environment: [ \033[00;32m${2:-dev}\033[0m ]"
  echo "Auction: [ \033[00;32m$AUCTION\033[0m ]"
}
es-all() {
  SEARCH_URL="https://vpc-dev-edge-spark-abjrfqwjnu4tkra7hugnfgwhe4.us-west-2.es.amazonaws.com"
  STAGE_SEARCH_URL="https://vpc-stage-edge-spark-ayaymeuahm7sf5xwl6s4uvlfpe.us-west-2.es.amazonaws.com"
  PROD_SEARCH_URL="https://vpc-prod-edge-spark-20210322-hor4s3m3tmg52beleuia5ux374.us-west-2.es.amazonaws.com"
  if [ -n "$2" ]; then
    if [ "$2" = "prod" ]; then
      SEARCH_URL=$PROD_SEARCH_URL
    elif [ "$2" = "stage" ]; then
      SEARCH_URL=$STAGE_SEARCH_URL
    fi
    echo $SEARCH_URL
  fi
  PAYLOAD='{"track_total_hits": true,"track_scores": true,"query": {"bool": {"must": [{"match": {"is_valid": "1"}},{"match": {"stock_number": "'"${1}"'"}}]}}}'
  curl -XGET "$SEARCH_URL/a_vehicles/_search?pretty=true" -H 'Content-Type: application/json' -d"$PAYLOAD"
  echo "Showing results for Stock Number [ \033[00;32m$1\033[0m ] "
  echo "Environment: [ \033[00;32m${2:-dev}\033[0m ]"
  echo "Auction: [ \033[00;32mANY\033[0m ]"
}
es-go() {
  echo "\033[00;33mLet's get you that vehicle up in Spark ....\033[0m"
  echo "Stock Number [ \033[00;32m$1\033[0m ] "
  echo "Environment: [ \033[00;32m${2:-dev}\033[0m ]"
  echo "Auction: [ \033[00;32m${3:-amtest}\033[0m ]"
  SEARCH=$(es $1 $2 $3)
  ID=$(echo $SEARCH | ack "\"_id\" : \"([0-9]+)\"" --output '$1')
  if [ "$2" = "prod" ]; then
    open "https://spark.auctionedge.com/details/vehicles?id=$ID&auction=${3:-amtest}"
  elif [ "$2" = "stage" ]; then
    open "https://sparkpreview-stage.ext.edgeapps.net/details/vehicles?id=$ID&auction=${3:-amtest}"
  else
    open "https://sparkpreview.ext-dev.edgeapps.net/details/vehicles?id=$ID&auction=${3:-amtest}"
  fi
  # | ack "\"_id\" : \"([0-9]+)\"" --output '$1'
}
get-veh() {
  echo "\033[00;33mGetting vehicle details ....\033[0m"
  echo "Stock Number [ \033[00;32m$1\033[0m ] "
  echo "Environment: [ \033[00;32m${2:-dev}\033[0m ]"
  echo "Auction: [ \033[00;32m${3:-amtest}\033[0m ]"
  SEARCH=$(es $1 $2 $3)
  ID=$(echo $SEARCH | ack "\"_id\" : \"([0-9]+)\"" --output '$1')
  echo "Asset ID: [ \033[00;32m$ID\033[0m ]"
  echo ''
  if [ "$2" = "prod" ]; then
    pg-o-p -xc"SELECT * FROM ods.get_vehicle_details($ID, '${3:-amtest}');"
  elif [ "$2" = "stage" ]; then
    pg-o-s -xc"SELECT * FROM ods.get_vehicle_details($ID, '${3:-amtest}');"
  else
    pg-o-d -xc"SELECT * FROM ods.get_vehicle_details($ID, '${3:-amtest}');"
  fi
}

es-i() {
  SEARCH_URL="https://vpc-dev-edge-spark-abjrfqwjnu4tkra7hugnfgwhe4.us-west-2.es.amazonaws.com"
  STAGE_SEARCH_URL="https://vpc-stage-edge-spark-ayaymeuahm7sf5xwl6s4uvlfpe.us-west-2.es.amazonaws.com"
  PROD_SEARCH_URL="https://vpc-prod-edge-spark-20210322-hor4s3m3tmg52beleuia5ux374.us-west-2.es.amazonaws.com"
  if [ -n "$1" ]; then
    if [ "$1" = "prod" ]; then
      SEARCH_URL=$PROD_SEARCH_URL
    elif [ "$1" = "stage" ]; then
      SEARCH_URL=$STAGE_SEARCH_URL
    fi
    echo $SEARCH_URL
  fi
curl -XGET "$SEARCH_URL/_cat/indices?v"
}
