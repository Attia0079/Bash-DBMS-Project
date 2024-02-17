#!/bin/bash

welcome(){

# Greeting
echo "Welcome to Bash-DBMS!"
echo "What would you like to do?" 

PS3="Please Choose a Number: "

# Entry menu
select option in CreateDB ConnectDB RemoveDB ListDBs Exit
do
    case $option in
        CreateDB)
            createdb
            ;;
        ConnectDB)
            echo "ConnectDB option selected"
            ;;
        RemoveDB)
            echo "RemoveDB option selected"
            ;;
        ListDBs)
            echo "ListDBs option selected"
            ;;
        Exit)
            echo "BYE!"
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done

}

# calling the function
welcome