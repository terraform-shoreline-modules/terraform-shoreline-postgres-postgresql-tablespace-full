
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# PostgreSQL tablespace full
---

This incident type occurs when the PostgreSQL tablespace of a database has reached its maximum storage capacity. When tablespace is full, it can no longer store any new data and any attempt to insert new data will fail. This can cause disruption in the normal operation of the database and affect the performance of applications that rely on the database.

### Parameters
```shell
export PATH_TO_TABLESPACE="PLACEHOLDER"

export DATABASE_NAME="PLACEHOLDER"

export TABLESPACE_NAME="PLACEHOLDER"

export ADDITIONAL_SPACE_IN_GB="PLACEHOLDER"

export MAX_TABLESPACE_SIZE="PLACEHOLDER"
```

## Debug

### Check the disk space usage of the PostgreSQL tablespace
```shell
df -h ${PATH_TO_TABLESPACE}
```

### Check the size of the tablespace
```shell
du -sh ${PATH_TO_TABLESPACE}
```

### List the largest tables in the database
```shell
psql -c "SELECT pg_size_pretty(pg_relation_size(relid)), relname FROM pg_stat_user_tables ORDER BY pg_relation_size(relid) DESC LIMIT 10;" ${DATABASE_NAME}
```

### List the largest indexes in the database
```shell
psql -c "SELECT pg_size_pretty(pg_relation_size(indexrelid)), relname, indexrelname FROM pg_stat_user_indexes JOIN pg_index USING(indexrelid) WHERE indisunique = false ORDER BY pg_relation_size(indexrelid) DESC LIMIT 10;" ${DATABASE_NAME}
```

### Check the available space in the tablespace
```shell
psql -c "SELECT pg_size_pretty(pg_tablespace_size('${TABLESPACE_NAME}'));" ${DATABASE_NAME}
```

### Large data inserts: If a large amount of data is inserted into the database at once, it can fill up the tablespace quickly and cause it to become full.
```shell


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


```

## Repair

### Increase the storage capacity of the tablespace by adding more disk space to the server where the database is hosted.
```shell


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


```