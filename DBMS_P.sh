#! /bin/bash

dbms_path="C:\Users\Mostafa Mohamed\DBMS_P"
cd $dbms_path



#table options function
tableoptions(){
select option in createTB removeTB listTBs renameTB
do
case $option in
"createTB")
read -p "Please Enter Table Name: " TableName

    if [ -z $TableName ]; then
        echo "input can't be empty"
        continue
    fi
    if [ ! -e $TableName ]; then
        read -p "Please Enter Columns Number: " colNumber
        for ((i=1;i<=$colNumber;i++))
        do
            read -p "Please Enter Column $i Name: " colName
            select option in int float varchar date boolean
            do
            case $option in
            "int")
                echo $colName:$option >> .metadata.txt
                break
            ;;
            "float")
                echo $colName:$option >> .metadata.txt
                break
            ;;
            "varchar")
                echo $colName:$option >> .metadata.txt
                break
            ;;
            "date")
                echo $colName:$option >> .metadata.txt
                break
            ;;
            "boolean")
                echo $colName:$option >> .metadata.txt
                break
            ;;
            esac
            done
        done
        touch $TableName.txt
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
        mv $TableName.txt $NewTableName.txt
        echo "Table Is Renamed Successfully"
    else
        echo "Table doesn't exist"
    fi
;;
esac
done
}

#Create DB or Connect DB

select option in CreateDB ConnectDB RemoveDB ListDBs
do
case $option in
"CreateDB")
    read -p "Please Enter Database Name: " DBName
    if [ -z $DBName ]; then
        echo "input can't be empty"
        continue
    fi
    if [ ! -e $DBName ]; then
        mkdir $DBName
        echo "Database Created Successfully"
        touch "$dbms_path/$DBName/.metadata.txt"
    else
        echo "Database Already exists"
    fi
;;
"ConnectDB")
    read -p "Please Enter Database Name: " ConDB
    if [ -z $ConDB ]; then
        echo "input can't be empty"
        continue
    fi
    if [ -e $ConDB ]; then
        cd $ConDB
        echo "Database $ConDB connected successfully"
        tableoptions
    else
        echo "Database $ConDB doesn't exist"
    fi
;;
"removeDB")
read -p "Please Enter Table Name: " DBname
    if [ -z $DBname ]; then
        echo "input can't be empty"
        continue
    fi
    if [  -e $DBname ]; then
        rm -rf $DBname
        echo "Database Removed Successfully"
    else
        echo "Database doesn't exist"
    fi
;;
"ListDBs")
    ls -F | grep '/$' | sed 's/\/$//'
;;
"renameDB")
read -p "Please Enter Database Name: " DBName
    if [ -z $DBName ]; then
        echo "input can't be empty"
        continue
    fi
    if [ -e $DBName ]; then
        read -p "Please Enter New Database Name: " NewDBName
        mv $DBName $NewDBName
        echo "Database Is Renamed Successfully"
    else
        echo "Database doesn't exist"
    fi
;;
esac

done

