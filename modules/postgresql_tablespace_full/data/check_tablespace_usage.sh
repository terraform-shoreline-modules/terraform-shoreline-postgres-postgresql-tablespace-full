

#!/bin/bash



# Set variables

DB_NAME=${DATABASE_NAME}

TABLESPACE_NAME=${TABLESPACE_NAME}

MAX_TABLESPACE_SIZE=${MAX_TABLESPACE_SIZE}



# Check if tablespace is full

TABLESPACE_USAGE=$(psql -d $DB_NAME -t -c "SELECT pg_size_pretty(pg_tablespace_size('$TABLESPACE_NAME'))")

if [ "$TABLESPACE_USAGE" >= "$MAX_TABLESPACE_SIZE" ]; then

  echo "Tablespace $TABLESPACE_NAME is full."

  

  # Check for large data inserts

  LARGE_DATA_INSERTS=$(psql -d $DB_NAME -t -c "SELECT relname, n_tup_ins FROM pg_stat_user_tables WHERE n_tup_ins > 1000")

  if [ -n "$LARGE_DATA_INSERTS" ]; then

    echo "The following tables have had large data inserts:"

    echo "$LARGE_DATA_INSERTS"

  else

    echo "No tables have had large data inserts."

  fi

else

  echo "Tablespace $TABLESPACE_NAME is not full."

fi