#!/bin/bash

dbms_path="databases"
databases=$(ls "$dbms_path")

# current_db=''

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
    select option in CreateDB ConnectDB ListDBs DropDB Exit
    do
        case $option in
            CreateDB)
                createdb
                ;;
            ConnectDB)
                ConnectDB
                ;;
            DropDB)
                DropDB
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
    # databses=ls $dbms_path
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

list_tables() {
    while true; do
        tables=()
        index=1

        # Populate the tables array with table names, excluding hidden files
        while IFS= read -r -d '' table; do
            table_basename=$(basename "$table")
            tables+=("$table_basename")
            ((index++))
        done < <(find "$dbms_path/$current_db" -maxdepth 1 -type f ! -name ".*" -print0)

        tables+=("Exit")

        # Display the menu
        echo "Tables: "
        select table in "${tables[@]}"; do
            case $table in
                "Exit")
                    echo "Exiting..."
                    break 2 
                    ;;
                *)
                    current_table=$table
                    echo "You selected $table table. Insert data logic goes here."
                    awk -F ':' -v table="$table" '{
                        # Processing each line
                        if ($1 == table) {
                            current_row = $0 
                            columns_count = $2
                            line_number = 1

                            # Print the current line with its number
                            print "The Table Name: " table
                            print "The Number of Columns: " columns_count


                            # Loop to print the next "columns_count" lines with their numbers
                            for (i = 1; i <= columns_count; i++) {
                                if (getline next_line > 0) {
                                    print line_number ": " next_line
                                    line_number++
                                }
                            }
                        }
                    }' "$dbms_path/$current_db/.$current_db.metadata"
                      
                    columns_number=$(awk -F ':' -v table="$table" '$1 == table { print $2 }' "$dbms_path/$current_db/.$current_db.metadata")
                    for ((i=1; i<=columns_number; i++))
                    do
                        read -p "Please enter the data for column number $i: " data
                        if [[ $i -lt $columns_number ]]; then
                            echo -n "$data:" >> "$dbms_path/$current_db/$current_table"
                        else
                            echo "$data" >> "$dbms_path/$current_db/$current_table"
                        fi 
                    done
                    echo "Data Inserted Successfully!"
                    tableoptions
                    ;;
            esac
        done
    done
}



ConnectDB(){
    list_databases
}

DropDB(){
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
                        rm -rf "$dbms_path/$db"
                        echo "$db Database Dropped Successfully."
                        welcome
                    else
                        echo "Invalid option. Please try again."
                    fi
                    ;;
            esac
        done
    done
}

#table options function
tableoptions(){
    select option in createTB removeTB listTBs renameTB insert update disconnect
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
                    echo "$TableName:$colNumber" >> "$dbms_path/$current_db/.$current_db.metadata"
                    for ((i=1;i<=$colNumber;i++))
                    do
                        read -p "Please Enter Column $i Name: " colName
                        if validateTableName "$colName"; then 
                        select option in int float varchar date boolean; do
                            case $option in
                                "int")
                                    echo "$colName:$option" >> "$dbms_path/$current_db/.$current_db.metadata"
                                    break
                                    ;;
                                "float")
                                    echo "$colName:$option" >> "$dbms_path/$current_db/.$current_db.metadata"
                                    break
                                    ;;
                                "varchar")
                                    echo "$colName:$option" >> "$dbms_path/$current_db/.$current_db.metadata"
                                    break
                                    ;;
                                "date")
                                    echo "$colName:$option" >> "$dbms_path/$current_db/.$current_db.metadata"
                                    break
                                    ;;
                                "boolean")
                                    echo "$colName:$option" >> "$dbms_path/$current_db/.$current_db.metadata"
                                    break
                                    ;;
                                *)
                                    echo "Invalid option"
                                    read -p "Please choose a number: "
                                    ;;
                            esac
                        done

                        else
                            echo "Invalid column name. Please enter a name without spaces, newlines, special characters, and starting with a letter."
                            read -p "Please Enter Column $i Name: " colName
                        fi
                    done
                    touch "$dbms_path/$current_db/$TableName"
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
                    rm "$TableName"
                    echo "Table Removed Successfully"
                else
                    echo "Table doesn't exist"
                fi
                ;;
            "listTBs")
                ls "$dbms_path/$current_db/" -F | grep -v '/$' | sed 's/[*=@|]$//'
                ;;
            "renameTB")
                read -p "Please Enter Table Name: " TableName
                if [ -z $TableName ]; then
                    echo "input can't be empty"
                    continue
                fi
                if [ -e $TableName ]; then
                    read -p "Please Enter New Table Name: " NewTableName
                    mv "$TableName" "$NewTableName"
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
                    line_number=$(awk -F: -v word="$TableName" '$1 == word {print NR; exit}' ".metadata.txt")
                    value=$(awk -F: -v word="$TableName" '$1 == word {print $2; exit}' ".metadata.txt")
                    value=$((value + line_number))
                    line_number=$((line_number + 1))
                    awk -F: -v start="$line_number" -v end="$value" 'NR>=start && NR<=end' ".metadata.txt"


                    # read -p "Please Enter New Table Name: " NewTableName
                    # mv $TableName $NewTableName
                    echo "Table Is Renamed Successfully"
                else
                    echo "Table doesn't exist"
                fi
                ;;
                # insert disconnect
            "insert")
                list_tables
        esac
    done
}



# the actual execution!
echo "Welcome to Bash-DBMS!"
welcome
