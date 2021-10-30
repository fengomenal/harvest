docker build -t harvest:sandbox .
docker run -it -v $(pwd)/sandbox:/app/app/sandbox harvest:sandbox sh
