#!/bin/bash

createdb(){
    read -p "Please Enter Database Name: " DBName
    # checking that the dbname is not empty
    if [ -z $DBName ]; then
        echo "input can't be empty"
        continue
    fi
    #checking that the dbname exists
    if [ ! -e $DBName ]; then
        mkdir $dbms_path/$DBName
        echo "Database Created Successfully"
        touch "$dbms_path/$DBName/.metadata.txt"
    else #else the db exists
        echo "Database Already exists"
    fi
}
createdb