FROM ghcr.io/cirruslabs/flutter:3.41.2 AS build

ARG BACKEND_URL=http://34.31.122.97

WORKDIR /app
COPY pubspec.* ./
COPY analysis_options.yaml ./
COPY lib ./lib
COPY web ./web

RUN flutter pub get
RUN flutter build web --release --dart-define=BACKEND_URL=$BACKEND_URL

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
