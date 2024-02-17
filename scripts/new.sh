#!/bin/bash



dbms_path="databases"
current_db=''

# a function to validate the name: existence(duplicate or not), special characters, and validates that it has a good start
validateTableName() {
    name=$1
    # Check if the table name is empty
    if [ -z "$name" ]; then
        echo "Input can't be empty"
        return 1
    fi
    
    # Check if the table already exists
    if [ -e "$dbms_path/$current_db/$name" ]; then
        echo "Table Already exists"
        return 1
    fi
    
    # Check if the table name matches the pattern
    if [[ ! $name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        echo "Invalid table name. Please enter a name without spaces, newlines, special characters, and starting with a letter."
        return 1
    fi

    return 0
}


welcome() {
    # Greeting
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
                ConnectDB
                ;;
            RemoveDB)
                echo "RemoveDB option selected"
                ;;
            ListDBs)
                echo "ListDBs option selected"
                ;;
            Exit)
                echo "BYE!"
                break
                ;;
            *)
                echo "Invalid option, please try again"
                ;;
        esac
    done
}

createdb() {
    while true; do
        read -p "Please Enter Database Name: " DBName
        if validateTableName "$DBName"; then
            # If the database name is valid, proceed with creating the database
            if [ -d "$dbms_path/$DBName" ]; then
                echo "Database Already exists"
            else 
                mkdir -p "$dbms_path/$DBName" && echo "Database Created Successfully" || echo "Failed to create database"
                # touch "$dbms_path/$DBName/.$DBName.metadata" # Create a metadata file for the database
                clear
                welcome  # Return to the welcome menu
                break  # Exit the loop if database creation is successful
            fi
        fi
    done
}

list_databases() {
    databses=ls $dbms_path
    while true; do
        databases=()
        index=1

        # Populate the databases array with directory names
        for db in "$dbms_path"/*; do
            if [ -d "$db" ]; then
                databases+=("$(basename "$db")")
                ((index++))
            fi
        done
        databases+=("Exit")

        # Display the menu
        echo "Databases: "
        select db in "${databases[@]}"; do
            case $db in
                "Exit")
                    echo "Exiting..."
                    break 2  # Exit both the select and the while loop
                    ;;
                *)
                    # Validate if the selected option is in the databases array
                    if [[ " ${databases[@]} " =~ " $db " ]]; then
                        echo "Successfully Connected to $db!"
                        current_db=$db
                        tableoptions
                    else
                        echo "Invalid option. Please try again."
                    fi
                    ;;
            esac
        done
    done
}

ConnectDB(){
    list_databases
}

#table options function
tableoptions(){
select option in createTB removeTB listTBs renameTB update
do
case $option in
"createTB")
read -p "Please Enter Table Name: " TableName
    while true; do
        dbTables=($(ls "$dbms_path/$current_db"))
        if validateTableName "$TableName"; then 
            if [[ " ${dbTables[@]} " =~ " $TableName " ]]; then
                echo "Table Already Exists"
                read -p "Please Enter Table Name: " TableName
            else
                break 
            fi
        else
            echo "Invalid table name. Please enter a name without spaces, newlines, special characters, and starting with a letter."
            read -p "Please Enter Table Name: " TableName
        fi
    done

   if [ ! -e $TableName ]; then
      read -p "Please Enter Number of columns: " colNumber
      #adding metadata to database
      echo $TableName:$colNumber >> $dbms_path/$current_db/.$current_db.metadata
      for ((i=1;i<=$colNumber;i++))
      do
        read -p "Please Enter Column $i Name: " colName
        if validateTableName "$colName"; then 
            select option in int float varchar date boolean
            do
                case $option in
                "int")
                break
                ;;
                "float")
                break
                ;;
                "varchar")
                break
                ;;
                "date")
                break
                ;;
                "boolean")
                break
                ;;
                *)
                echo "Invalid option"
                read -p "please choose a number: "
                esac
            echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
            done
        else
            echo "Invalid column name. Please enter a name without spaces, newlines, special characters, and starting with a letter."
            read -p "Please Enter Column $i Name: " colName
        fi
      done
      touch $dbms_path/$current_db/$TableName
      echo "Table Created Successfully!"
      tableoptions
   else
      echo "Table Already exists"
   fi
;;
"removeTB")
read -p "Please Enter Table Name: " TableName
    if [ -z $TableName ]; then
        echo "input can't be empty"
        continue
    fi
    if [  -e $TableName ]; then
        rm $TableName
        echo "Table Removed Successfully"
    else
        echo "Table doesn't exist"
    fi
;;
"listTBs")
    ls $dbms_path/$current_db/ -F | grep -v '/$' | sed 's/[*=@|]$//'
;;
"renameTB")
read -p "Please Enter Table Name: " TableName
    if [ -z $TableName ]; then
        echo "input can't be empty"
        continue
    fi
    if [ -e $TableName ]; then
        read -p "Please Enter New Table Name: " NewTableName
        mv $TableName $NewTableName
        echo "Table Is Renamed Successfully"
    else
        echo "Table doesn't exist"
    fi
;;
"update")
read -p "Please Enter Table Name: " TableName
    if [ -z $TableName ]; then
        echo "input can't be empty"
        continue
    fi
    if [ -e $TableName ]; then
        line_number=$(awk -F: -v word="$TableName" '$1 == word {print NR; exit}' .metadata.txt)
        value=$(awk -F: -v word="$TableName" '$1 == word {print $2; exit}' .metadata.txt)
        value=$((value + line_number))
        line_number=$((line_number + 1))
        awk -F: -v start="$line_number" -v end="$value" 'NR>=start && NR<=end' .metadata.txt


        # read -p "Please Enter New Table Name: " NewTableName
        # mv $TableName $NewTableName
        echo "Table Is Renamed Successfully"
    else
        echo "Table doesn't exist"
fi
;;
esac
done
}

# the actual exectution!
echo "Welcome to Bash-DBMS!"
echo "$dbms_path/$DBName/.$DBName.metadata"
welcome
