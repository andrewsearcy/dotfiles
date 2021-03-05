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

# selection-menu() {
#   # spiffy selection menu
#   echo ''
#   PS3=$'\n'"%F{green}Select an environment:%{$reset_color%} "
#   if [ -z "$1" ]; then # if length arg != 0 (not empty string)
#     files=($(find . -type f -iname "*.env*"))
#     select file in "${files[@]}"; do
#       if [ 1 -le "$REPLY" ] && [ "$REPLY" -le ${#files[@]} ]; then
#         SELECTED_FILE=$file
#         break
#       else
#         ERROR="Invalid entry. Select a number between \033[00;32m1\033[0m-\033[00;32m${#files[@]}\033[0m "
#         printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $ERROR\n"
#       fi
#     done
#   else
#     USER_FILES=($(find . -type f -iname "*$1*" -maxdepth 2))
#     if [ ${#USER_FILES[@]} -eq 1 ]; then
#       SELECTED_FILE=$USER_FILES
#     else
#       select user_file in "${USER_FILES[@]}"; do
#         if [ 1 -le "$REPLY" ] && [ "$REPLY" -le ${#USER_FILES[@]} ]; then
#           SELECTED_FILE=$user_file
#           break
#         else
#           ERROR="Invalid entry. Select a number between \033[00;32m1\033[0m-\033[00;32m${#USER_FILES[@]}\033[0m "
#           printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $ERROR\n"
#         fi
#       done
#     fi
#   fi
#   echo $SELECTED_FILE
# }
# spark-env() {                    # shoutout to raymondd and andrews for the inspiration
#   SPARK=$(z -e edge-spark-react) # -e -- echo output without cd'ing to it
#   cd $SPARK
#   ENV_FILE=$(selection-menu $1)
#   MESSAGE="Building Spark with \033[00;32m$ENV_FILE\033[0m variables"
#   OK_MESSAGE="[ \033[00;32mOK\033[0m ] $MESSAGE"
#   echo -n $OK_MESSAGE | boxes -d unicornsay
#   set -a
#   source $ENV_FILE
#   set +a
#   # cat $SPARK/.env.$1 > $SPARK/.env ## other option to avoid set
#   npm run generate-graphql-types && npm start ## or `spark` alias
# }
# tg-source() {
#   set -a
#   ENV_FILE=$(selection-menu $1)
#   echo $ENV_FILE
#   source $ENV_FILE
#   set +a
#   npm run generate-graphql-types
# }