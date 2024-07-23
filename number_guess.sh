#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GAME () {
  SECRET=$(( $RANDOM % 1000 + 1 ))
  echo "Guess the secret number between 1 and 1000:"
  ATTEMPTS=0
  GUESSED=0

  while [[ $GUESSED == 0 ]]
  do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $GUESS == $SECRET ]]
    then
      ATTEMPTS=$(( $ATTEMPTS + 1 ))
      echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET. Nice job!"
      INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $ATTEMPTS)")
      GUESSED=1
    elif [[ $GUESS -lt $SECRET ]]
    then
      ATTEMPTS=$(( $ATTEMPTS + 1 ))
      echo "It's higher than that, guess again:"
    elif [[ $GUESS -gt $SECRET ]]
    then
      ATTEMPTS=$(( $ATTEMPTS + 1 ))
      echo "It's lower than that, guess again:"
    fi
  done
}

PROMPT () {
  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  else
    GAMES_PLAYED=$($PSQL "SELECT count(user_id) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT min(number_of_guesses) FROM games WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  GAME
}

PROMPT