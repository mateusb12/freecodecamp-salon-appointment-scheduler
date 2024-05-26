#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

get_services() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  local services=$($PSQL "SELECT service_id, name FROM services")

  echo "$services" | while read -r service_id name; do
    echo "$service_id) $name"
  done

  read -r selected_service_id
  case $selected_service_id in
    [1-5]) handle_customer_info "$selected_service_id" ;;
    *) get_services "I could not find that service. What would you like today?" ;;
  esac
}

handle_customer_info() {
  local service_id=$1

  echo -e "\nWhat's your phone number?"
  read -r customer_phone

  local customer_name
  customer_name=$($PSQL "SELECT name FROM customers WHERE phone='$customer_phone'" | sed 's/ //g')

  if [[ -z $customer_name ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read -r customer_name
    $PSQL "INSERT INTO customers(name, phone) VALUES('$customer_name', '$customer_phone')"
  fi

  local service_name
  service_name=$($PSQL "SELECT name FROM services WHERE service_id=$service_id" | sed 's/ //g')
  
  local customer_id
  customer_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$customer_phone'" | sed 's/ //g')

  echo -e "\nWhat time would you like your $service_name, $customer_name?"
  read -r service_time

  local appointment_result
  appointment_result=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($customer_id, $service_id, '$service_time')")

  if [[ $appointment_result == "INSERT 0 1" ]]; then
    echo -e "\nI have put you down for a $service_name at $service_time, $customer_name."
  fi
}

get_services
