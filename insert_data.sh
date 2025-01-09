#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

 insert_team(){
  local TEAM_ID="$($PSQL "select team_id from teams where name='$1'")"
  if [[ -z "$TEAM_ID" ]]
   then
     INSERT_TEAM_RESULT="$($PSQL "insert into teams(name) values('$1')")"
     if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
     then
       #Get the team's id
        TEAM_ID="$($PSQL "select team_id from teams where name='$1'")"
        echo -e "\n Team inserted successfully!" >&2
      fi  
   fi
  echo "$TEAM_ID"
 }
cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
 #avoid the headers
 if [[ $YEAR == "year" ]]
   then
    continue
   fi
 WINNER_ID=$(insert_team "$WINNER")
 if [[ -z $WINNER_ID ]]
  then
   echo -e "\n There was a problem inserting the winner team: $WINNER"
   continue
  fi
 OPPONENT_ID=$(insert_team "$OPPONENT")
 if [[ -z $OPPONENT_ID ]]
  then
   echo -e "\n There was a problem inserting the opponent team: $OPPONENT"
   continue
  fi
 #insert the game
 INSERT_GAME_RESULT="$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")"
 if [[ $INSERT_GAME_RESULT == "INSERT 0 1"  ]]
  then
   echo -e "\n Game inserted successfully!"
  else
   echo -e "\n There was a problem inserting the game: $WINNER vs $OPPONENT"
  fi
done
