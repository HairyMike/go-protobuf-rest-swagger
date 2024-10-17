package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/grpc-ecosystem/grpc-gateway/v2/runtime"
	pb "github.com/hairymike/go-protobuf-rest-swagger/generated"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

// server is used to implement the ExampleService.
type server struct {
	pb.UnimplementedExampleServiceServer
}

// SayHello implements ExampleService.SayHello
func (s *server) SayHello(ctx context.Context, req *pb.ExampleRequest) (*pb.ExampleResponse, error) {
	// Logic for handling the gRPC request goes here
	responseMessage := fmt.Sprintf("Hello, %s!", req.Name)
	return &pb.ExampleResponse{Message: responseMessage}, nil
}

// SayGoodbye implements ExampleService.SayGoodbye
func (s *server) SayGoodbye(ctx context.Context, req *pb.ExampleRequest) (*pb.ExampleResponse, error) {
	// Logic for handling the gRPC request goes here
	responseMessage := fmt.Sprintf("Goodbye, %s!", req.Name)
	return &pb.ExampleResponse{Message: responseMessage}, nil
}

// runGRPCServer runs the gRPC server
func runGRPCServer() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterExampleServiceServer(grpcServer, &server{})

	log.Println("gRPC server is listening on port 50051...")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

// runRESTServer runs the REST proxy server
func runRESTServer() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	mux := runtime.NewServeMux()
	err := pb.RegisterExampleServiceHandlerFromEndpoint(ctx, mux, "localhost:50051", []grpc.DialOption{grpc.WithTransportCredentials(insecure.NewCredentials())})
	if err != nil {
		log.Fatalf("failed to register handler: %v", err)
	}

	log.Println("REST proxy server is listening on port 8081...")
	if err := http.ListenAndServe(":8081", mux); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}

func main() {
	go runGRPCServer() // Start gRPC server in a goroutine
	runRESTServer()    // Start REST proxy server
}
