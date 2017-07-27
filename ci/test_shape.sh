#!/bin/bash

# Copyright 2017, RadiantBlue Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# ---Setup---
PZKEY=$PZ_API_KEY
curl="curl -S -s -u $PZKEY:"" -H Content-Type:application/json"


# ---Create test job using bfalg-shape service---
echo "Creating job"
jobId=`$curl -X POST https://piazza.int.geointservices.io/job \
    -d '{
        "data": {
            "dataInputs": {
                "body": {
                    "content": "{\"cmd\":\"-f landsatImage.TIF -o shape.geojson\",\"inExtFiles\":[\"https://landsat-pds.s3.amazonaws.com/L8/139/045/LC81390452014295LGN00/LC81390452014295LGN00_B1.TIF\"],\"inExtNames\":[\"landsatImage.TIF\"],\"outGeoJson\":[\"shape.geojson\"]}",
                    "type": "body",
                    "mimeType": "application/json"
                }
            },
            "dataOutput": [{"mimeType": "application/json","type": "text"}],
            "serviceId": "238e8795-1a4d-4220-8f5c-e6434f2c4373"
        },
        "type": "execute-service"
    }' | jq -r .data.jobId`


# ---Checking if job started---
if [ $jobId == "null" ]
then
    echo "Error creating job. Exiting test."
    exit 1
fi
echo "Kicked off job with jobId $jobId"


# ---Checking job status until success or otherwise---
jobStatus="null"
while [ $jobStatus != "Success" ]; do
    echo "Checking job status for job $jobId"
    jobStatus=`$curl -X GET https://piazza.int.geointservices.io/job/$jobId | jq -r .data.status`
    echo "job status = $jobStatus"
    if [ $jobStatus == "Cancelled" ]
    then
        echo "Job $jobId ended with status Cancelled"
        exit 1
    fi
    if [ $jobStatus == "Error" ]
    then
        echo "Job $jobId ended with status Error"
        exit 1
    fi
    if [ $jobStatus == "Fail" ]
    then
        echo "Job $jobId ended with status Fail"
        exit 1
    fi
    sleep 10s
done


# ---Getting dataId from completed job---
echo "Job $jobId finished. Getting dataId"
dataId=`$curl -X GET https://piazza.int.geointservices.io/job/$jobId | jq -r .data.result.dataId`


# ---Checking if dataId received---
if [ $dataId == "null" ]
then
    echo "Error getting dataId. Exiting test."
    exit 1
fi
echo "Retrieved dataId $dataId"


# ---Getting fileId from dataId---
echo "Getting fileId using dataId $dataId"
fileId=`$curl -X GET https://piazza.int.geointservices.io/file/$dataId | jq -r '.OutFiles."shape.geojson"'`


# ---Checking if fileId received---
if [ $fileId == "null" ]
then
    echo "Error getting fileId. Exiting test."
    exit 1
fi
echo "Retrieved fileId $fileId"


# ---Getting geojson data from file---
echo "Getting geojson data at fileId $fileId"
geojsonData=`$curl -X GET https://piazza.int.geointservices.io/file/$fileId`


# ---Checking if geojson data exists---
if [ $geojsonData | jq -r .type == "error" ]
then
    echo "Error getting geojson data. Exiting test."
    exit 1
fi

echo $geojsonData
exit 0