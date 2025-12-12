FROM golang:1.25 AS build
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY . .
RUN go build -o artifacts .

# Final Stage with Distroless image

FROM gcr.io/distroless/base
COPY --from=build /app/artifacts .
COPY --from=build /app/static ./static
EXPOSE 8080
CMD [ "./artifacts" ]


