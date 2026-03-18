FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM/$TARGETARCH"
WORKDIR /source
COPY . .
RUN dotnet restore -a $TARGETARCH
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app .
CMD ["dotnet", "Worker.dll"]