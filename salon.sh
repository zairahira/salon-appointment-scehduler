#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ MY SALON ~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

ALL_SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  LIST_ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$LIST_ALL_SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #
  FORMATTED_SERVICE=$(echo $SERVICE_NAME_SELECTED | sed -r 's/^ *| *$//g')

  if [[ -z $SERVICE_NAME_SELECTED ]]
  then
    ALL_SERVICES_MENU "I could not find that service. What would you like today?"
  else
    USER_ADD_MENU
  fi
}

USER_ADD_MENU() {
  echo -e "\nWhat's your phone number?"

  read CUSTOMER_PHONE

  SELECTED_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $SELECTED_CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"

    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    SELECTED_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  SELECTED_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $SELECTED_CUSTOMER_ID")

  FORMAT_CUSTOMER_NAME=$(echo $SELECTED_CUSTOMER_NAME | sed -r 's/^ *| *$//g')

  TIME_MENU
}

TIME_MENU() {
  echo -e "\nWhat time would you like your $FORMATTED_SERVICE, $FORMAT_CUSTOMER_NAME?"

  read SERVICE_TIME

  NEW_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($SELECTED_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ -z $NEW_APPOINTMENT_RESULT ]]
  then
    echo -e "\nUnable to insert new appointment"
  else
    echo -e "\nI have put you down for a $FORMATTED_SERVICE at $SERVICE_TIME, $FORMAT_CUSTOMER_NAME."
  fi
}

ALL_SERVICES_MENU
