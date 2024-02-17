dbms_path="databases"


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

#table options function
tableoptions(){
    select option in createTB removeTB listTBs renameTB update
    do
        case $option in
        "createTB")
            read -p "Please Enter Table Name: " TableName

            while true; do  # Loop until a valid name is entered
                if validateTableName TableName; then  
                    break 
                else
                    echo "Invalid option. Please try again."
                    # read -p "Please Enter Table Name: " TableName
                fi
            done

            if [ -z $TableName ]; then
                echo "Input can't be empty"
                continue
            fi
            if [ ! -e $TableName ]; then
                read -p "Please Enter Number of columns: " colNumber
                #adding metadata to database
                echo $TableName:$colNumber >> $dbms_path/$current_db/.$current_db.metadata
                echo $Table
                for ((i=1;i<=$colNumber;i++))
                do
                    read -p "Please Enter Column $i Name: " colName
                    select option in int float varchar date boolean
                    do
                    case $option in
                    "int")
                        echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
                        break
                    ;;
                    "float")
                        echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
                        break
                    ;;
                    "varchar")
                        echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
                        break
                    ;;
                    "date")
                        echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
                        break
                    ;;
                    "boolean")
                        echo $colName:$option >> $dbms_path/$current_db/.$current_db.metadata
                        break
                    ;;
                    esac
                    done
                done
                touch $dbms_path/$current_db/$TableName

                echo "Table Created Successfully"
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
            ls -F | grep -v '/$' | sed 's/[*=@|]$//'
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
tableoptions


