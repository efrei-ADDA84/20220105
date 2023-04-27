#Define the python version that is being used
FROM python:3.10.9

#Define the working repository inside the Docker image
WORKDIR /app

#Copy the python file into the Docker image
COPY weather.py .

#Install the required libraries
RUN pip install requests

#Define environment variables
ENV LAT=""
ENV LONG=""
ENV API_KEY=""

#Execute the script weather.py with python
CMD [ "python", "weather.py" ]
