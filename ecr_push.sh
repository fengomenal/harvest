docker build -t harvest .
docker tag harvest:latest 182798957005.dkr.ecr.us-east-1.amazonaws.com/harvest:latest
docker push 182798957005.dkr.ecr.us-east-1.amazonaws.com/harvest:latest
