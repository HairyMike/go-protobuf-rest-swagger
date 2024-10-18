# Swagger doc generation and REST proxy for your gRPC services
Greetings and Salutations.  Go checkout the accompanying medium article:
https://medium.com/@beardmanmike/creating-a-grpc-rest-proxy-with-swagger-bd2b56c1c917

## Setup
Ensure you're running an up-to-date version of Go.
```
make all
go mod tidy
go run ./...

# expected output
# 2024/10/18 11:26:52 REST proxy server is listening on port 8081...
# 2024/10/18 11:26:52 gRPC server is listening on port 50051...
```

## Testing
```
curl --location 'http://localhost:8081/v1/example/sayHello' \
--header 'Content-Type: application/json' \
--data '{
  "name": "Steve Harris"
}'

# expected output
# {"message":"Hello, Steve Harris!"}
```

Now go forth and have fun! May your code compile and run on the first try!
