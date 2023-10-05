

#!/bin/bash



# Set the parameters

TABLESPACE=${TABLESPACE_NAME}

ADDITIONAL_SPACE=${ADDITIONAL_SPACE_IN_GB}



# Check if the tablespace exists

if [ ! -d "$TABLESPACE" ]; then

  echo "Error: Tablespace $TABLESPACE does not exist."

  exit 1

fi



# Check if the additional space is a number

if ! [[ "$ADDITIONAL_SPACE" =~ ^[0-9]+$ ]]; then

  echo "Error: Additional space must be a number."

  exit 1

fi



# Add the additional space to the tablespace

sudo su - postgres -c "psql -c \"ALTER TABLESPACE $TABLESPACE SET (add data '$ADDITIONAL_SPACE GB')\""



echo "Additional space of $ADDITIONAL_SPACE GB added to tablespace $TABLESPACE."