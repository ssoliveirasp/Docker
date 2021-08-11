FROM microsoft.com/dotnet/core/sdk:3.1 AS build-env
ARG PATH
COPY NuGet.Config /root/.nuget/NuGet/
ENV TZ=America/Sao_Paulo

WORKDIR /app
COPY . ./
WORKDIR /app/Docker.Api
RUN dotnet nuget add source https://packages.visualstudio.com/nuget/v3/index.json 
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM azurecr/aspnetcore:latest AS runtime
RUN apk add tzdata
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" >  /etc/timezone
RUN apk add icu-libs

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT false
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
USER app
COPY --from=build-env /app/Service/out .
ENTRYPOINT ["dotnet", "Service.Api.dll"]
