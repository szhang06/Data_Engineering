# Data_Engineering

This repository is about data engineering skills on GCP.

### Create a data lake: 
#### Loading Taxi Data into Google Cloud SQL 2.5
https://www.cloudskillsboost.google/course_sessions/2440590/labs/344091





### Build a datawarehouse: 
#### Loading data into BigQuery
https://www.cloudskillsboost.google/course_sessions/2440590/labs/344100
  1. create a dataset under a project -> create a table
  
  2. load: 
  
   - from google cloud storage: 
        ```sql
        bq load \
        --source_format=CSV \
        --autodetect \
        --noreplace  \
        nyctaxi.2018trips \
        gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv
        ```
   - from local:
        upload

   - from another table
        ```
            #standardSQL
        CREATE TABLE
          nyctaxi.january_trips AS
        SELECT
          *
        FROM
          nyctaxi.2018trips
        WHERE
          EXTRACT(Month
          FROM
            pickup_datetime)=1;
       ```
       
### Building a data warehouse
https://www.cloudskillsboost.google/course_sessions/2440590/labs/344091

    query truct_array table.sql
    
    course documents


### ETL Processing on Google Cloud Using Dataflow and BigQuery
https://www.cloudskillsboost.google/focuses/3460?parent=catalog
