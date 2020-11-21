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